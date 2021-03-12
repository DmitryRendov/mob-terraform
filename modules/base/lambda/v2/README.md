# Create a Lambda function for all your serverless needs.

This Terraform module creates lambda function with CloudWatch alarm that monitors errors that occur in the lambda.

## Usage

### Lambda function deployed from a local source file, previously packed with TF archive_file

```hcl
module "redis_encryption" {
  source                   = "../../../modules/base/lambda/v1"
  environment              = local.env
  filename                 = data.archive_file.lambda_function.output_path
  handler                  = "lambda_function.lambda_handler"
  iam_role_policy_document = data.aws_iam_policy_document.redis_encryption_lambda.json
  role_name                = "account-defaults"
  runtime                  = "python3.8"
  source_code_hash         = data.archive_file.lambda_function.output_base64sha256
  timeout                  = "600"
  attach_vpc_config        = false
  attributes               = ["redis", "encryption", data.aws_region.current.name]
  description              = "Lambda for Custom Config Rule to check Redis compliance."
  variables = {
    "LOG_LEVEL" = "INFO"
  }
  providers = {
    aws = aws
  }
}
```

### Lambda function deployed from S3 bucket source

```hcl
module "authorizer" {
  source = "../../../modules/base/lambda/v1"

  environment = local.env
  role_name   = module.label.id
  handler     = "lambda_function.lambda_handler"
  runtime     = "nodejs10.x"
  timeout     = 30
  memory_size = 256

  s3_bucket = data.terraform_remote_state.s3_global.outputs.lambda_function_name
  s3_key    = "${terraform.workspace}/hs-lambda-authorizer/latest/authorizer.zip"

  attach_vpc_config = false
  source_code_hash  = data.aws_s3_bucket_object.authorizer_zip_hash.body

  variables = {
    ENV        = local.env
    ROLE       = local.role_name
  }

  iam_role_policy_document = data.aws_iam_policy_document.authorizer_policy.json
  description              = "Authorize a thing for great justice"
}

```

## History:

### v1:
- Upgrade null-label to v3 to fix lambda function name length issue
- Add required `description` parameter
- Add ARN and name of the Lambda Log Group to output
- Fix broken IAM role in case if the module is disabled
- feat: upgrade modules to terraform 0.12

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
