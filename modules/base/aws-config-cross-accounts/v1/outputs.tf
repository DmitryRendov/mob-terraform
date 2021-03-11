output "config_iam_role" {
  description = "The IAM role for ORG AWS Config"
  value       = aws_iam_role.config_lambda
}
