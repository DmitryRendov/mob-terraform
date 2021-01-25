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

resource "aws_config_organization_custom_rule" "sqs_encryption_check" {
  depends_on = [
    aws_lambda_permission.lambda_permission,
  ]

  lambda_function_arn         = module.sqs_encryption.function_arn
  name                        = "sqs_encryption_check"
  trigger_types               = ["ScheduledNotification"]
  maximum_execution_frequency = "TwentyFour_Hours"
  excluded_accounts           = var.exclude_accounts
  description                 = "Check whether SQS queue has encryption at rest enabled."

  input_parameters = jsonencode(
    {
      "QueueNameStartsWith" = null
    }
  )
}

output "sqs_encryption_check" {
  value = aws_config_organization_custom_rule.sqs_encryption_check
}

resource "aws_lambda_permission" "lambda_permission" {
  count         = local.count
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = module.sqs_encryption.function_name
  principal     = "config.amazonaws.com"
}

##
# Lambda for Custom Config Rule to check for SQS encryption compliance
#
module "sqs_encryption" {
  enabled                  = var.enabled
  source                   = "../../../../modules/base/lambda/v1"
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
  attributes               = ["sqs", "encryption"]
  description              = "Lambda for Custom Config Rule to check for SQS encryption compliance."
  variables = {
    "LOG_LEVEL" = "INFO"
  }
}

data "archive_file" "sqs_encryption" {
  type        = "zip"
  source_file = "${path.module}/files/sqs_encryption/sqs_encryption.py"
  output_path = "${path.module}/files/sqs_encryption_check.zip"
}
