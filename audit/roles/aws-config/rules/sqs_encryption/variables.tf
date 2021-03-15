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

variable "alarm_enabled" {
  description = "Create the Cloudwatch Alarm or not"
  default     = true
  type        = bool
}

variable "alarm_actions" {
  description = "Actions to take if there are errors in the lambda function"
  default     = []
  type        = list(string)
}

variable "alarm_period" {
  description = "The period in seconds over which the alarm statistic is applied"
  default     = "86400" # 24 * 60 * 60"
}

variable "alarm_evaluation_periods" {
  description = "The number of periods over which data is compared to the specified alarm threshold"
  default     = "1"
}

variable "alarm_threshold" {
  description = "The value against which the specified statistic is compared."
  default     = "1"
}

variable "treat_missing_data" {
  description = "Sets how to handle missing data points"
  default     = "missing"
}

variable "log_retention" {
  description = "Maximum days of log retention for the lambda function log group"
  default     = 30
}
