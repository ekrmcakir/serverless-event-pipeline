import json
import pytest
import boto3
from moto import mock_aws

def test_ingestion_valid_message(monkeypatch):
    """Test that a valid SQS event is processed and written to Raw S3."""
    with mock_aws():
        s3 = boto3.client('s3', region_name='us-east-1')
        s3.create_bucket(Bucket='test-raw-bucket')

        import src.ingestion.handler as handler
        monkeypatch.setattr(handler, 'RAW_BUCKET', 'test-raw-bucket')
        monkeypatch.setattr(handler, 's3_client', s3)

        event = {
            'Records': [
                {
                    'messageId': 'msg-12345',
                    'body': json.dumps({'order_id': 'ord-999', 'amount': 150.50})
                }
            ]
        }

        response = handler.lambda_handler(event, None)
        assert response['statusCode'] == 200
        assert json.loads(response['body'])['processed_records'] == 1

        # Verify object created in S3
        objects = s3.list_objects_v2(Bucket='test-raw-bucket')
        assert 'Contents' in objects
        assert len(objects['Contents']) == 1

        key = objects['Contents'][0]['Key']
        assert key.startswith('raw/year=')

        obj = s3.get_object(Bucket='test-raw-bucket', Key=key)
        data = json.loads(obj['Body'].read().decode('utf-8'))
        assert data['order_id'] == 'ord-999'
        assert data['_metadata']['message_id'] == 'msg-12345'


def test_ingestion_invalid_json_raises_for_dlq(monkeypatch):
    """Test that malformed JSON payload raises exception for SQS DLQ retry."""
    with mock_aws():
        s3 = boto3.client('s3', region_name='us-east-1')
        s3.create_bucket(Bucket='test-raw-bucket')

        import src.ingestion.handler as handler
        monkeypatch.setattr(handler, 'RAW_BUCKET', 'test-raw-bucket')
        monkeypatch.setattr(handler, 's3_client', s3)

        event = {
            'Records': [
                {
                    'messageId': 'msg-malformed',
                    'body': '{bad_json: invalid}'
                }
            ]
        }

        with pytest.raises(json.JSONDecodeError):
            handler.lambda_handler(event, None)
