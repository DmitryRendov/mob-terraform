variable "enabled" {
  default = true
}

variable "environment" {
  description = "Environment of resources (i.e. prod, staging)"
}

variable "exclude_accounts" {
  description = "List of AWS account identifiers to exclude from the rules"
  type        = list(string)
  default     = []
}

variable "role_name" {
  description = "Name of role to be used in resource naming"
}

variable "alarm_actions" {
  type    = list(string)
  default = []
}

variable "default_execution_frequency" {
  default     = "TwentyFour_Hours"
  description = "Default maximum frequency with which AWS Config runs evaluations for a rule."
}
