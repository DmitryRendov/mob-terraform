## User role

This module is used to create user roles across our various AWS accounts.
For each account, must pass in a list of policy ARNs to attach to the user role in that account.
Additionally, a list of teams can be provided, and access to various resources in each account may be gated by matching team parameters. For example, decoding of SSM Parameter Store secrets requires a matching `team` tag between the Parameter and the role attempting to decode it.

### v1

Initial role


<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
