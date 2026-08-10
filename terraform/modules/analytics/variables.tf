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

variable "analytics_bucket_id" {
  description = "ID/Name of the Analytics S3 bucket"
  type        = string
}

variable "analytics_bucket_arn" {
  description = "ARN of the Analytics S3 bucket"
  type        = string
}