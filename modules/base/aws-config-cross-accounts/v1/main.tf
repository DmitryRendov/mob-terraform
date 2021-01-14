data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.config_lambda.arn]
    }
  }
}

# All of our AWS Config Rule lambdas live in the Audit account. This role is to allow the lambda in the Audit account to report back the results in the account the rule is created in.
resource "aws_iam_role" "aws_config_rule_audit" {
  provider    = aws.audit
  name        = module.label.id
  description = "Role for AWS Config Rules"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "audit" {
  count      = length(var.service_role_policy_arns)
  provider   = aws.audit
  role       = aws_iam_role.aws_config_rule_audit.id
  policy_arn = element(var.service_role_policy_arns, count.index)
}

resource "aws_config_config_rule" "aws_config_rule_audit" {
  provider = aws.audit
  name     = var.name

  # The input parameter gets passed into the lambda in the rule_parameters dict
  input_parameters = jsonencode(
    {
      "execution_role" = aws_iam_role.aws_config_rule_audit.arn
    },
  )

  scope {
    compliance_resource_types = var.compliance_resource_types
  }

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.default.arn

    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }

    source_detail {
      message_type = "OversizedConfigurationItemChangeNotification"
    }
  }
}

# All of our AWS Config Rule lambdas live in the Audit account. This role is to allow the lambda in the Audit account to report back the results in the account the rule is created in.
resource "aws_iam_role" "aws_config_rule_bastion" {
  provider    = aws.bastion
  name        = module.label.id
  description = "Role for AWS Config Rules"

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
}
resource "aws_iam_role_policy_attachment" "bastion" {
  count      = length(var.service_role_policy_arns)
  provider   = aws.bastion
  role       = aws_iam_role.aws_config_rule_bastion.id
  policy_arn = element(var.service_role_policy_arns, count.index)
}

resource "aws_config_config_rule" "aws_config_rule_bastion" {
  provider = aws.bastion
  name     = var.name

  # The input parameter gets passed into the lambda in the rule_parameters dict
  input_parameters = jsonencode(
    {
      "execution_role" = aws_iam_role.aws_config_rule_bastion.arn
    },
  )

  scope {
    compliance_resource_types = var.compliance_resource_types
  }

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = aws_lambda_function.default.arn

    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }

    source_detail {
      message_type = "OversizedConfigurationItemChangeNotification"
    }
  }
}
