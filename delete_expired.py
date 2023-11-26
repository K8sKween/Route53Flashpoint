import boto3
import json
import os
from datetime import datetime
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    route53 = boto3.client('route53')
    
    
    hosted_zone_id = os.environ.get('HOSTED_ZONE_ID')
    if not hosted_zone_id:
        raise ValueError('HOSTED_ZONE_ID environment variable is not set')
    tablename = os.environ.get('DYNAMODB_TABLE')
    if not tablename:
        raise ValueError('DYNAMODB_TABLE environment variable is not set')

    # Current date for checking expiration
    current_date = datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%SZ')
    # Get a reference to the DynamoDB table
    table = dynamodb.Table(tablename)
    try:
        # Scanning DynamoDB for expired records
        expired_records = table.scan(
            FilterExpression='delete_after <= :today',
            ExpressionAttributeValues={':today': current_date}
        )['Items']
        print(expired_records)
        for record in expired_records:
            try:
                # Delete the record from Route 53
                response = route53.change_resource_record_sets(
                    HostedZoneId=hosted_zone_id,
                    ChangeBatch={
                        'Changes': [{
                            'Action': 'DELETE',
                            'ResourceRecordSet': {
                                'Name': record['RecordName'],
                                'Type': record['RecordType'],
                                'TTL': int(record['ttl']),
                                'ResourceRecords': [{'Value': record['value']}]
                            }
                        }]
                    }
                )
                print(f"Deleted record: {record['RecordName']}")

                # Optionally, delete the record from DynamoDB
                table.delete_item(Key={'RecordName': record['RecordName'], 'RecordType': record['RecordType']})

            except ClientError as e:
                print(f"Error deleting record: {record['RecordName']}, Error: {str(e)}")

        return {
            'statusCode': 200,
            'body': json.dumps({'message': f'Processed {len(expired_records)} expired records'})
        }

    except ClientError as e:
        return {
            'statusCode': 500,
            'body': json.dumps({'error': str(e)})
        }
