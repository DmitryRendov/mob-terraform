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

variable "is_config_recorder_enabled" {
  default     = true
  description = "Is Config Recorder enabled?"
}

variable "role_name" {
  description = "Name of role to be used in resource naming"
}

variable "s3_bucket" {}

variable "record_global_resources" {
  default     = true
  description = "Record global resources or not (eg. IAM, CloudFront, etc.)"
}
