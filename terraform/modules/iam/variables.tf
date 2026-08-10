variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "serverless-event-pipeline"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "raw_bucket_arn" {
  description = "ARN of the Raw S3 bucket"
  type        = string
}

variable "analytics_bucket_arn" {
  description = "ARN of the Analytics S3 bucket"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the primary Ingestion SQS queue"
  type        = string
}