import json
import os
import boto3
import urllib.parse
import pandas as pd
from io import BytesIO

s3_client = boto3.client('s3')
ANALYTICS_BUCKET = os.environ.get('ANALYTICS_BUCKET_NAME')

def lambda_handler(event, context):
    """
    Triggered by S3 ObjectCreated event in Raw Bucket.
    Reads JSON, transforms it to Parquet, and writes to Analytics Bucket.
    """
    for record in event['Records']:
        source_bucket = record['s3']['bucket']['name']
        source_key = urllib.parse.unquote_plus(record['s3']['object']['key'], encoding='utf-8')
        
        try:
            # 1. Fetch JSON file from Raw Bucket
            response = s3_client.get_object(Bucket=source_bucket, Key=source_key)
            json_content = json.loads(response['Body'].read().decode('utf-8'))
            
            # Ensure it's a list for Pandas DataFrame
            if isinstance(json_content, dict):
                json_content = [json_content]
                
            # 2. Convert JSON to Pandas DataFrame
            df = pd.DataFrame(json_content)
            
            # 3. Write DataFrame to Parquet format in memory
            parquet_buffer = BytesIO()
            df.to_parquet(parquet_buffer, engine='pyarrow', compression='snappy')
            
            # Replace 'raw' prefix with 'analytics' and change extension
            destination_key = source_key.replace('raw/', 'analytics/').replace('.json', '.parquet')
            
            # 4. Upload Parquet file to Analytics Bucket
            s3_client.put_object(
                Bucket=ANALYTICS_BUCKET,
                Key=destination_key,
                Body=parquet_buffer.getvalue()
            )
            
            print(f"Successfully transformed and uploaded to {ANALYTICS_BUCKET}/{destination_key}")
            
        except Exception as e:
            print(f"Error processing object {source_key} from bucket {source_bucket}. Error: {str(e)}")
            raise e
            
    return {
        'statusCode': 200,
        'body': 'Transformation complete'
    }