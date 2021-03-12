module "label" {
  source      = "../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  team        = "ops"
  attributes  = [var.name, "rule"]
}

module "lambda_label" {
  source      = "../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  team        = "ops"
  attributes  = [var.name, "rule", "lambda"]
}

module "alarm_label" {
  source      = "../../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = "aws-config"
  team        = "ops"
  attributes  = [var.name, "alarm"]
}
