# -------------------------------------------------------------
# 1. ATHENA QUERY RESULTS BUCKET
# Athena stores query execution results (CSV metadata) in S3
# -------------------------------------------------------------
resource "random_id" "athena_suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "athena_results" {
  bucket        = "${var.project_name}-athena-results-${var.environment}-${random_id.athena_suffix.hex}"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "athena_results_public_block" {
  bucket = aws_s3_bucket.athena_results.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# -------------------------------------------------------------
# 2. AWS GLUE DATA CATALOG DATABASE
# Logical database holding our external Parquet tables
# -------------------------------------------------------------
resource "aws_glue_catalog_database" "analytics_db" {
  name        = "${replace(var.project_name, "-", "_")}_db_${var.environment}"
  description = "Glue Catalog database for serverless analytics"
}

# -------------------------------------------------------------
# 3. GLUE IAM ROLE & CRAWLER
# Crawls Parquet files and updates table schemas automatically
# -------------------------------------------------------------
resource "aws_iam_role" "glue_crawler_role" {
  name = "${var.project_name}-glue-crawler-role-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "glue.amazonaws.com" }
    }]
  })
}

resource "aws_iam_policy" "glue_crawler_policy" {
  name        = "${var.project_name}-glue-crawler-policy-${var.environment}"
  description = "Policy for Glue Crawler to read S3 and manage catalog"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          var.analytics_bucket_arn,
          "${var.analytics_bucket_arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "glue:GetDatabase",
          "glue:GetTable",
          "glue:GetPartitions",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:BatchCreatePartition"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_crawler_attach" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
}

resource "aws_glue_crawler" "analytics_crawler" {
  database_name = aws_glue_catalog_database.analytics_db.name
  name          = "${var.project_name}-crawler-${var.environment}"
  role          = aws_iam_role.glue_crawler_role.arn

  s3_target {
    path = "s3://${var.analytics_bucket_id}/analytics/"
  }

  schema_change_policy {
    delete_behavior = "LOG"
    update_behavior = "UPDATE_IN_DATABASE"
  }
}

# -------------------------------------------------------------
# 4. AMAZON ATHENA WORKGROUP
# Serverless SQL query execution environment
# -------------------------------------------------------------
resource "aws_athena_workgroup" "analytics_workgroup" {
  name        = "${var.project_name}-workgroup-${var.environment}"
  description = "Dedicated Athena workgroup for analytics pipeline"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.athena_results.bucket}/query-results/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}