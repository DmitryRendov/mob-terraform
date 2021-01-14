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
  timeout                  = "600"
  attach_vpc_config        = false
  alarm_enabled            = false
  attributes               = ["sqs", "encryption", data.aws_region.current.name]
  description              = "Lambda for Custom Config Rule to check for SQS encryption compliance."
  variables = {
    "LOG_LEVEL" = "INFO"
  }
  providers = {
    aws = aws
  }
}

data "archive_file" "sqs_encryption" {
  type        = "zip"
  source_file = "${path.module}/files/sqs_encryption/sqs_encryption.py"
  output_path = local.sqs_encryption_lambda_filename
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
}

resource "aws_lambda_permission" "sqs_encryption_aws_config_rule" {
  count         = local.count
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = module.sqs_encryption.function_name
  principal     = "config.amazonaws.com"
}
