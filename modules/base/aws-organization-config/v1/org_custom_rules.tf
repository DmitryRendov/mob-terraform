module "sqs_encryption" {
  source = "./rules/sqs_encryption_check"

  maximum_execution_frequency = var.maximum_execution_frequency
  exclude_accounts            = var.exclude_accounts
}

module "sqs_encryption_west" {
  source = "./rules/sqs_encryption_check"

  maximum_execution_frequency = var.maximum_execution_frequency
  exclude_accounts            = var.exclude_accounts

  providers = {
    aws = aws.west
  }
}
