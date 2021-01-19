#!/bin/bash

##
## Logs you in or out of AWS by creating a session token and updating your AWS credentials file in place.
## We use Perl for calculating dates since BSD date and GNU date have almost zero common command line arguments.
##
## Requires: AWS CLI tools, jq, a bastion account user, and a 'sts' section in your ~/.aws/credentials file
##

if [[ $# != 1 ]]; then
    echo "usage: $0 <login|logout>"
    exit 1
fi

profile="bastion"
section="sts"

command="$1"
case $command in
    login)
        echo -n "Enter 2FA token: "
        read -s token
        echo

        #output=$(aws --output json --profile $profile sts get-session-token)
        output=$(aws --output json --profile $profile sts get-session-token --serial-number $(aws configure get $profile.mfa_serial) --token-code $token)

        access_key=$(echo "$output" | jq -r .Credentials.AccessKeyId)
        secret_access_key=$(echo "$output" | jq -r .Credentials.SecretAccessKey)
        session_token=$(echo "$output" | jq -r .Credentials.SessionToken)

        aws configure set profile.$section.aws_access_key_id $access_key
        aws configure set profile.$section.aws_secret_access_key $secret_access_key
        aws configure set profile.$section.aws_session_token $session_token
        expiration=$(perl -e 'print time + (60*60*12-200)') # Our IAM policies require MFA every 12 hours. Fudge downward a bit.
        aws configure set profile.$section.terraform_sts_expiration $expiration

        expiration_iso8601=$(perl -e "use POSIX qw(strftime); print strftime '%Y-%m-%d %R %Z', localtime($expiration)")
        echo "Your session will expire in 12 hours at ${expiration_iso8601}."

        ;;

    logout)
        aws configure set profile.$section.aws_access_key_id blank
        aws configure set profile.$section.aws_secret_access_key blank
        aws configure set profile.$section.aws_session_token blank
        aws configure set profile.$section.terraform_sts_expiration $(date +%s)
        rm -f "$HOME/.aws/cli/cache/"*
        ;;

    *)
        echo "choose 'login' or 'logout'"
        exit 1
        ;;
esac
