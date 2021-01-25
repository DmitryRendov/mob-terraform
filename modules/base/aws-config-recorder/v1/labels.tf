module "label" {
  source      = "../../null-label/v1"
  environment = var.environment
  role_name   = var.role_name
}

module "config_label" {
  source      = "../../null-label/v1"
  environment = var.environment
  role_name   = var.role_name
  attributes  = ["config", "recorder", data.aws_region.current.name]
}
