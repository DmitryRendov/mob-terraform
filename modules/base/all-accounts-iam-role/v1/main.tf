resource "aws_iam_role" "default_audit" {
  provider    = aws.audit
  name        = var.name
  description = var.description

  assume_role_policy = var.assume_role_policy_document
}

resource "aws_iam_role_policy_attachment" "aws_config_rule_audit" {
  provider   = aws.audit
  role       = aws_iam_role.default_audit.id
  policy_arn = var.policy_arn
}

resource "aws_iam_role" "default_bastion" {
  provider    = aws.bastion
  name        = var.name
  description = var.description

  assume_role_policy = var.assume_role_policy_document
}

resource "aws_iam_role_policy_attachment" "aws_config_rule_bastion" {
  provider   = aws.bastion
  role       = aws_iam_role.default_bastion.id
  policy_arn = var.policy_arn
}
