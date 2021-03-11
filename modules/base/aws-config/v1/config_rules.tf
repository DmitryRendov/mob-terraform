##
# To be migrated to ORG AWS Config
resource "aws_config_config_rule" "sns_encrypted_kms" {
  name        = "sns_encrypted_kms"
  description = "Checks whether Amazon SNS topic is encrypted with AWS Key Management Service (AWS KMS). The rule is NON_COMPLIANT if the Amazon SNS topic is not encrypted with AWS KMS."

  source {
    owner             = "AWS"
    source_identifier = "SNS_ENCRYPTED_KMS"
  }

  tags = module.sns_encrypted_kms_label.tags
}

##
# To be migrated to ORG AWS Config
resource "aws_config_config_rule" "sqs_encryption_check" {
  name        = "sqs_encryption_check"
  description = "Check whether SQS queue has encryption at rest enabled."

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = module.sqs_encryption.function_arn
    source_detail {
      maximum_execution_frequency = "TwentyFour_Hours"
      message_type                = "ScheduledNotification"
    }
  }

  input_parameters = jsonencode(
    {
      "QueueNameStartsWith" = null,
      "ExecutionRoleName"   = "audit-aws-config-cross-rule"
    }
  )

  tags = module.sqs_encryption_check_label.tags
}
