variable "project_name" {
  type    = string
  default = "serverless-event-pipeline"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "raw_bucket_id" {}
variable "raw_bucket_arn" {}
variable "analytics_bucket_id" {}

variable "sqs_queue_arn" {}
variable "ingestion_role_arn" {}
variable "transformer_role_arn" {}