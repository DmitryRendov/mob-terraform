module "label" {
  source      = "../../../../modules/base/null-label/v1"
  environment = "audit"
  role_name   = "aws-config"
  team        = "ops"
  attributes  = [var.name, "rule"]
}

module "lambda_label" {
  source      = "../../../../modules/base/null-label/v1"
  environment = "audit"
  role_name   = "aws-config"
  team        = "ops"
  attributes  = [var.name, "rule", "lambda"]
}
