import boto3
import json
import os
import datetime
from botocore.exceptions import ClientError
from decimal import Decimal

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')

    # DynamoDB table name
    tablename = os.environ.get('DYNAMODB_TABLE')
    if not tablename:
        raise ValueError('DYNAMODB_TABLE environment variable is not set')
    table = dynamodb.Table(tablename)

    try:
        # Scan the DynamoDB table for active records
        response = table.scan()
        records = response.get('Items', [])

        # Filter for active records (adjust the condition as per your data schema)
        active_records = [record for record in records if record['delete_after'] > datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')]
        expired_records = [record for record in records if record['delete_after'] < datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')]

        # Convert Decimal objects to float
        active_records = [{k: float(v) if isinstance(v, Decimal) else v for k, v in record.items()} for record in active_records]
        expired_records = [{k: float(v) if isinstance(v, Decimal) else v for k, v in record.items()} for record in expired_records]

        return {
            'statusCode': 200,
            'body': json.dumps({'active_records': active_records, 'expired_records': expired_records}, cls=DateTimeEncoder)
        }

    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }

class DateTimeEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, datetime.datetime):
            return o.isoformat()

        return super().default(o)