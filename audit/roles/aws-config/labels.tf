module "label" {
  source      = "../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = local.role_name
  team        = local.team
}

module "reporter_lambda_label" {
  source      = "../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = local.role_name
  team        = local.team
  attributes  = ["reporter"]
}

module "reporter_lambda_cross_account_label" {
  source      = "../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = local.role_name
  team        = local.team
  attributes  = ["reporter", "cross", "account"]
}

module "aggregator_role_label" {
  source      = "../../../modules/base/null-label/v2"
  environment = "audit"
  role_name   = local.role_name
  team        = local.team
  attributes  = ["org", "role"]
}
