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
  tags              = module.lambda_label.tags
}
