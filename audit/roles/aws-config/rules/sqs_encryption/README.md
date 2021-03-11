# redis_encryption

A Terraform module to deploy a custom AWS Config rule to check whether SQS queue has encryption at rest enabled..

## Information

* This Config rule should be deployed to every region you want to cover with Organization AWS Config service.
* Please note that global resources recording should be enabled only in one region (us-east-1) in order to avoid resource duplication.

## Accepted parameters

* QueueNameStartsWith - (Optional) Specify your SQS queue names to check for. Starting SQS queue names will suffice. For example, your SQS queue names are "processimages" and "extractdocs".

## Examples

Deploy a custom Config Rule with a overriden maximum execution frequency (Default is `TwentyFour_Hours`):
```
module "sqs_encryption" {
  source = "./rules/redis_encryption"

  maximum_execution_frequency = "One_Hour"
  exclude_accounts            = []

  input_parameters = jsonencode(
    {
      "QueueNameStartsWith" = null
    }
  )
}
```

Deploy a custom Config Rule to our second supported resgion us-east-1:
```
module "sqs_encryption_east" {
  source = "./rules/redis_encryption"

  maximum_execution_frequency = "TwentyFour_Hours"
  exclude_accounts            = []

  input_parameters = jsonencode(
    {
      "QueueNameStartsWith" = null
    }
  )

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
| `maximum_execution_frequency` |The maximum frequency with which AWS Config runs evaluations for a rule. | | `TwentyFour_Hours` | no |

Managed Resources
-----------------
* `aws_config_organization_custom_rule.sqs_encryption`
* `aws_lambda_permission.lambda_permission`

Data Resources
--------------
* `data.archive_file.sqs_encryption`
* `data.aws_iam_policy_document.sqs_encryption_lambda`
* `data.aws_region.current`

Child Modules
-------------
* `sqs_encryption` from `../../../../../modules/site/lambda/v4`
<!-- END OF TERRAFORM-DOCS HOOK -->
