resource "aws_config_configuration_recorder" "config_recorder" {
  count    = local.count
  name     = "default"
  role_arn = aws_iam_role.awsconfig[0].arn

  recording_group {
    all_supported                 = true
    include_global_resource_types = local.record_global_resources
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["config.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "awsconfig" {
  count       = local.count
  name        = "${module.config_label.id}-role"
  description = "Role for AWS Config recorder to assume"

  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "AWSConfig" {
  count      = local.count
  role       = aws_iam_role.awsconfig[0].id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_delivery_channel" "config_recorder" {
  count          = local.count
  name           = "default"
  s3_bucket_name = var.s3_bucket
  depends_on     = [aws_config_configuration_recorder.config_recorder]

  snapshot_delivery_properties {
    delivery_frequency = var.delivery_frequency
  }
}

resource "aws_config_configuration_recorder_status" "config_recorder" {
  count      = local.count
  name       = aws_config_configuration_recorder.config_recorder[0].name
  is_enabled = var.is_config_recorder_enabled
  depends_on = [aws_config_delivery_channel.config_recorder]
}
