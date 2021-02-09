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
