# 1. Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "pipeline_dlq" {
  name                      = "${var.project_name}-ingestion-dlq-${var.environment}"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Name        = "${var.project_name}-dlq"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

# 2. Primary Queue
resource "aws_sqs_queue" "pipeline_queue" {
  name                       = "${var.project_name}-ingestion-queue-${var.environment}"
  visibility_timeout_seconds = var.visibility_timeout_seconds
  message_retention_seconds  = 86400 # 1 day

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.pipeline_dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name        = "${var.project_name}-queue"
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}