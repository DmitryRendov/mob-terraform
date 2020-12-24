TF_ROOT := $(shell git rev-parse --show-toplevel)
TF := $(TF_ROOT)/tf

include lib/common.makefile

## Create a bare bones account from the account_template for named account which must be in global aws_account_map
new-account-%:
	@mkdir $*
	@rsync --exclude="*template" -a ./lib/account_template/ ./$*
	@cd $* && ${TF_ROOT}/lib/tools/account_variables_renderer $*

	@echo "Now cd $*/global/core, 'make init', and run 'make new-workspace-%' (if needed) for the workspaces relevant to your account.  Import the super-user role and role attachment resources and 'make apply'"
	@echo "Then cd $*/global/global and run 'make new-workspace-%' (if needed) for the workspaces relevant to your account."
	@echo "Then 'git add $*', then commit and create a PR."

remove-unused-modules:
	@find modules -type d -name 'v*' | grep -v examples | grep -v openvpn | xargs -L 1 -I {} bash -c "git grep -q {} || echo {}" | xargs git rm -r

# Input: modules/site/alb/v2
# Output: mv modules/site/alb/v2 modules/site/v3, find all instances of modules/site/alb/v2 and replace with v3
## Increment version of module and replace all instances with new version
upgrade-module:
	@lib/tools/upgrade-module $(MODULE)

## Setup tools used for development
setup:
	@which go || (echo "Setup go using this doc: https://golang.org/doc/install and run this script again" && exit 1)
	@which pip3 || dnf install pip3
	@pip3 install --user -U -r $(TF_ROOT)/terraform/lib/requirements.txt
	@which pre-commit || pip3 install pre-commit && pre-commit install
	@GO111MODULE="on" go get -u github.com/hashicorp/terraform-config-inspect
	@which terraform-config-inspect || (echo "Please ensure your GOPATH is setup and it is in your PATH" && exit 1)
