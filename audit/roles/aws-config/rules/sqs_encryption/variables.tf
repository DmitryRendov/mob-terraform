variable "aws_account_ids" {
  type = list(string)
}
variable "aws_account_map" {
  description = "Map of all our AWS account IDs"
  type        = map(string)
}

variable "input_parameters" {
  description = "The parameters are passed to the AWS Config Rule Lambda Function in JSON format."
  default     = {}
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
