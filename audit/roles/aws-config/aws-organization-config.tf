module "aws_config" {
  source          = "../../../modules/base/aws-organization-config/v1"
  aws_account_map = var.aws_account_map

  role_name   = var.account_name
  environment = terraform.workspace

  exclude_accounts = local.exclude_accounts
}
