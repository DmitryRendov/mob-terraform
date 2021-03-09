resource "aws_securityhub_account" "us_east_1" {
  count = local.security_hub_enabled ? 1 : 0
}

resource "aws_securityhub_standards_subscription" "cis_us_east_1" {
  count         = local.security_hub_enabled ? 1 : 0
  depends_on    = [aws_securityhub_account.us_east_1]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
}

resource "aws_securityhub_standards_subscription" "aws_foundational_us_east_1" {
  count         = local.security_hub_enabled ? 1 : 0
  depends_on    = [aws_securityhub_account.us_east_1]
  standards_arn = "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_securityhub_account" "us_west_2" {
  count    = local.security_hub_enabled ? 1 : 0
  provider = aws.west
}

resource "aws_securityhub_standards_subscription" "cis_us_west_2" {
  count         = local.security_hub_enabled ? 1 : 0
  depends_on    = [aws_securityhub_account.us_west_2]
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.2.0"
  provider      = aws.west
}

resource "aws_securityhub_standards_subscription" "aws_foundational_us_west_2" {
  count         = local.security_hub_enabled ? 1 : 0
  depends_on    = [aws_securityhub_account.us_west_2]
  standards_arn = "arn:aws:securityhub:us-west-2::standards/aws-foundational-security-best-practices/v/1.0.0"
  provider      = aws.west
}

resource "null_resource" "security_hub_delegation_us_east_1" {
  count = local.security_hub_enabled ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
aws securityhub update-organization-configuration --auto-enable --profile audit-super-user --region us-east-1
EOF
    environment = {
      ACCOUNT_ID = local.aws_account_id
      REGION     = "us-east-1"
    }
  }
}

resource "null_resource" "security_hub_delegation_us_west_2" {
  count = local.security_hub_enabled ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
aws securityhub update-organization-configuration --auto-enable --profile audit-super-user --region us-west-2
EOF
    environment = {
      ACCOUNT_ID = local.aws_account_id
      REGION     = "us-west-2"
    }
  }
}

resource "aws_securityhub_member" "us_east_1" {
  count      = local.security_hub_enabled ? 1 : 0
  account_id = "501055688096"
  email      = "drendov@gmail.com"
  invite     = true

  # The invite sometimes takes a few seconds to register before it can be accepted in the target account,
  # so we pause for 5 seconds to let the invite propagate
  provisioner "local-exec" {
    command = "python -c 'import time; time.sleep(5)'"
  }
}

resource "aws_securityhub_member" "us_west_2" {
  count      = local.security_hub_enabled ? 1 : 0
  provider   = aws.west
  account_id = "501055688096"
  email      = "drendov@gmail.com"
  invite     = true

  # The invite sometimes takes a few seconds to register before it can be accepted in the target account,
  # so we pause for 5 seconds to let the invite propagate
  provisioner "local-exec" {
    command = "python -c 'import time; time.sleep(5)'"
  }
}
