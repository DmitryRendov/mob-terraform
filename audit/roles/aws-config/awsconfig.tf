module "aws_config" {
  source          = "../../../modules/base/aws-config/v1"
  aws_account_id  = var.aws_account_id
  aws_account_map = var.aws_account_map

  role_name    = var.account_name
  environment  = terraform.workspace
  account_name = var.account_name
  cr_s3_bucket = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws
  }
}

#module "aws_config_east" {
#  source          = "../../../modules/base/aws-config/v1"
#  aws_account_id  = var.aws_account_id
#  aws_account_map = var.aws_account_map

#  role_name                 = var.account_name
#  environment               = terraform.workspace
#  account_name              = var.account_name
#  cr_s3_bucket              = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

#  providers = {
#    aws = aws.west
#  }
#}
