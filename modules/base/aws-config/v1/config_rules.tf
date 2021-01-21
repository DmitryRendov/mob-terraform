##
# Region-specific AWS Config rules only (deprecated)
#
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
