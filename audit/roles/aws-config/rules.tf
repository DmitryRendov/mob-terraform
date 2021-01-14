module "s3_bucket_encryption" {
  source                    = "../../../modules/base/aws-config-cross-accounts/v1"
  name                      = "s3_bucket_encryption"
  compliance_resource_types = ["AWS::S3::Bucket"]
  aws_account_ids           = distinct(values(var.aws_account_map))

  // TODO: send this to somewhere that alarms, maybe the prod account, instead of an email to ops
  alarm_actions = []

  service_role_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole",
  ]

  providers = {
    aws.audit   = aws.audit
    aws.bastion = aws.bastion
  }
}
