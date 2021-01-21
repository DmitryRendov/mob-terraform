module "label" {
  source      = "../../../modules/base/null-label/v1"
  environment = "audit"
  role_name   = local.role_name
  team        = local.team
}

module "aggregator_role_label" {
  source      = "../../../modules/base/null-label/v1"
  environment = "audit"
  role_name   = local.role_name
  team        = local.team
  attributes  = ["org", "role"]
}

module "aggregator_test_role_label" {
  source      = "../../../modules/base/null-label/v1"
  environment = "audit"
  role_name   = local.role_name
  team        = local.team
  attributes  = ["org", "role", "test"]
}
