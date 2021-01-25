#!/usr/bin/env python3
#
# Delete ALL default resources in every default VPC in every AWS region.
# This also applies to custom VPCs that have been created by users and then flagged as the new "default VPC".
# Forked from: https://github.com/davidobrien1985/delete-aws-default-vpc/blob/master/delete-default-vpc.py
#
# Accepted Parameters: -e, --exclude
#                       (Optional) Comma separated, lowercase list of regions you want to exclude.
#                      -r, --role
#                       (Optional) An IAM role to assume and perform the operation in other accounts.
#                      -n, --dry-run
#                       (Optional) Show what would have happened.
# Examples:
#           python3 delete_default_vpc.py -n
#           python3 delete_default_vpc.py -e us-west-2,us-east-1
#           python3 delete_default_vpc.py -r arn:aws:iam::562495469185:role/super-user

import os
import re
import sys
import json
import boto3
import argparse
import logging
from botocore.exceptions import ClientError

DEBUG = True

CONFIG_ROLE_TIMEOUT_SECONDS = 900
LOGLEVEL = os.getenv("LOG_LEVEL", "ERROR").strip()
logger = logging.getLogger(__name__)
if DEBUG:
    logger.setLevel(logging.DEBUG)
else:
    logger.setLevel(logging.INFO)


def get_regions(client):
  """ Build a region list """

  reg_list = []
  regions = client.describe_regions()
  data_str = json.dumps(regions)
  resp = json.loads(data_str)
  region_str = json.dumps(resp['Regions'])
  region = json.loads(region_str)
  for reg in region:
    reg_list.append(reg['RegionName'])
  return reg_list

def get_default_vpcs(client):
  vpc_list = []
  vpcs = client.describe_vpcs(
    Filters=[
      {
          'Name' : 'isDefault',
          'Values' : [
            'true',
          ],
      },
    ]
  )
  vpcs_str = json.dumps(vpcs)
  resp = json.loads(vpcs_str)
  data = json.dumps(resp['Vpcs'])
  vpcs = json.loads(data)

  for vpc in vpcs:
    vpc_list.append(vpc['VpcId'])

  return vpc_list

def del_igw(ec2, vpcid, dryrun):
  """ Detach and delete the internet-gateway """
  vpc_resource = ec2.Vpc(vpcid)
  igws = vpc_resource.internet_gateways.all()
  if igws:
    for igw in igws:
      try:
        logger.debug(f"Detaching and Removing igw-id: %s" % igw.id)
        igw.detach_from_vpc(
          VpcId=vpcid,
          DryRun=dryrun
        )
        igw.delete(
          DryRun=dryrun
        )
      except ClientError as error:
        print(error)

def del_sub(ec2, vpcid, dryrun):
  """ Delete the subnets """
  vpc_resource = ec2.Vpc(vpcid)
  subnets = vpc_resource.subnets.all()
  default_subnets = [ec2.Subnet(subnet.id) for subnet in subnets if subnet.default_for_az]

  if default_subnets:
    try:
      for sub in default_subnets:
        logger.debug(f"Removing sub-id: %s" % sub.id)
        sub.delete(
          DryRun=dryrun
        )
    except ClientError as error:
      print(error)

def del_rtb(ec2, vpcid, dryrun):
  """ Delete the route-tables """
  vpc_resource = ec2.Vpc(vpcid)
  rtbs = vpc_resource.route_tables.all()
  if rtbs:
    try:
      for rtb in rtbs:
        assoc_attr = [rtb.associations_attribute for rtb in rtbs]
        if [rtb_ass[0]['RouteTableId'] for rtb_ass in assoc_attr if rtb_ass[0]['Main'] == True]:
          logger.info(f"%s is the main route table, continue..." % rtb.id)
          continue
        logger.debug(f"Removing rtb-id: %s" % rtb.id)
        table = ec2.RouteTable(rtb.id)
        table.delete(
          DryRun=dryrun
        )
    except ClientError as error:
      print(error)

def del_acl(ec2, vpcid, dryrun):
  """ Delete the network-access-lists """

  vpc_resource = ec2.Vpc(vpcid)
  acls = vpc_resource.network_acls.all()

  if acls:
    try:
      for acl in acls:
        if acl.is_default:
          logger.info(f"%s is the default NACL, continue..." % acl.id)
          continue
        logger.debug(f"Removing acl-id: %s" % acl.id)
        acl.delete(
          DryRun=dryrun
        )
    except ClientError as error:
      print(error)

def del_sgp(ec2, vpcid, dryrun):
  """ Delete any security-groups """
  vpc_resource = ec2.Vpc(vpcid)
  sgps = vpc_resource.security_groups.all()
  if sgps:
    try:
      for sg in sgps:
        if sg.group_name == 'default':
          logger.info(f"%s is the default security group, continue..." % sg.id)
          continue
        logger.debug(f"Removing sg-id: %s" % sg.id)
        sg.delete(
          DryRun=dryrun
        )
    except ClientError as error:
      print(error)

