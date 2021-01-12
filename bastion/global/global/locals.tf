locals {
  role_name = "global"
  team      = "ops"

  developer_policies = {
    headspace_prod_policy_arns = [
      "arn:aws:iam::aws:policy/AWSSupportAccess",
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
      #aws_iam_policy.developer_permissions.arn,
      #aws_iam_policy.restrict_destructive_actions.arn,
    ]
  }

  security_team_policies = {
    headspace_prod_policy_arns = [
      "arn:aws:iam::aws:policy/AWSSupportAccess",
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
      #aws_iam_policy.deny_s3_archives.arn,
    ]
  }

}
