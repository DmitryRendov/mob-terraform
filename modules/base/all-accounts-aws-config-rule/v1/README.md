<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

## Inputs
| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| `alarm_actions` | |list(string) | `[]` | no |
| `aws_account_ids` | |list(string) | `<nil>` | no |
| `compliance_resource_types` |List of resources this rule applies to. See  https://docs.aws.amazon.com/config/latest/APIReference/API_ResourceIdentifier.html#config-Type-ResourceIdentifier-resourceType |list(string) | `[]` | no |
| `name` |Name of aws config rule | | `<nil>` | no |
| `service_role_policy_arns` | |list(string) | `[]` | no |

Managed Resources
-----------------
* `aws_cloudwatch_metric_alarm.error_alarm`
* `aws_config_config_rule.aws_config_rule_alpha`
* `aws_config_config_rule.aws_config_rule_audit`
* `aws_config_config_rule.aws_config_rule_bastion`
* `aws_config_config_rule.aws_config_rule_data_dev`
* `aws_config_config_rule.aws_config_rule_data_prod`
* `aws_config_config_rule.aws_config_rule_databricks_prod`
* `aws_config_config_rule.aws_config_rule_databricks_staging`
* `aws_config_config_rule.aws_config_rule_headspace_integration`
* `aws_config_config_rule.aws_config_rule_headspace_prod`
* `aws_config_config_rule.aws_config_rule_headspace_skill`
* `aws_config_config_rule.aws_config_rule_it`
* `aws_config_config_rule.aws_config_rule_logging`
* `aws_config_config_rule.aws_config_rule_ops`
* `aws_iam_policy.default`
* `aws_iam_role.aws_config_rule_alpha`
* `aws_iam_role.aws_config_rule_audit`
* `aws_iam_role.aws_config_rule_bastion`
* `aws_iam_role.aws_config_rule_data_dev`
* `aws_iam_role.aws_config_rule_data_prod`
* `aws_iam_role.aws_config_rule_databricks_prod`
* `aws_iam_role.aws_config_rule_databricks_staging`
* `aws_iam_role.aws_config_rule_headspace_integration`
* `aws_iam_role.aws_config_rule_headspace_prod`
* `aws_iam_role.aws_config_rule_headspace_skill`
* `aws_iam_role.aws_config_rule_it`
* `aws_iam_role.aws_config_rule_logging`
* `aws_iam_role.aws_config_rule_ops`
* `aws_iam_role.config_lambda`
* `aws_iam_role_policy_attachment.alpha`
* `aws_iam_role_policy_attachment.audit`
* `aws_iam_role_policy_attachment.bastion`
* `aws_iam_role_policy_attachment.cloudwatch_logs`
* `aws_iam_role_policy_attachment.data_prod`
* `aws_iam_role_policy_attachment.data_staging`
* `aws_iam_role_policy_attachment.databricks_prod`
* `aws_iam_role_policy_attachment.databricks_staging`
* `aws_iam_role_policy_attachment.default`
* `aws_iam_role_policy_attachment.headspace_integration`
* `aws_iam_role_policy_attachment.headspace_prod`
* `aws_iam_role_policy_attachment.headspace_skill`
* `aws_iam_role_policy_attachment.it`
* `aws_iam_role_policy_attachment.logging`
* `aws_iam_role_policy_attachment.ops`
* `aws_lambda_function.default`
* `aws_lambda_permission.allow_cross_account`

Data Resources
--------------
* `data.aws_iam_policy_document.assume_role_policy`
* `data.aws_iam_policy_document.default`
* `data.aws_iam_policy_document.lambda_assume_role_policy`

Child Modules
-------------
* `alarm_label` from `../../../../modules/base/null-label/v2`
* `label` from `../../../../modules/base/null-label/v2`
* `lambda_label` from `../../../../modules/base/null-label/v2`
<!-- END OF TERRAFORM-DOCS HOOK -->
