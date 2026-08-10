output "sqs_queue_url" {
  description = "URL of the primary SQS queue to push events to"
  value       = module.sqs.queue_id
}

output "sqs_dlq_url" {
  description = "URL of the Dead Letter Queue for inspecting failed events"
  value       = module.sqs.dlq_id
}

output "s3_raw_bucket" {
  description = "Name of the S3 Raw bucket"
  value       = module.s3.raw_bucket_name
}

output "s3_analytics_bucket" {
  description = "Name of the S3 Analytics (Parquet) bucket"
  value       = module.s3.analytics_bucket_name
}

output "ingestion_lambda_arn" {
  description = "ARN of Ingestion Lambda"
  value       = module.lambda.ingestion_lambda_arn
}

output "transformer_lambda_arn" {
  description = "ARN of Transformer Lambda"
  value       = module.lambda.transformer_lambda_arn
}

output "glue_database_name" {
  description = "Name of the Glue Catalog Database"
  value       = module.analytics.glue_database_name
}

output "athena_workgroup_name" {
  description = "Name of the Athena Workgroup"
  value       = module.analytics.athena_workgroup_name
}