def del_vpc(ec2, vpcid, dryrun):
  """ Delete the VPC """
  vpc_resource = ec2.Vpc(vpcid)
  try:
    logger.info(f"Removing vpc-id: %s" % vpc_resource.id)
    vpc_resource.delete(
      DryRun=dryrun
    )
  except ClientError as error:
    print(error)
    logger.info('Please remove dependencies and delete VPC manually.')

# This gets the client after assuming the role
# either in the same AWS account or cross-account.
def get_client(service, role_arn, region_name = None):
    """Return the service boto client. It should be used instead of directly calling the client.

    Keyword arguments:
    service -- the service name used for calling the boto.client()
    event -- the event variable given in the lambda handler
    """
    if not role_arn:
        return boto3.client(service,
                            region_name=region_name)
    credentials = get_assume_role_credentials(role_arn)
    return boto3.client(service, aws_access_key_id=credentials['AccessKeyId'],
                        aws_secret_access_key=credentials['SecretAccessKey'],
                        aws_session_token=credentials['SessionToken'],
                        region_name=region_name
                       )

# This gets the resource after assuming the role
# either in the same AWS account or cross-account.
def get_resource(service, role_arn, region_name = None):
    """Return the service boto client. It should be used instead of directly calling the client.

    Keyword arguments:
    service -- the service name used for calling the boto.client()
    event -- the event variable given in the lambda handler
    """
    if not role_arn:
        return boto3.resource(service,
                              region_name=region_name)
    credentials = get_assume_role_credentials(role_arn)
    return boto3.resource(service, aws_access_key_id=credentials['AccessKeyId'],
                          aws_secret_access_key=credentials['SecretAccessKey'],
                          aws_session_token=credentials['SessionToken'],
                          region_name=region_name
                          )

def get_assume_role_credentials(role_arn):
    sts_client = boto3.client('sts')
    try:
        assume_role_response = sts_client.assume_role(RoleArn=role_arn,
                                                      RoleSessionName="ec2CleanupExecution",
                                                      DurationSeconds=CONFIG_ROLE_TIMEOUT_SECONDS)
        if 'liblogging' in sys.modules:
            liblogging.logSession(role_arn, assume_role_response)
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


def main(**kwargs):
  """
  Order
   * Delete the internet-gateway
   * Delete subnets
   * Delete route-tables
   * Delete network access-lists
   * Delete security-groups
   * Delete the VPC
  """

  dryrun = False
  if 'dryrun' in kwargs:
    dryrun = kwargs.get('dryrun', False)

  exclude_regions = []
  if 'exclude' in kwargs:
    exclude = kwargs.pop('exclude', '')
    if exclude:
      exclude_regions = list(filter(lambda x: len(x), re.sub(r"\s+",'', exclude).split(",")))

  role_arn = None
  if 'role_arn' in kwargs:
    role_arn = kwargs.get('role_arn', None)

  client = get_client('ec2', role_arn)
  regions = get_regions(client)

  for region in regions:
    try:
      logger.info('')
      logger.info('Processing region: %s', region)
      logger.info('')
      if not region in exclude_regions:
        client = get_client('ec2', role_arn, region_name = region)
        ec2 = get_resource('ec2', role_arn, region_name = region)
        vpcs = get_default_vpcs(client)
      else:
        logger.info('Skipping the region %s...', region)
        continue
    except ClientError as error:
      raise ValueError('ClientError: {}'.format(error))
    else:
      for vpc in vpcs:
        logger.info('')
        logger.info('REGION: %s', region)
        logger.info('VPC ID: %s', vpc)
        logger.info('')
        del_igw(ec2, vpc, dryrun)
        del_sub(ec2, vpc, dryrun)
        del_rtb(ec2, vpc, dryrun)
        del_acl(ec2, vpc, dryrun)
        del_sgp(ec2, vpc, dryrun)
        del_vpc(ec2, vpc, dryrun)

if __name__ == "__main__":
    """Command Line calling of this script. """
    logging.basicConfig(format='%(asctime)s %(levelname)s:%(message)s',
                        level=logging.INFO)

    parser = argparse.ArgumentParser(
        description="Delete all default AWS VPCs in all regions",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter)
    parser.add_argument("-e", "--exclude", type=str, required=False,
                        help="Comma separated, lowercase list of regions you want to exclude")
    parser.add_argument("-r", "--role", required=False, default=None,
                        help="Specify an IAM role to perform the operation")
    parser.add_argument("-n", "--dry-run", action='store_true',
                        help="Show what would have happened")
    args = parser.parse_args()
    sync = main(role_arn=args.role, dryrun=args.dry_run, exclude=args.exclude)
