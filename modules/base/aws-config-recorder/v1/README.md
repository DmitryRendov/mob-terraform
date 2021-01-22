# aws-config-recorder

A Terraform module to configure AWS Config service in our AWS accounts and enable config item recorder.

## Note

* Please, enable global resources recording only in one region in the account (e.g. us-east-1) in order to avoid resource duplication

## Examples

An example AWS Config enabled in us-east-1 region with enabled global resource recording:
```
module "aws_config_recorder_east" {
  source      = "../../../modules/base/aws-config-recorder/v1"
  environment = terraform.workspace
  role_name   = local.role_name

  record_global_resources = data.aws_region.current.name == "us-east-1" ? true : false
  delivery_frequency      = "TwentyFour_Hours"
  s3_bucket               = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  # Here, you can specify what exactly region AWS Config service should be enabled in
  providers = {
    aws = aws.east
  }
}
```

## History

### v1
- Initial release

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
