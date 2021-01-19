module "aws_config" {
  source          = "../../../modules/base/aws-config/v1"
  aws_account_id  = var.aws_account_id
  aws_account_map = var.aws_account_map

  role_name        = var.account_name
  environment      = terraform.workspace
  account_name     = var.account_name
  exclude_accounts = local.exclude_accounts

  # Config Recorder settings
  cr_is_enabled         = local.config_recorder_enabled
  cr_delivery_frequency = "TwentyFour_Hours"
  cr_s3_bucket          = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws
  }
}

module "aws_config_west" {
  source          = "../../../modules/base/aws-config/v1"
  aws_account_id  = var.aws_account_id
  aws_account_map = var.aws_account_map

  role_name        = var.account_name
  environment      = terraform.workspace
  account_name     = var.account_name
  exclude_accounts = local.exclude_accounts

  # Config Recorder settings
  cr_is_enabled         = local.config_recorder_enabled
  cr_delivery_frequency = "TwentyFour_Hours"
  cr_s3_bucket          = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws.west
  }
}
