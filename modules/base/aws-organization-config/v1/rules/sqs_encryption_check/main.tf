##
# Lambda for Custom Config Rule to check for SQS encryption compliance
#
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
}

data "archive_file" "sqs_encryption" {
  type        = "zip"
  source_file = "${path.module}/files/sqs_encryption/sqs_encryption.py"
  output_path = "${path.module}/files/sqs_encryption_check.zip"
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = module.sqs_encryption.function_name
  principal     = "config.amazonaws.com"
}

module "sqs_encryption" {
  source                   = "../../../../../../modules/base/lambda/v1"
  environment              = var.environment
  filename                 = data.archive_file.sqs_encryption.output_path
  handler                  = "sqs_encryption.lambda_handler"
  iam_role_policy_document = data.aws_iam_policy_document.sqs_encryption_lambda.json
  role_name                = "aws-config"
  runtime                  = "python3.8"
  source_code_hash         = data.archive_file.sqs_encryption.output_base64sha256
  timeout                  = 60
  memory_size              = 128
  attach_vpc_config        = false
  alarm_enabled            = false
  attributes               = ["sqs", "encryption", data.aws_region.current.name]
  description              = "Lambda for Custom Config Rule to check for SQS encryption compliance."
  variables = {
    "LOG_LEVEL" = "INFO"
  }
}

resource "aws_config_organization_custom_rule" "sqs_encryption_check" {
  depends_on = [
    module.sqs_encryption,
  ]
  name                        = "sqs_encryption_check"
  lambda_function_arn         = module.sqs_encryption.function_arn
  trigger_types               = ["ScheduledNotification"]
  maximum_execution_frequency = var.maximum_execution_frequency
  excluded_accounts           = var.exclude_accounts
  description                 = "Check whether SQS queue has encryption at rest enabled."

  input_parameters = jsonencode(
    {
      "QueueNameStartsWith" = null
    }
  )
}
