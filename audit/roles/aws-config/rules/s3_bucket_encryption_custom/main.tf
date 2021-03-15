##
# ORG Custom Config Rule to ensures S3 Buckets have server side encryption enabled.
# With an exception, if we have a proper tag is set, eg `audit:public_okay`
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
    sid = "EC2"
    actions = [
      "s3:GetEncryptionConfiguration",
    ]
    effect    = "Allow"
    resources = ["arn:aws:s3:::*"]
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

resource "aws_lambda_function" "default" {
  filename         = data.archive_file.s3_bucket_encryption_custom.output_path
  function_name    = local.lambda_function_id
  role             = aws_iam_role.lambda_role.arn
  handler          = "s3_bucket_encryption_custom.lambda_handler"
  memory_size      = 128
  source_code_hash = data.archive_file.s3_bucket_encryption_custom.output_base64sha256
  runtime          = "python3.8"
  timeout          = 60
  description      = "Lambda for Custom Config Rule to ensures S3 Buckets have server side encryption enabled."

  environment {
    variables = {
      "LOG_LEVEL" = "INFO"
    }
  }

  lifecycle {
    ignore_changes = [last_modified]
  }
}

// TODO: Move source code to S3 bucket and CircleCI
data "archive_file" "s3_bucket_encryption_custom" {
  type        = "zip"
  source_file = "${path.module}/files/s3_bucket_encryption_custom/s3_bucket_encryption_custom.py"
  output_path = "${path.module}/files/s3_bucket_encryption_custom.zip"
}


resource "aws_lambda_permission" "lambda_permission" {
  count          = length(var.aws_account_ids)
  statement_id   = "AllowExecutionFromCrossAccount-${element(var.aws_account_ids, count.index)}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.default.function_name
  principal      = "config.amazonaws.com"
  source_account = element(sort(var.aws_account_ids), count.index)
}

resource "aws_config_organization_custom_rule" "s3_bucket_encryption_custom" {
  depends_on = [
    aws_iam_role.lambda_role,
    module.cross_account_roles,
    aws_lambda_function.default
  ]
  name        = "s3_bucket_encryption_custom"
  description = "Config Rule to ensures S3 Buckets have server side encryption enabled, except tagged by `audit:public_okay` tag."

  trigger_types       = ["ConfigurationItemChangeNotification"]
  lambda_function_arn = aws_lambda_function.default.arn

  excluded_accounts = var.exclude_accounts
  input_parameters = jsonencode(merge(
    var.input_parameters,
    {
      "ExecutionRoleName" = module.lambda_cross_account_role_label.id
    }
  ))
}
