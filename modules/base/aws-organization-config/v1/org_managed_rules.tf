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

resource "aws_config_organization_managed_rule" "s3_bucket_public_read_prohibited" {
  name            = "s3_bucket_public_read_prohibited"
  rule_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"

  description = "Checks that your Amazon S3 buckets do not allow public read access. The rule checks the Block Public Access settings, the bucket policy, and the bucket access control list (ACL)."

  excluded_accounts = var.exclude_accounts
}

resource "aws_config_organization_managed_rule" "s3_bucket_public_read_prohibited_west" {
  provider        = aws.west
  name            = "s3_bucket_public_read_prohibited"
  rule_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"

  description = "Checks that your Amazon S3 buckets do not allow public read access. The rule checks the Block Public Access settings, the bucket policy, and the bucket access control list (ACL)."

  excluded_accounts = var.exclude_accounts
}
