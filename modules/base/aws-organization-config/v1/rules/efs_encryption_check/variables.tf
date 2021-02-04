variable "input_parameters" {
  description = "A string in JSON format that is passed to the AWS Config Rule Lambda Function."
  default     = ""
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
