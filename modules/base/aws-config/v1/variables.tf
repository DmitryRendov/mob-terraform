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

variable "cr_is_enabled" {
  default     = true
  description = "Is Config Recorder enabled?"
}

variable "cr_delivery_frequency" {
  default     = "One_Hour"
  description = "The frequency with which AWS Config delivers configuration snapshots."
}
