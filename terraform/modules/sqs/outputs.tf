output "queue_id" {
  description = "URL of the primary SQS queue"
  value       = aws_sqs_queue.pipeline_queue.id
}

output "queue_arn" {
  description = "ARN of the primary SQS queue"
  value       = aws_sqs_queue.pipeline_queue.arn
}

output "dlq_id" {
  description = "URL of the Dead Letter Queue"
  value       = aws_sqs_queue.pipeline_dlq.id
}

output "dlq_arn" {
  description = "ARN of the Dead Letter Queue"
  value       = aws_sqs_queue.pipeline_dlq.arn
}