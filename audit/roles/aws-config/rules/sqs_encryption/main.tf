##
# ORG Custom Config Rule to check for SQS encryption compliance.
#
data "aws_region" "current" {}

module "lambda_label" {
  source      = "../../../../../modules/base/null-label/v1"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["sqs", "encryption", data.aws_region.current.name]
}

data "aws_iam_role" "config_role" {
  name = var.iam_role.name
}

resource "aws_iam_policy" "default" {
  name   = module.lambda_label.id
  path   = "/"
  policy = data.aws_iam_policy_document.sqs_encryption_lambda.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = data.aws_iam_role.config_role.name
  policy_arn = aws_iam_policy.default.arn
}

data "aws_iam_policy_document" "sqs_encryption_lambda" {
  statement {
    sid = "EC2"
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
      "logs:DescribeLogStreams",
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
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = module.sqs_encryption.function_name
  principal     = "config.amazonaws.com"
}

module "sqs_encryption" {
  source            = "../../../../../modules/base/lambda/v1"
  environment       = "default"
  filename          = data.archive_file.sqs_encryption.output_path
  handler           = "sqs_encryption.lambda_handler"
  iam_role_arn      = data.aws_iam_role.config_role.arn
  role_name         = "aws-config"
  runtime           = "python3.8"
  source_code_hash  = data.archive_file.sqs_encryption.output_base64sha256
  timeout           = 60
  memory_size       = 128
  attach_vpc_config = false
  alarm_enabled     = false
  attributes        = ["sqs", "encryption", data.aws_region.current.name]
  description       = "Lambda for Custom Config Rule to check for SQS encryption compliance."
  variables = {
    "LOG_LEVEL" = "DEBUG"
  }
}

resource "aws_config_organization_custom_rule" "sqs_encryption" {
  depends_on = [
    module.sqs_encryption,
  ]
  name                = "sqs_encryption"
  trigger_types       = ["ScheduledNotification"]
  lambda_function_arn = module.sqs_encryption.function_arn
  description         = "Check whether SQS queue has encryption at rest enabled."

  maximum_execution_frequency = var.maximum_execution_frequency
  excluded_accounts           = var.exclude_accounts
  input_parameters = jsonencode(merge(
    var.input_parameters,
    {
      "ExecutionRoleName" = data.aws_iam_role.config_role.name
    }
  ))
}
