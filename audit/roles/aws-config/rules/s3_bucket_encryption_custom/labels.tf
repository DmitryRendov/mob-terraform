module "lambda_label" {
  source      = "../../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["s3", "encryption", data.aws_region.current.name]
}

module "lambda_role_label" {
  source      = "../../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["s3", "encryption", "role", data.aws_region.current.name]
}

module "lambda_cross_account_role_label" {
  source      = "../../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  attributes  = ["s3", "encryption", "cross", "account", "role", data.aws_region.current.name]
}
