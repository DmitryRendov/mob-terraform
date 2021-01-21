##
# ORG AWS Config rules
#
resource "aws_config_organization_managed_rule" "sns_encrypted_kms" {
  name            = "sns_encrypted_kms"
  rule_identifier = "SNS_ENCRYPTED_KMS"

  description = "Checks whether Amazon SNS topic is encrypted with AWS Key Management Service (AWS KMS). The rule is NON_COMPLIANT if the Amazon SNS topic is not encrypted with AWS KMS."

  excluded_accounts = var.exclude_accounts
}

output "sns_encrypted_kms" {
  value = aws_config_organization_managed_rule.sns_encrypted_kms
}
