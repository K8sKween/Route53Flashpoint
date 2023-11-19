import boto3
import json
from datetime import datetime
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    dynamodb = boto3.resource('dynamodb')
    route53 = boto3.client('route53')

    # DynamoDB table name for DNS records
    table_name = 'YOUR_DYNAMODB_TABLE_NAME'
    table = dynamodb.Table(table_name)

    # Current date for checking expiration
    current_date = datetime.utcnow().strftime('%Y-%m-%d')

    try:
        # Scanning DynamoDB for expired records
        expired_records = table.scan(
            FilterExpression='ExpirationDate <= :today',
            ExpressionAttributeValues={':today': current_date}
        )['Items']

        for record in expired_records:
            try:
                # Delete the record from Route 53
                response = route53.change_resource_record_sets(
                    HostedZoneId=record['HostedZoneId'],
                    ChangeBatch={
                        'Changes': [{
                            'Action': 'DELETE',
                            'ResourceRecordSet': {
                                'Name': record['RecordName'],
                                'Type': record['RecordType'],
                                'TTL': record['TTL'],
                                'ResourceRecords': [{'Value': record['RecordValue']}]
                            }
                        }]
                    }
                )

                # Optionally, delete the record from DynamoDB
                # table.delete_item(Key={'RecordName': record['RecordName']})

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
