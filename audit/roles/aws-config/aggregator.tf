resource "aws_config_configuration_aggregator" "organization" {
  count      = local.config_enabled ? 1 : 0
  depends_on = [aws_iam_role_policy_attachment.organization]

  name = "all-org"

  organization_aggregation_source {
    regions  = local.aggregator_source_regions
    role_arn = aws_iam_role.organization[0].arn
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"

      identifiers = [
        "config.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "organization" {
  count              = local.config_enabled ? 1 : 0
  name               = module.aggregator_role_label.id
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "organization" {
  count      = local.config_enabled ? 1 : 0
  role       = aws_iam_role.organization[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSConfigRoleForOrganizations"
}
