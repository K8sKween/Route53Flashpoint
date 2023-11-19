import boto3
import json
from botocore.exceptions import ClientError
import os

def lambda_handler(event, context):
    try:
        # Extracting record details from the event
        record_data = json.loads(event['body'])
        record_name = record_data['name']
        record_type = record_data['type']
        record_value = record_data['value']
        record_ttl = record_data.get('ttl', 300)  # Default TTL

        # Initialize the Route 53 client
        route53 = boto3.client('route53')

        # Replace with your hosted zone ID

        hosted_zone_id = os.environ.get('HOSTED_ZONE_ID')
        if not hosted_zone_id:
            raise ValueError('HOSTED_ZONE_ID environment variable is not set')

        # Create the DNS record
        response = route53.change_resource_record_sets(
            HostedZoneId=hosted_zone_id,
            ChangeBatch={
                'Changes': [{
                    'Action': 'UPSERT',
                    'ResourceRecordSet': {
                        'Name': record_name,
                        'Type': record_type,
                        'TTL': record_ttl,
                        'ResourceRecords': [{'Value': record_value}]
                    }
                }]
            }
        )

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Record created/updated successfully', 'response': response})
        }

    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
