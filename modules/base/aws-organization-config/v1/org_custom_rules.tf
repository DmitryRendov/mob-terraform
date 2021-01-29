module "sqs_encryption" {
  source = "./rules/sqs_encryption_check"

  maximum_execution_frequency = var.default_execution_frequency
  exclude_accounts            = var.exclude_accounts

  input_parameters = jsonencode(
    {
      "QueueNameStartsWith" = null
    }
  )
}

module "sqs_encryption_west" {
  source = "./rules/sqs_encryption_check"

  maximum_execution_frequency = var.default_execution_frequency
  exclude_accounts            = var.exclude_accounts

  input_parameters = jsonencode(
    {
      "QueueNameStartsWith" = null
    }
  )

  providers = {
    aws = aws.west
  }
}


module "efs_encryption" {
  source = "./rules/efs_encryption_check"

  maximum_execution_frequency = "Twelve_Hours"
  exclude_accounts            = var.exclude_accounts

  input_parameters = jsonencode(
    {
      "KmsKeyId" = null
    }
  )
}

module "efs_encryption_west" {
  source = "./rules/efs_encryption_check"

  maximum_execution_frequency = "Twelve_Hours"
  exclude_accounts            = var.exclude_accounts

  input_parameters = jsonencode(
    {
      "KmsKeyId" = null
    }
  )

  providers = {
    aws = aws.west
  }
}
