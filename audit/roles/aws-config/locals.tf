locals {
  team      = "ops"
  role_name = "aws-config"

  config_recorder_enabled = false
  exclude_accounts = [
    var.aws_account_map.production,
  ]
}
