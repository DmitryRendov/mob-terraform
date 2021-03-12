data "aws_iam_policy_document" "assume_role_policy" {
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

resource "aws_iam_role" "reporter_lambda" {
  name = module.reporter_lambda_label.id

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = module.reporter_lambda_label.tags
}

data "aws_iam_policy_document" "reporter_lambda_cross_account" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    resources = formatlist(
      "arn:aws:iam::%s:role/${module.reporter_lambda_cross_account_label.id}",
      sort(values(var.aws_account_map)),
    )
  }
}

resource "aws_iam_policy" "reporter_lambda_cross_account" {
  name   = module.reporter_lambda_label.id
  policy = data.aws_iam_policy_document.reporter_lambda_cross_account.json
}

resource "aws_iam_role_policy_attachment" "reporter_lambda_cross_account" {
  role       = aws_iam_role.reporter_lambda.name
  policy_arn = aws_iam_policy.reporter_lambda_cross_account.arn
}

resource "aws_iam_role_policy_attachment" "reporter_cloudwatch_logs" {
  role       = aws_iam_role.reporter_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "reporter_config_role" {
  role       = aws_iam_role.reporter_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_lambda_function" "reporter" {
  filename      = "lambda_function.zip"
  function_name = module.reporter_lambda_label.id
  role          = aws_iam_role.reporter_lambda.arn
  handler       = "lambda_function.lambda_handler"
  timeout       = 210

  runtime = "python3.7"

  environment {
    variables = {
      account_map             = jsonencode(var.aws_account_map)
      cross_account_role_name = module.reporter_lambda_cross_account_label.id
    }
  }

  tags = module.reporter_lambda_label.tags
}

data "aws_iam_policy_document" "reporter_cross_account_assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.reporter_lambda.arn]
    }
  }
}

module "cross_account_lambda_reporter_roles" {
  source                      = "../../../modules/base/all-accounts-iam-role/v1"
  name                        = module.reporter_lambda_cross_account_label.id
  description                 = "Audit AWS Config Reporter lambda uses this role to gather data"
  policy_arn                  = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
  assume_role_policy_document = data.aws_iam_policy_document.reporter_cross_account_assume_role_policy.json

  providers = {
    aws.audit   = aws.audit
    aws.bastion = aws.bastion
  }
}
