locals {
  team      = "ops"
  role_name = "aws-config"

  config_enabled = true

  aggregator_source_regions = ["us-west-2", "us-east-1", "eu-central-1"]
  exclude_accounts = [
    var.aws_account_map.production,
    var.aws_account_map.staging,
  ]

  # The maximum frequency with which AWS Config runs evaluations for a rule.
  default_execution_frequency = "TwentyFour_Hours"

}
