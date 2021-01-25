variable "environment" {
  description = "Environment of resources (i.e. prod, staging)"
  default     = "default"
}

variable "exclude_accounts" {
  description = "List of AWS account identifiers to exclude from the rules"
  default     = []
  type        = list(string)
}

variable "maximum_execution_frequency" {
  default     = "TwentyFour_Hours"
  description = "The maximum frequency with which AWS Config runs evaluations for a rule."
}
