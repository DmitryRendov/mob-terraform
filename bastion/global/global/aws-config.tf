module "aws_config_recorder" {
  source          = "../../../modules/base/aws-config-recorder/v1"
  aws_account_map = var.aws_account_map
  role_name       = var.account_name
  environment     = terraform.workspace

  # Config Recorder settings
  is_enabled         = local.config_recorder_enabled
  delivery_frequency = local.config_recorder_delivery_frequency
  s3_bucket          = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws
  }
}

module "aws_config_recorder_west" {
  source          = "../../../modules/base/aws-config-recorder/v1"
  aws_account_map = var.aws_account_map
  role_name       = var.account_name
  environment     = terraform.workspace

  # Config Recorder settings
  is_enabled         = local.config_recorder_enabled
  delivery_frequency = local.config_recorder_delivery_frequency
  s3_bucket          = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws.west
  }
}
