locals {
  team      = "ops"
  role_name = "aws-config"

  aggregator_source_regions = ["us-west-2", "us-east-1"]

  config_recorder_enabled = false
  exclude_accounts = [
    var.aws_account_map.production,
  ]
}
