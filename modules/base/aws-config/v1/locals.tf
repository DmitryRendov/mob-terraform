locals {
  count           = var.enabled ? 1 : 0
  count_east_only = var.enabled && data.aws_region.current.name == "us-east-1" ? 1 : 0

  # Audit account id for AWS Config aggregation
  audit_account_id = var.aws_account_map.audit

  sqs_encryption_lambda_filename = "${path.module}/files/sqs_encryption_check.zip"

}
