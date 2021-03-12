variable "name" {
  description = "Name of aws config rule"
}

variable "compliance_resource_types" {
  type        = list(string)
  description = "List of resources this rule applies to. See  https://docs.aws.amazon.com/config/latest/APIReference/API_ResourceIdentifier.html#config-Type-ResourceIdentifier-resourceType"
  default     = []
}

variable "alarm_actions" {
  type    = list(string)
  default = []
}

variable "aws_account_ids" {
  type = list(string)
}

variable "service_role_policy_arns" {
  type    = list(string)
  default = []
}
