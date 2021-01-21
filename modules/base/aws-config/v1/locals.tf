locals {
  count = var.enabled ? 1 : 0

  # This module supports ORG and accout levels
  org_only = var.enabled && var.account_name == "audit" ? 1 : 0

  # Record global resources only in one region
  record_global_resources = data.aws_region.current.name == "us-east-1" ? true : false

  # Audit account id for AWS Config aggregation
  audit_account_id = var.aws_account_map.audit

  sqs_encryption_lambda_filename = "${path.module}/files/sqs_encryption_check.zip"
}
