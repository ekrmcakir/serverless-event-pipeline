import json
import os
import boto3
import uuid
from datetime import datetime

# Initialize S3 client
s3_client = boto3.client('s3')
RAW_BUCKET = os.environ.get('RAW_BUCKET_NAME')

def lambda_handler(event, context):
    """
    Triggered by SQS Event. Parses messages and writes to the Raw S3 Bucket.
    """
    records = event.get('Records', [])
    processed_count = 0

    for record in records:
        body_str = record.get('body', '{}')
        try:
            # Validate JSON payload
            payload = json.loads(body_str)
            
            # Inject timestamp and unique message ID
            now = datetime.utcnow()
            payload['_metadata'] = {
                'received_at': now.isoformat(),
                'message_id': record.get('messageId')
            }
            
            # Generate partition key for S3: raw/year=2026/month=08/day=15/...
            s3_key = f"raw/year={now.strftime('%Y')}/month={now.strftime('%m')}/day={now.strftime('%d')}/{uuid.uuid4()}.json"
            
            # Write to Raw S3 Bucket
            s3_client.put_object(
                Bucket=RAW_BUCKET,
                Key=s3_key,
                Body=json.dumps(payload),
                ContentType='application/json'
            )
            processed_count += 1
            
        except json.JSONDecodeError as e:
            print(f"Invalid JSON payload received: {body_str}. Error: {str(e)}")
            # Raise exception to trigger SQS retry policy / DLQ mechanism
            raise e
            
    return {
        'statusCode': 200,
        'body': json.dumps({
            'message': 'Successfully processed messages',
            'processed_records': processed_count
        })
    }