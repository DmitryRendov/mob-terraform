# s3_bucket_encryption_lambda

A Terraform module to configure a custom AWS Config rule to ensure S3 Buckets have server side encryption enabled,
unless they are supposed to be public and properly tagged by the `audit:public_okay` tag.


## Information

* This Config rule should be deployed to every region you want to cover with Organization AWS Config service.
* Please note that global resources recording should be enabled only in one region (us-east-1) in order to avoid resource duplication.

## Rule Parameters:

None.

## Examples

Deploy a custom Config Rule with a overriden maximum execution frequency (Default is `TwentyFour_Hours`):
```
module "s3_bucket_encryption_custom" {
  source = "./rules/s3_bucket_encryption_custom"

  maximum_execution_frequency = "One_Hour"
  exclude_accounts            = []
}
```

Deploy a custom Config Rule to our second supported resgion us-east-1:
```
module "s3_bucket_encryption_custom_east" {
  source = "./rules/s3_bucket_encryption_custom"

  maximum_execution_frequency = "TwentyFour_Hours"
  exclude_accounts            = []

  providers = {
    aws = aws.east
  }
}
```


<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `exclude_accounts` |List of AWS account identifiers to exclude from the rules |list(string) | `[]` | no |
| `input_parameters` |A string in JSON format that is passed to the AWS Config Rule Lambda Function. | | `` | no |

Managed Resources
-----------------
* `aws_config_organization_custom_rule.s3_bucket_encryption_custom`
* `aws_lambda_permission.s3_bucket_encryption_custom_aws_config_rule`

Data Resources
--------------
* `data.archive_file.s3_bucket_encryption_custom`
* `data.aws_iam_policy_document.s3_bucket_encryption_custom_lambda`
* `data.aws_region.current`

Child Modules
-------------
* `s3_bucket_encryption_custom` from `../../../../../modules/site/lambda/v4`
<!-- END OF TERRAFORM-DOCS HOOK -->
