resource "aws_lambda_function" "default" {
  provider      = aws.audit
  filename      = "lambda_function.zip"
  function_name = module.lambda_label.id
  role          = aws_iam_role.config_lambda.arn
  handler       = "lambda_function.lambda_handler"

  // TODO: make configurable, this involves having a different hello world script for each language
  runtime = "python3.7"
  tags    = module.lambda_label.tags
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
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

resource "aws_iam_role" "config_lambda" {
  name = module.lambda_label.id

  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json

  tags = module.lambda_label.tags
}

data "aws_iam_policy_document" "default" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    resources = formatlist(
      "arn:aws:iam::%s:role/${module.label.id}",
      sort(var.aws_account_ids),
    )
  }
}

resource "aws_iam_policy" "default" {
  name   = module.lambda_label.id
  path   = "/"
  policy = data.aws_iam_policy_document.default.json
}

resource "aws_iam_role_policy_attachment" "default" {
  role       = aws_iam_role.config_lambda.name
  policy_arn = aws_iam_policy.default.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch_logs" {
  role       = aws_iam_role.config_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_permission" "allow_cross_account" {
  count          = length(var.aws_account_ids)
  statement_id   = "AllowExecutionFromCrossAccount-${element(var.aws_account_ids, count.index)}"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.default.function_name
  principal      = "config.amazonaws.com"
  source_account = element(sort(var.aws_account_ids), count.index)
}

resource "aws_cloudwatch_metric_alarm" "error_alarm" {
  alarm_name          = module.alarm_label.id
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "86400"
  statistic           = "SampleCount"
  threshold           = "1"
  alarm_description   = "AWS Config Lambda ${module.lambda_label.id} errors"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.alarm_actions

  dimensions = {
    FunctionName = aws_lambda_function.default.function_name
  }
}
