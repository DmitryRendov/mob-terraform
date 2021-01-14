resource "aws_config_configuration_recorder" "cr" {
  count    = local.count
  name     = "default"
  role_arn = aws_iam_role.awsconfig[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = true
  }
}

resource "aws_iam_role" "awsconfig" {
  count       = local.count
  name        = "${module.config_label.id}-role"
  description = "Role for AWS Config recorder to assume"

  assume_role_policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
                "Service": "config.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
POLICY

}

resource "aws_iam_role_policy_attachment" "AWSConfig" {
  count      = local.count
  role       = aws_iam_role.awsconfig[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "cr" {
  count          = local.count
  name           = "default"
  s3_bucket_name = var.cr_s3_bucket
  depends_on     = [aws_config_configuration_recorder.cr]

  snapshot_delivery_properties {
    delivery_frequency = local.cr_delivery_frequency
  }
}

resource "aws_config_configuration_recorder_status" "cr" {
  count      = local.count
  name       = aws_config_configuration_recorder.cr[0].name
  is_enabled = local.cr_is_enabled
  depends_on = [aws_config_delivery_channel.cr]
}

resource "aws_config_aggregate_authorization" "audit" {
  account_id = local.audit_account_id
  region     = data.aws_region.current.name
}
