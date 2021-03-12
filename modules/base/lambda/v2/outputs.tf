output "function" {
  description = "The Lambda function resource"
  value       = aws_lambda_function.default
}

output "role" {
  description = "The Lambda function IAM role resource (if created)"
  value       = local.iam_role_count == 1 ? aws_iam_role.default[0].arn : null
}

output "log_group" {
  description = "The Lambda Log Group resource"
  value       = aws_cloudwatch_log_group.group
}
