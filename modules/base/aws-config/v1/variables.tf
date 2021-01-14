variable "account_name" {}

variable "aws_account_id" {}

variable "aws_account_map" {
  description = "Map of all our AWS account IDs"
  type        = map(string)
}

variable "cr_s3_bucket" {}

variable "enabled" {
  default = true
}

variable "environment" {
  description = "Environment of resources (i.e. prod, staging)"
}

variable "role_name" {
  description = "Name of role to be used in resource naming"
}
