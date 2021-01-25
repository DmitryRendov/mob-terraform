module "aws_config" {
  source      = "../../../modules/base/aws-organization-config/v1"
  role_name   = var.account_name
  environment = terraform.workspace

  exclude_accounts = local.exclude_accounts

  alarm_actions = []

  providers = {
    aws      = aws
    aws.west = aws.west
  }
}
