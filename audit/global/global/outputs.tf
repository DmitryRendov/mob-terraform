output "aws_config_bucket" {
  value       = aws_s3_bucket.aws_config
  description = "S3 bucket for AWS config"
}
