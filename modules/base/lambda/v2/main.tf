locals {
  iam_role_count = var.iam_role_arn == "" ? 1 : 0

  lambda_function_id = length(module.label.id) > 64 ? module.label.id_brief : module.label.id

  vpc_config = var.attach_vpc_config ? [{
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnet_ids
  }] : []
}

module "label" {
  source      = "../../../../modules/base/null-label/v2"
  environment = var.environment
  role_name   = var.role_name
  attributes  = var.attributes
}

data "aws_iam_policy_document" "default" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = compact(concat(["lambda.amazonaws.com"], var.assume_role_trusted_services))
    }
  }
}

resource "aws_iam_role" "default" {
  count              = local.iam_role_count
  name               = local.lambda_function_id
  assume_role_policy = data.aws_iam_policy_document.default.json
}

resource "aws_lambda_function" "default" {
  filename         = var.filename
  function_name    = local.lambda_function_id
  role             = local.iam_role_count < 1 ? var.iam_role_arn : aws_iam_role.default[0].arn
  handler          = var.handler
  memory_size      = var.memory_size
  source_code_hash = var.source_code_hash
  runtime          = var.runtime
  timeout          = var.timeout
  kms_key_arn      = var.kms_key_arn
  description      = var.description
  publish          = var.publish

  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  dynamic "vpc_config" {
    for_each = local.vpc_config
    content {
      security_group_ids = vpc_config.value.security_group_ids
      subnet_ids         = vpc_config.value.subnet_ids
    }
  }

  dynamic "environment" {
    for_each = length(var.variables) > 0 ? [1] : []
    content {
      variables = var.variables
    }
  }

  lifecycle {
    ignore_changes = [last_modified]
  }
}

resource "aws_iam_role_policy" "default" {
  count  = local.iam_role_count
  name   = local.lambda_function_id
  role   = aws_iam_role.default[0].name
  policy = var.iam_role_policy_document
}

resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  count      = local.iam_role_count
  role       = aws_iam_role.default[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_cloudwatch_metric_alarm" "error" {
  count               = var.alarm_enabled ? 1 : 0
  alarm_name          = "${local.lambda_function_id}-error"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.alarm_evaluation_periods
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = var.alarm_period
  statistic           = "Maximum"
  threshold           = var.alarm_threshold
  treat_missing_data  = var.treat_missing_data

  dimensions = {
    FunctionName = aws_lambda_function.default.function_name
  }

  alarm_description = "This metric monitors errors that occur in ${local.lambda_function_id}"
  alarm_actions     = var.alarm_actions
  ok_actions        = var.alarm_actions
}

resource "aws_cloudwatch_log_group" "group" {
  name              = "/aws/lambda/${aws_lambda_function.default.function_name}"
  retention_in_days = var.log_retention
  tags              = module.label.tags
}
