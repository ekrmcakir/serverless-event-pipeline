resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# 1. Raw Zone Bucket (Raw JSON payloads)
resource "aws_s3_bucket" "raw_bucket" {
  bucket        = "${var.project_name}-raw-${var.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "raw_public_block" {
  bucket = aws_s3_bucket.raw_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "raw_encryption" {
  bucket = aws_s3_bucket.raw_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# 2. Analytics Zone Bucket (Parquet files)
resource "aws_s3_bucket" "analytics_bucket" {
  bucket        = "${var.project_name}-analytics-${var.environment}-${random_id.bucket_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "analytics_public_block" {
  bucket = aws_s3_bucket.analytics_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "analytics_encryption" {
  bucket = aws_s3_bucket.analytics_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Cost Optimization: Transition Parquet files older than 90 days to Glacier
resource "aws_s3_bucket_lifecycle_configuration" "analytics_lifecycle" {
  bucket = aws_s3_bucket.analytics_bucket.id

  rule {
    id     = "archive-old-parquet-data"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}