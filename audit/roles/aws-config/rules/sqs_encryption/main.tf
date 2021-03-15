##
# ORG Custom Config Rule to check for SQS encryption compliance.
#
data "aws_region" "current" {}

locals {
  lambda_function_id = length(module.lambda_label.id) > 64 ? module.lambda_label.id_brief : module.lambda_label.id
}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name = module.lambda_role_label.id

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = module.lambda_role_label.tags
}

data "aws_iam_policy_document" "lambda_cross_account_policy" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    resources = formatlist(
      "arn:aws:iam::%s:role/${module.lambda_cross_account_role_label.id}",
      sort(values(var.aws_account_map)),
    )
  }
}

resource "aws_iam_policy" "lambda_cross_account_policy" {
  name   = module.lambda_role_label.id
  policy = data.aws_iam_policy_document.lambda_cross_account_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_cross_account" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_cross_account_policy.arn
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "cross_account_assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_role.arn]
    }
  }
}

module "cross_account_roles" {
  source                      = "../../../../../modules/base/all-accounts-iam-role/v1"
  name                        = module.lambda_cross_account_role_label.id
  description                 = "Audit AWS Config SQS lambda uses this role to gather data"
  policy_arn                  = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
  assume_role_policy_document = data.aws_iam_policy_document.cross_account_assume_role_policy.json

  providers = {
    aws.audit   = aws.audit
    aws.bastion = aws.bastion
  }
}

resource "aws_iam_policy" "sqs_encryption" {
  name   = module.lambda_label.id
  path   = "/"
  policy = data.aws_iam_policy_document.sqs_encryption_lambda.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = module.lambda_cross_account_role_label.id
  policy_arn = aws_iam_policy.sqs_encryption.arn
}

data "aws_iam_policy_document" "sqs_encryption_lambda" {
  statement {
    sid = "SQSList"
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:ListQueues",
      "sqs:ListQueueTags",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "Config"
    actions = [
      "config:GetComplianceDetailsByConfigRule",
      "config:GetResourceConfigHistory",
      "config:PutEvaluations",
    ]
    effect    = "Allow"
    resources = ["*"]
  }
  statement {
    sid = "AllowAccessToCloudwatchLogs"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["*"]
  }
}

// TODO: Move source code to S3 bucket and CircleCI
data "archive_file" "sqs_encryption" {
  type        = "zip"
  source_file = "${path.module}/files/sqs_encryption/sqs_encryption.py"
  output_path = "${path.module}/files/sqs_encryption.zip"
}

resource "aws_lambda_permission" "lambda_permission" {
  count          = length(var.aws_account_ids)
  statement_id   = "AllowExecutionFromCrossAccount-${element(var.aws_account_ids, count.index)}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.default.function_name
  principal      = "config.amazonaws.com"
  source_account = element(sort(var.aws_account_ids), count.index)
}

resource "aws_lambda_function" "default" {
  filename         = data.archive_file.sqs_encryption.output_path
  function_name    = local.lambda_function_id
  role             = aws_iam_role.lambda_role.arn
  handler          = "sqs_encryption.lambda_handler"
  memory_size      = 128
  source_code_hash = data.archive_file.sqs_encryption.output_base64sha256
  runtime          = "python3.8"
  timeout          = 60
  description      = "Lambda for Custom Config Rule to check for SQS encryption compliance."

  environment {
    variables = {
      "LOG_LEVEL" = "INFO"
    }
  }

  lifecycle {
    ignore_changes = [last_modified]
  }
}

resource "aws_cloudwatch_metric_alarm" "error" {
  alarm_name          = "${local.lambda_function_id}-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 86400
  statistic           = "Maximum"
  threshold           = 1
  treat_missing_data  = "missing"

  dimensions = {
    FunctionName = aws_lambda_function.default.function_name
  }

  alarm_description = "This metric monitors errors that occur in ${local.lambda_function_id}"
}

resource "aws_cloudwatch_log_group" "group" {
  name              = "/aws/lambda/${aws_lambda_function.default.function_name}"
  retention_in_days = 30
  tags              = module.lambda_label.tags
}


resource "aws_config_organization_custom_rule" "sqs_encryption" {
  depends_on = [
    aws_lambda_function.default,
    aws_iam_role.lambda_role,
    module.cross_account_roles
  ]
  name                = "sqs_encryption"
  trigger_types       = ["ScheduledNotification"]
  lambda_function_arn = aws_lambda_function.default.arn
  description         = "Check whether SQS queue has encryption at rest enabled."

  maximum_execution_frequency = var.maximum_execution_frequency
  excluded_accounts           = var.exclude_accounts
  input_parameters = jsonencode(merge(
    var.input_parameters,
    {
      "ExecutionRoleName" = module.lambda_cross_account_role_label.id
    }
  ))
}
