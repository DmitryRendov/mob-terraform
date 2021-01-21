variable "aws_account_map" {
  description = "Map of all our AWS account IDs"
  type        = map(string)
}

variable "enabled" {
  default = true
}

variable "environment" {
  description = "Environment of resources (i.e. prod, staging)"
}

variable "exclude_accounts" {
  description = "List of AWS account identifiers to exclude from the rules"
  type        = list(string)
}

variable "role_name" {
  description = "Name of role to be used in resource naming"
}
