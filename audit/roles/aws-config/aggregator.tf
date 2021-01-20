resource "aws_config_configuration_aggregator" "default" {
  name = "all-accounts"

  account_aggregation_source {
    account_ids = distinct(values(var.aws_account_map))
    regions     = ["us-east-1", "us-west-2"]
  }
}
