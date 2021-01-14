add-account-%:
	@sed 's/{{NAME}}/$*/' new_account_template.tpl >> main.tf
	@sed 's/{{NAME}}/$*/' new_account_provider_template.tpl >> providers.tf
