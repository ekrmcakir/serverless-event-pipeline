# -------------------------------------------------------------
# 1. ARCHIVE SOURCE CODE
# -------------------------------------------------------------
data "archive_file" "ingestion_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../src/ingestion/handler.py"
  output_path = "${path.module}/ingestion.zip"
}

data "archive_file" "transformer_zip" {
  type        = "zip"
  source_file = "${path.module}/../../../src/transformer/handler.py"
  output_path = "${path.module}/transformer.zip"
}

# -------------------------------------------------------------
# 2. INGESTION LAMBDA & SQS TRIGGER
# -------------------------------------------------------------
resource "aws_lambda_function" "ingestion" {
  filename         = data.archive_file.ingestion_zip.output_path
  source_code_hash = data.archive_file.ingestion_zip.output_base64sha256
  function_name    = "${var.project_name}-ingestion-${var.environment}"
  role             = var.ingestion_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 256

  environment {
    variables = {
      RAW_BUCKET_NAME = var.raw_bucket_id
    }
  }
}

resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.ingestion.arn
  batch_size       = 10 # Read up to 10 messages from SQS at once
}

# -------------------------------------------------------------
# 3. TRANSFORMER LAMBDA & S3 TRIGGER
# -------------------------------------------------------------
resource "aws_lambda_function" "transformer" {
  filename         = data.archive_file.transformer_zip.output_path
  function_name    = "${var.project_name}-transformer-${var.environment}"
  role             = var.transformer_role_arn
  handler          = "handler.lambda_handler"
  runtime          = "python3.11"
  timeout          = 60
  memory_size      = 512
  source_code_hash = data.archive_file.transformer_zip.output_base64sha256

  layers = [
    "arn:aws:lambda:eu-central-1:336392948345:layer:AWSSDKPandas-Python311:12"
  ]

  environment {
    variables = {
      ENVIRONMENT          = var.environment
      ANALYTICS_BUCKET_NAME = var.analytics_bucket_id
    }
  }
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.transformer.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = var.raw_bucket_arn
}

resource "aws_s3_bucket_notification" "raw_bucket_trigger" {
  bucket = var.raw_bucket_id

  lambda_function {
    lambda_function_arn = aws_lambda_function.transformer.arn
    events              = ["s3:ObjectCreated:*"]
    filter_prefix       = "raw/"
    filter_suffix       = ".json"
  }
  depends_on = [aws_lambda_permission.allow_s3]
}