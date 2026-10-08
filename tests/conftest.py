import os
import pytest
import boto3
from moto import mock_aws

@pytest.fixture(autouse=True)
def aws_environment():
    """Mocked AWS Credentials for moto and test isolation."""
    os.environ['AWS_ACCESS_KEY_ID'] = 'testing'
    os.environ['AWS_SECRET_ACCESS_KEY'] = 'testing'
    os.environ['AWS_SECURITY_TOKEN'] = 'testing'
    os.environ['AWS_SESSION_TOKEN'] = 'testing'
    os.environ['AWS_DEFAULT_REGION'] = 'us-east-1'
    os.environ['RAW_BUCKET_NAME'] = 'test-raw-bucket'
    os.environ['ANALYTICS_BUCKET_NAME'] = 'test-analytics-bucket'

@pytest.fixture
def s3_buckets(aws_environment):
    """Create mock S3 raw and analytics buckets."""
    with mock_aws():
        s3 = boto3.client('s3', region_name='us-east-1')
        s3.create_bucket(Bucket='test-raw-bucket')
        s3.create_bucket(Bucket='test-analytics-bucket')
        yield s3
