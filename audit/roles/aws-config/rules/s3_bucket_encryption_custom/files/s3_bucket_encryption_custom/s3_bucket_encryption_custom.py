"""Ensures S3 Buckets have server side encryption enabled"""
# Forked from: https://github.com/awslabs/aws-config-rules/blob/master/python/s3_bucket_default_encryption_enabled.py
#
# Trigger Type: Change Triggered
# Scope of Changes: S3:Bucket
# Accepted Parameters: None
# Your Lambda function execution role will need to have a policy that provides
# the appropriate permissions. Here is a policy that you can consider.
# You should validate this for your own environment.
#
# Optional Parameters:
# 1. Key: SSE_OR_KMS
#    Values: SSE, KMS
# 2. Key: KMS_ARN
#    Value: ARN of the KMS key
#
# NOTE: If you specify KMS_ARN, you must choose KMS for SSE_OR_KMS.
#
# {
#    "Version": "2012-10-17",
#    "Statement": [
#        {
#            "Effect": "Allow",
#            "Action": [
#                "logs:CreateLogGroup",
#                "logs:CreateLogStream",
#                "logs:PutLogEvents"
#            ],
#            "Resource": "arn:aws:logs:*:*:*"
#        },
#        {
#            "Effect": "Allow",
#            "Action": [
#                "config:PutEvaluations"
#            ],
#            "Resource": "*"
#        },
#        {
#            "Effect": "Allow",
#            "Action": [
#                "s3:GetEncryptionConfiguration"
#            ],
#            "Resource": "arn:aws:s3:::*"
#        }
#    ]
# }


import json
import boto3


##############
# Parameters #
##############

# Set to True to get the lambda to assume the Role attached on the Config Service (useful for cross-account).
ASSUME_ROLE_MODE = True

# Other parameters (no change needed)
CONFIG_ROLE_TIMEOUT_SECONDS = 900

APPLICABLE_RESOURCES = ["AWS::S3::Bucket"]


def evaluate_compliance(configuration_item, rule_parameters, s3Client):
    """Evaluate complience for each item"""

    # Start as non-compliant
    compliance_type = 'NON_COMPLIANT'
    annotation = "S3 bucket either does NOT have default encryption enabled, " \
                 + "has the wrong TYPE of encryption enabled, or is encrypted " \
                 + "with the wrong KMS key."

    # Check if resource was deleted
    if configuration_item['configurationItemStatus'] == "ResourceDeleted":
        compliance_type = 'NOT_APPLICABLE'
        annotation = "The resource was deleted."

    # Check resource for applicability
    elif configuration_item["resourceType"] not in APPLICABLE_RESOURCES:
        compliance_type = 'NOT_APPLICABLE'
        annotation = "The rule doesn't apply to resources of type " \
                     + configuration_item["resourceType"] + "."

    # Check bucket for default encryption
    else:
        try:
            # TODO: check bucket tags and pass if contains audit:public_okay

            # Encryption isn't in configurationItem so an API call is necessary
            response = s3Client.get_bucket_encryption(
                Bucket=configuration_item["resourceName"]
            )

            if response['ServerSideEncryptionConfiguration']['Rules'][0][
                    'ApplyServerSideEncryptionByDefault']['SSEAlgorithm'] != 'AES256':
                compliance_type = 'NON_COMPLIANT'
                annotation = 'S3 bucket is NOT encrypted with SSE-S3.'
            else:
                compliance_type = 'COMPLIANT'
                annotation = 'S3 bucket is encrypted with SSE-S3.'

        except BaseException as e:
            print(e)
            # If we receive an error, the default encryption flag is not set
            compliance_type = 'NON_COMPLIANT'
            annotation = 'S3 bucket does NOT have default encryption enabled.'

    return {
        "compliance_type": compliance_type,
        "annotation": annotation
    }

# This gets the client after assuming the Config service role
# either in the same AWS account or cross-account.
def get_client(service, event, region=None):
    """Return the service boto client. It should be used instead of directly calling the client.

    Keyword arguments:
    service -- the service name used for calling the boto.client()
    event -- the event variable given in the lambda handler
    region -- the region where the client is called (default: None)
    """
    if not ASSUME_ROLE_MODE:
        return boto3.client(service, region)
    credentials = get_assume_role_credentials(get_execution_role_arn(event), region)
    return boto3.client(service, aws_access_key_id=credentials['AccessKeyId'],
                        aws_secret_access_key=credentials['SecretAccessKey'],
                        aws_session_token=credentials['SessionToken'],
                        region_name=region
                       )

def get_assume_role_credentials(role_arn, region=None):
    sts_client = boto3.client('sts', region)
    try:
        assume_role_response = sts_client.assume_role(RoleArn=role_arn,
                                                      RoleSessionName="configLambdaExecution",
                                                      DurationSeconds=CONFIG_ROLE_TIMEOUT_SECONDS)
        return assume_role_response['Credentials']
    except botocore.exceptions.ClientError as ex:
        # Scrub error message for any internal account info leaks
        print(str(ex))
        if 'AccessDenied' in ex.response['Error']['Code']:
            ex.response['Error']['Message'] = "AWS Config does not have permission to assume the IAM role."
        else:
            ex.response['Error']['Message'] = "InternalError"
            ex.response['Error']['Code'] = "InternalError"
        raise ex

# Get execution role for Lambda function
def get_execution_role_arn(event):
    role_arn = None
    if 'ruleParameters' in event:
        rule_params = json.loads(event['ruleParameters'])
        role_name = rule_params.get("ExecutionRoleName")
        if role_name:
            execution_role_prefix = event["executionRoleArn"].split("/")[0]
            role_arn = "{}/{}".format(execution_role_prefix, role_name)
    if not role_arn:
        role_arn = event['executionRoleArn']

    return role_arn


def lambda_handler(event, context):
    """Entrypoint"""

    invoking_event = json.loads(event['invokingEvent'])

    # Check for oversized item
    if "configurationItem" in invoking_event:
        configuration_item = invoking_event["configurationItem"]
    elif "configurationItemSummary" in invoking_event:
        configuration_item = invoking_event["configurationItemSummary"]

    # Optional parameters
    rule_parameters = {}
    if 'ruleParameters' in event:
        rule_parameters = json.loads(event['ruleParameters'])

    print(event)
    config = get_client('config', event)
    s3Client = get_client('s3', event)

    evaluation = evaluate_compliance(configuration_item, rule_parameters, s3Client)

    print('Compliance evaluation for %s: %s' %
          (configuration_item['resourceId'], evaluation["compliance_type"]))
    print('Annotation: %s' % (evaluation["annotation"]))

    response = config.put_evaluations(
        Evaluations=[
            {
                'ComplianceResourceType': invoking_event['configurationItem']['resourceType'],
                'ComplianceResourceId': invoking_event['configurationItem']['resourceId'],
                'ComplianceType': evaluation["compliance_type"],
                "Annotation": evaluation["annotation"],
                'OrderingTimestamp': invoking_event['configurationItem']['configurationItemCaptureTime']
            },
        ],
        ResultToken=event['resultToken'])
