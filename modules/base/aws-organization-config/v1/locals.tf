locals {
  count = var.enabled ? 1 : 0

  # This module supports ORG and accout levels
  #org_only = var.enabled && var.account_name == "audit" ? 1 : 0

  # Record global resources only in one region
  record_global_resources = data.aws_region.current.name == "us-east-1" ? true : false

}
