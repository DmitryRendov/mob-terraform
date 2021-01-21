variable "aws_account_map" {
  description = "Map of all our AWS account IDs"
  type        = map(string)
}

variable "delivery_frequency" {
  default     = "One_Hour"
  description = "The frequency with which AWS Config delivers configuration snapshots."
}

variable "enabled" {
  default = true
}

variable "environment" {
  description = "Environment of resources (i.e. prod, staging)"
}

variable "is_enabled" {
  default     = true
  description = "Is Config Recorder enabled?"
}

variable "role_name" {
  description = "Name of role to be used in resource naming"
}

variable "s3_bucket" {}
