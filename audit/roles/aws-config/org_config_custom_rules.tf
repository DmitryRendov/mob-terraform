##
# ORG custom AWS Config rules
#

module "sqs_encryption" {
  source = "./rules/sqs_encryption"

  maximum_execution_frequency = local.default_execution_frequency
  exclude_accounts            = local.exclude_accounts
  aws_account_map             = var.aws_account_map
  aws_account_ids             = distinct(values(var.aws_account_map))

  input_parameters = {
    "QueueNameStartsWith" = null
  }
  providers = {
    aws.audit   = aws.audit
    aws.bastion = aws.bastion
  }

}

module "sqs_encryption_east" {
  source = "./rules/sqs_encryption"

  maximum_execution_frequency = local.default_execution_frequency
  exclude_accounts            = local.exclude_accounts
  aws_account_map             = var.aws_account_map
  aws_account_ids             = distinct(values(var.aws_account_map))

  input_parameters = {
    "QueueNameStartsWith" = null
  }

  providers = {
    aws         = aws.west
    aws.audit   = aws.audit
    aws.bastion = aws.bastion
  }
}
