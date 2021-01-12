resource "aws_iam_group" "mob_user" {
  name = "mob_user"
}

resource "aws_iam_group_policy_attachment" "mob_user_force_mfa" {
  group      = aws_iam_group.mob_user.name
  policy_arn = aws_iam_policy.force_mfa.arn
}

resource "aws_iam_group" "ops" {
  name = "ops"
}

resource "aws_iam_group_membership" "ops" {
  name = "ops-group-membership"

  users = [
    module.dmitry_rendov.name
  ]

  group = aws_iam_group.ops.name
}

resource "aws_iam_group_policy_attachment" "ops_assumerole_all" {
  group      = aws_iam_group.ops.name
  policy_arn = aws_iam_policy.assumerole_all.arn
}

resource "aws_iam_group" "developers" {
  name = "developers"
}

resource "aws_iam_group_membership" "developers" {
  name = "developers-group-membership"

  users = [
    module.dmitry_rendov.name
  ]

  group = aws_iam_group.developers.name
}

resource "aws_iam_group_policy_attachment" "developers_assumerole_developers" {
  group      = aws_iam_group.developers.name
  policy_arn = aws_iam_policy.assumerole_developers.arn
}
