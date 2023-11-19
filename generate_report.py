import boto3
import json
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')

    # DynamoDB table name
    table_name = 'Route53FlashpointDNSRecords'
    table = dynamodb.Table(table_name)

    try:
        # Scan the DynamoDB table for active records
        response = table.scan()
        records = response.get('Items', [])

        # Filter for active records (adjust the condition as per your data schema)
        active_records = [record for record in records if record.get('Status') == 'Active']

        return {
            'statusCode': 200,
            'body': json.dumps({'active_records': active_records})
        }

    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
