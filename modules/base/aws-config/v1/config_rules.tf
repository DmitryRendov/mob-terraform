resource "aws_config_config_rule" "iam_access_key_rotation" {
  count       = local.count
  name        = "iam_access_key_rotation"
  description = "Checks whether the active access keys are rotated within the number of days specified in maxAccessKeyAge. The rule is non-compliant if the access keys have not been rotated for more than maxAccessKeyAge number of days."
  input_parameters = jsonencode(
    {
      maxAccessKeyAge = "90"
    }
  )
  maximum_execution_frequency = "TwentyFour_Hours"

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  depends_on = [aws_config_configuration_recorder.cr]
}

resource "aws_config_config_rule" "sqs_encryption_check" {
  count       = local.count
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
      "QueueNameStartsWith" = null
    }
  )

  tags       = module.sqs_encryption_check_label.tags
  depends_on = [aws_config_configuration_recorder.cr]
}
