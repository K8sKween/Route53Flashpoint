import boto3
import json
from botocore.exceptions import ClientError
import os
import datetime

def lambda_handler(event, context):
    try:
        # Extracting record details from the event
        record_data = json.loads(event['body'])
        record_name = record_data['name']
        record_type = record_data['type']
        record_value = record_data['value']
        delete_after = record_data['delete_after']
        record_ttl = record_data.get('ttl', 300)  # Default TTL

        # Initialize the Route 53 client
        route53 = boto3.client('route53')
        dynamodb = boto3.resource('dynamodb')
        # Replace with your hosted zone ID

        hosted_zone_id = os.environ.get('HOSTED_ZONE_ID')
        if not hosted_zone_id:
            raise ValueError('HOSTED_ZONE_ID environment variable is not set')
        tablename = os.environ.get('DYNAMODB_TABLE')
        if not tablename:
            raise ValueError('DYNAMODB_TABLE environment variable is not set')

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

        # Create the DynamoDB record
        # Get a reference to the DynamoDB table
        table = dynamodb.Table(tablename)

        # Add a new item to the table
        response = table.put_item(
            Item={
                'RecordName': record_name,
                'RecordType': record_type,
                'ttl': record_ttl,
                'value': record_value,
                'delete_after': delete_after
            }
        )        

        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Record created/updated successfully', 'response': response}, cls=DateTimeEncoder)
        }

    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'body': json.dumps({'error': 'An unexpected error occurred'})
        }


class DateTimeEncoder(json.JSONEncoder):
    def default(self, o):
        if isinstance(o, datetime.datetime):
            return o.isoformat()

        return super().default(o)