### Information
**ROLE MUST BE RUN USING TERRAFORM EXEC ROLE SUPER USER**

Changing Account Name or Email via Terraform requires the account be deleted and recreated,
**DO NOT DO THIS**.

Also, please keep in mind that newly created AWS account might be deleted only after you finish sign-up steps

Make changes in Terraform and then login to the account with root credentials and change
the settings to match the desired state.

Running this if there are changes you that cause a repo to be deleted and recreated the plan will fail. To execute
the plan delete the prevent_destroy lifecycle rule in the module.

<!-- BEGINNING OF TERRAFORM-DOCS HOOK -->

<!-- END OF TERRAFORM-DOCS HOOK -->
