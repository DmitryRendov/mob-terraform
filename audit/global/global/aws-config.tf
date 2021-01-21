resource "aws_s3_bucket" "aws_config" {
  bucket = module.aws_config_label.id
  acl    = "private"

  tags = module.aws_config_label.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id                                     = "transition-to-S3-IAS-after-30-days"
    prefix                                 = "" # whole bucket
    enabled                                = true
    abort_incomplete_multipart_upload_days = 7

    transition {
      days          = 30
      storage_class = "ONEZONE_IA"
    }

    expiration {
      days = 60
    }
  }
}

data "aws_iam_policy_document" "aws_config" {
  statement {
    sid = "AWSConfigBucketPermissionsCheck"

    actions = [
      "s3:GetBucketAcl",
    ]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    resources = [
      aws_s3_bucket.aws_config.arn,
    ]
  }

  statement {
    sid = "AWSConfigBucketDelivery"

    actions = [
      "s3:PutObject",
    ]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }

    resources = formatlist(
      "arn:aws:s3:::${aws_s3_bucket.aws_config.id}/AWSLogs/%s/Config/*",
      sort(values(var.aws_account_map)),
    )
  }
}

resource "aws_s3_bucket_policy" "aws_config" {
  bucket = aws_s3_bucket.aws_config.id
  policy = data.aws_iam_policy_document.aws_config.json
}

resource "aws_s3_bucket_public_access_block" "aws_config_block" {
  bucket = aws_s3_bucket.aws_config.id

  block_public_acls       = "true"
  ignore_public_acls      = "true"
  block_public_policy     = "true"
  restrict_public_buckets = "true"
}

module "aws_config_recorder" {
  source          = "../../../modules/base/aws-config-recorder/v1"
  aws_account_map = var.aws_account_map
  role_name       = var.account_name
  environment     = terraform.workspace

  # Config Recorder settings
  is_enabled         = local.config_recorder_enabled
  delivery_frequency = local.config_recorder_delivery_frequency
  s3_bucket          = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws
  }
}

module "aws_config_recorder_west" {
  source          = "../../../modules/base/aws-config-recorder/v1"
  aws_account_map = var.aws_account_map
  role_name       = var.account_name
  environment     = terraform.workspace

  # Config Recorder settings
  is_enabled         = local.config_recorder_enabled
  delivery_frequency = local.config_recorder_delivery_frequency
  s3_bucket          = data.terraform_remote_state.audit.outputs.aws_config_bucket.id

  providers = {
    aws = aws.west
  }
}
