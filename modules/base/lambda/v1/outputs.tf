output "function_arn" {
  description = "The ARN of the Lambda function"
  value       = join("", aws_lambda_function.default.*.arn)
}

output "function_name" {
  description = "The name of the Lambda function"
  value       = join("", aws_lambda_function.default.*.function_name)
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = join("", aws_iam_role.default.*.arn)
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = join("", aws_iam_role.default.*.name)
}

output "function_invoke_arn" {
  description = "The ARN to be used for invoking Lambda Function from API Gateway"
  value       = join("", aws_lambda_function.default.*.invoke_arn)
}

output "log_group_arn" {
  description = "The ARN of the Lambda Log Group"
  value       = join("", aws_cloudwatch_log_group.group.*.arn)
}

output "log_group_name" {
  description = "The name of the Lambda Log Group"
  value       = join("", aws_cloudwatch_log_group.group.*.name)
}
