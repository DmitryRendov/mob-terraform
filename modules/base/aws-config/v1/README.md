# aws-config (DEPRECATED)

A Terraform module to enable AWS Config service in our AWS accounts.

## Note

* You can specify what exactly region AWS Config service should be enabled in by setting an appropriate TF provider alias

## Rules

### SNS

* sns_encrypted_kms: Checks whether Amazon SNS topic is encrypted with AWS Key Management Service (AWS KMS). The rule is NON_COMPLIANT if the Amazon SNS topic is not encrypted with AWS KMS.

### SQS

* sqs_encryption_check: Check whether SQS queue has encryption at rest enabled.

## Examples

An example AWS Config enabled in us-east-1 region:
```
module "aws_config_east" {
  source          = "../../../modules/base/aws-config/v1"
  aws_account_map = var.aws_account_map
  environment     = local.env
  account_name    = var.account_name

  # Here, you can specify what exactly region AWS Config service should be enabled in
  providers = {
    aws = aws.east
  }
}
```

## History

### v1
- Initial release with basic checks

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
