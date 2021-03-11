##
# ORG custom AWS Config rules
#

module "sqs_encryption" {
  source = "./rules/sqs_encryption"

  maximum_execution_frequency = local.default_execution_frequency
  exclude_accounts            = local.exclude_accounts
  iam_role                    = module.aws_config_cross.config_iam_role

  input_parameters = {
    "QueueNameStartsWith" = null
  }
}

module "sqs_encryption_west" {
  source = "./rules/sqs_encryption"

  maximum_execution_frequency = local.default_execution_frequency
  exclude_accounts            = local.exclude_accounts
  iam_role                    = module.aws_config_cross.config_iam_role

  input_parameters = {
    "QueueNameStartsWith" = null
  }

  providers = {
    aws = aws.west
  }
}
