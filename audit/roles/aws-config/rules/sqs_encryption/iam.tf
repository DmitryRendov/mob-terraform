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

resource "aws_iam_role" "lambda_role" {
  name = module.lambda_role_label.id

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json

  tags = module.lambda_role_label.tags
}

data "aws_iam_policy_document" "lambda_cross_account_policy" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    resources = formatlist(
      "arn:aws:iam::%s:role/${module.lambda_cross_account_role_label.id}",
      sort(values(var.aws_account_map)),
    )
  }
}

resource "aws_iam_policy" "lambda_cross_account_policy" {
  name   = module.lambda_role_label.id
  policy = data.aws_iam_policy_document.lambda_cross_account_policy.json
}

resource "aws_iam_role_policy_attachment" "lambda_cross_account" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_cross_account_policy.arn
}

resource "aws_iam_role_policy_attachment" "execution_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "config_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

data "aws_iam_policy_document" "cross_account_assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.lambda_role.arn]
    }
  }
}

module "cross_account_roles" {
  source                      = "../../../../../modules/base/all-accounts-iam-role/v1"
  name                        = module.lambda_cross_account_role_label.id
  description                 = "Audit AWS Config Lambda uses this role to gather data"
  policy_arn                  = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
  assume_role_policy_document = data.aws_iam_policy_document.cross_account_assume_role_policy.json

  providers = {
    aws.audit   = aws.audit
    aws.bastion = aws.bastion
  }
}
