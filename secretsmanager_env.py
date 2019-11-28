#!/usr/bin/env python
import argparse
import json
import os

import boto3


parser = argparse.ArgumentParser(
    formatter_class=argparse.RawDescriptionHelpFormatter,
    description='''\
Output following the defined format.
   Options are:
     dotenv - dotenv style [default]
     export - shell export style
     stdout - secret plain value style'''
     )
parser.add_argument(
        '--output',
        default='dotenv',
        choices=['stdout', 'dotenv', 'export'],
    )

args = parser.parse_args()

try:
    secret_id = os.environ.get("ENV_SECRET_NAME")
    secretsmanager = boto3.client('secretsmanager')
    secret_values = json.loads(secretsmanager.get_secret_value(SecretId=secret_id)['SecretString'])
except:
    print('Error getting secret')
    raise

if args.output == 'export':
    prefix = 'export '
else:
    prefix = ''

if args.output != 'stdout':
    for envvar in secret_values:
        print(prefix+envvar+"=$'"+secret_values[envvar].replace('\\n', '\n')+"'")
else:
    print(json.dumps(secret_values.replace('\\n', '\n'), indent=2, sort_keys=True))
