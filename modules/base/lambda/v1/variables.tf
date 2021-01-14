variable "environment" {
}

variable "role_name" {
}

variable "attributes" {
  type    = list(string)
  default = []
}

variable "filename" {
  description = "The path to the function's deployment package within the local filesystem. If defined, The s3_-prefixed options cannot be used."
  default     = null
}

variable "handler" {
  description = "The function entrypoint in your code."
}

variable "source_code_hash" {
  description = "Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3_key."
  default     = ""
}

variable "runtime" {
  description = "The runtime environment for the Lambda function you are uploading"
}

variable "iam_role_arn" {
  description = "IAM role arn to use instead of making one"
  default     = ""
}

variable "iam_role_policy_document" {
  description = "Policy for IAM role"
  default     = "{}"
}

variable "memory_size" {
  description = "The memory size, in MB, you configured for the function. Must be a multiple of 64 MB."
  default     = 512
}

variable "s3_bucket" {
  description = "Amazon S3 bucket name where the .zip file containing your deployment package is stored"
  default     = null
}

variable "s3_key" {
  description = "The Amazon S3 object (the deployment package) key name you want to upload"
  default     = null
}

variable "s3_object_version" {
  description = "The Amazon S3 object (the deployment package) version you want to upload"
  default     = null
}

variable "attach_vpc_config" {
  description = "Set this to true if using the vpc_config variable"
  type        = bool
  default     = true
}

variable "timeout" {
  description = "Timeout for lambda function"
  default     = 10
}

variable "security_group_ids" {
  description = "When using lambda within VPC"
  type        = list(string)
  default     = []
}

variable "subnet_ids" {
  description = "When using lambda within VPC"
  type        = list(string)
  default     = []
}
variable "kms_key_arn" {
  description = "KMS key to encrypt environment variables at rest"
  default     = ""
}

variable "log_retention" {
  description = "Maximum days of log retention for the lambda function log group"
  default     = 30
}

variable "variables" {
  description = "Environment variables for lambda function"
  default     = {}
  type        = map(string)
}

variable "alarm_enabled" {
  description = "Create the Cloudwatch Alarm or not"
  default     = "true"
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

variable "enabled" {
  description = "Set to false and no resources will be created"
  type        = bool
  default     = true
}

variable "description" {
  description = "Description of what your Lambda Function does."
}
