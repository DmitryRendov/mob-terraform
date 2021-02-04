##
# ORG AWS Config rules
#
resource "aws_config_organization_managed_rule" "sns_encrypted_kms" {
  name            = "sns_encrypted_kms"
  rule_identifier = "SNS_ENCRYPTED_KMS"

  description = "Checks whether Amazon SNS topic is encrypted with AWS Key Management Service (AWS KMS). The rule is NON_COMPLIANT if the Amazon SNS topic is not encrypted with AWS KMS."

  excluded_accounts = var.exclude_accounts
}

resource "aws_config_organization_managed_rule" "sns_encrypted_kms_west" {
  provider        = aws.west
  name            = "sns_encrypted_kms"
  rule_identifier = "SNS_ENCRYPTED_KMS"

  description = "Checks whether Amazon SNS topic is encrypted with AWS Key Management Service (AWS KMS). The rule is NON_COMPLIANT if the Amazon SNS topic is not encrypted with AWS KMS."

  excluded_accounts = var.exclude_accounts
}


# Applicable only in us-east-1 region
resource "aws_config_organization_managed_rule" "cloudfront_associated_with_waf" {
  name            = "cloudfront_associated_with_waf"
  rule_identifier = "CLOUDFRONT_ASSOCIATED_WITH_WAF"

  description = "Checks if Amazon CloudFront distributions are associated with either AWS WAF or WAFv2 web access control lists (ACLs). This rule is COMPLIANT if the CloudFront distribution is associated with a web ACL."

  excluded_accounts = var.exclude_accounts
}
