##
# ORG Custom Config Rule to check for SQS encryption compliance.
#
data "aws_region" "current" {}

resource "aws_iam_policy" "lambda_policy" {
  name   = module.lambda_label.id
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = module.lambda_cross_account_role_label.id
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "aws_iam_policy_document" "lambda_policy_document" {
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
