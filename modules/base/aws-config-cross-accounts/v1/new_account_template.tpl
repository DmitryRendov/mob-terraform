# All of our AWS Config Rule lambdas live in the Audit account. This role is to allow the lambda in the Audit account to report back the results in the account the rule is created in.
resource "aws_iam_role" "aws_config_rule_{{NAME}}" {
  provider    = "aws.{{NAME}}"
  name        = "${module.label.id}"
  description = "Role for AWS Config Rules"

  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}

resource "aws_iam_role_policy_attachment" "aws_config_rule_{{NAME}}" {
  provider   = "aws.{{NAME}}"
  role       = "${aws_iam_role.aws_config_rule_{{NAME}}.id}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"
}

resource "aws_config_config_rule" "aws_config_rule_{{NAME}}" {
  provider = "aws.{{NAME}}"
  name     = "${var.name}"

  # The input parameter gets passed into the lambda in the rule_parameters dict
  input_parameters = "${jsonencode(map("execution_role","${aws_iam_role.aws_config_rule_{{NAME}}.arn}"))}"

  scope {
    compliance_resource_types = ["${var.compliance_resource_types}"]
  }

  source {
    owner             = "CUSTOM_LAMBDA"
    source_identifier = "${aws_lambda_function.default.arn}"

    source_detail {
      message_type = "ConfigurationItemChangeNotification"
    }

    source_detail {
      message_type = "OversizedConfigurationItemChangeNotification"
    }
  }
}
