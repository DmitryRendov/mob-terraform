module "aws_config_cross" {
  source                    = "../../../modules/base/aws-config-cross-accounts/v1"
  name                      = "cross"
  compliance_resource_types = ["AWS::S3::Bucket"]
  aws_account_ids           = distinct(values(var.aws_account_map))

  alarm_actions = []

  service_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole",
  ]

  providers = {
    aws.audit   = aws.audit
    aws.bastion = aws.bastion
  }
}

output "config_iam_role" {
  description = "The IAM role for ORG AWS Config"
  value       = module.aws_config_cross.config_iam_role
}
