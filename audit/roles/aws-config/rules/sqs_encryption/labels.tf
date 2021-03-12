module "lambda_label" {
  source      = "../../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["sqs", "encryption", data.aws_region.current.name]
}

module "lambda_role_label" {
  source      = "../../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["reporter"]
}

module "lambda_cross_account_label" {
  source      = "../../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["reporter", "cross", "account"]
}
