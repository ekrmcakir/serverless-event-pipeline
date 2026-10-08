import json
from io import BytesIO
import pandas as pd
import boto3
from moto import mock_aws

def test_transformer_converts_json_to_parquet(monkeypatch):
    """Test that S3 ObjectCreated event transforms JSON into Parquet in Analytics S3 bucket."""
    with mock_aws():
        s3 = boto3.client('s3', region_name='us-east-1')
        s3.create_bucket(Bucket='test-raw-bucket')
        s3.create_bucket(Bucket='test-analytics-bucket')

        raw_key = 'raw/year=2026/month=10/day=08/sample-event.json'
        sample_payload = {
            'order_id': 'ord-1001',
            'customer_id': 'cust-55',
            'amount': 249.99,
            'status': 'COMPLETED'
        }
        s3.put_object(
            Bucket='test-raw-bucket',
            Key=raw_key,
            Body=json.dumps(sample_payload),
            ContentType='application/json'
        )

        import src.transformer.handler as handler
        monkeypatch.setattr(handler, 'ANALYTICS_BUCKET', 'test-analytics-bucket')
        monkeypatch.setattr(handler, 's3_client', s3)

        event = {
            'Records': [
                {
                    's3': {
                        'bucket': {'name': 'test-raw-bucket'},
                        'object': {'key': raw_key}
                    }
                }
            ]
        }

        response = handler.lambda_handler(event, None)
        assert response['statusCode'] == 200

        # Verify Parquet output in Analytics Bucket
        expected_dest_key = raw_key.replace('raw/', 'analytics/').replace('.json', '.parquet')
        obj = s3.get_object(Bucket='test-analytics-bucket', Key=expected_dest_key)

        parquet_buffer = BytesIO(obj['Body'].read())
        df = pd.read_parquet(parquet_buffer)

        assert len(df) == 1
        assert df['order_id'].iloc[0] == 'ord-1001'
        assert df['amount'].iloc[0] == 249.99
