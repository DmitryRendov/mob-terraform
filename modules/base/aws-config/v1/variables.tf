variable "aws_account_map" {
  description = "Map of all our AWS account IDs"
  type        = map(string)
}

variable "environment" {
  description = "Environment of resources (i.e. prod, staging)"
}

variable "role_name" {
  description = "Name of role to be used in resource naming"
}
