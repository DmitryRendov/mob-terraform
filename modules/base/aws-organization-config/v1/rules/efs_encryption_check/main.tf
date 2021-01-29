##
# Lambda for Custom Config Rule to check for EFS encryption compliance
#
data "aws_region" "current" {}

data "aws_iam_policy_document" "efs_encryption_lambda" {
  statement {
    sid = "EC2"
    actions = [
      "elasticfilesystem:DescribeFileSystems",
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

module "efs_encryption" {
  source                   = "../../../../../../modules/base/lambda/v1"
  environment              = "default"
  filename                 = data.archive_file.efs_encryption.output_path
  handler                  = "efs_encryption.lambda_handler"
  iam_role_policy_document = data.aws_iam_policy_document.efs_encryption_lambda.json
  role_name                = "aws-config"
  runtime                  = "python3.8"
  source_code_hash         = data.archive_file.efs_encryption.output_base64sha256
  timeout                  = "600"
  attach_vpc_config        = false
  attributes               = ["efs", "encryption", data.aws_region.current.name]
  description              = "Lambda for Custom Config Rule to check for EFS encryption compliance."
  variables = {
    "LOG_LEVEL" = "INFO"
  }
}

// TODO: Move source code to S3 bucket and CircleCI
data "archive_file" "efs_encryption" {
  type        = "zip"
  source_file = "${path.module}/files/efs_encryption/efs_encryption.py"
  output_path = "${path.module}/files/efs_encryption_check.zip"
}


resource "aws_lambda_permission" "efs_encryption_aws_config_rule" {
  statement_id  = "AllowExecutionFromConfig"
  action        = "lambda:InvokeFunction"
  function_name = module.efs_encryption.function_name
  principal     = "config.amazonaws.com"
}

resource "aws_config_organization_custom_rule" "efs_encryption_check" {
  depends_on = [
    module.efs_encryption,
  ]
  name        = "efs_encryption_check"
  description = "Check whether Amazon EFS Filesytems are configured to encrypt the file data using AWS Key Management Service (AWS KMS)"

  trigger_types       = ["ScheduledNotification"]
  lambda_function_arn = module.efs_encryption.function_arn

  maximum_execution_frequency = var.maximum_execution_frequency
  excluded_accounts           = var.exclude_accounts
  input_parameters            = var.input_parameters
}
