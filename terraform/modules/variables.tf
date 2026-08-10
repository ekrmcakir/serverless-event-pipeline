variable "aws_region" {
  description = "AWS deployment region"
  type        = string
  default     = "eu-central-1"
}

variable "project_name" {
  description = "Base name for all project resources"
  type        = string
  default     = "serverless-event-pipeline"
}

variable "environment" {
  description = "Deployment stage environment"
  type        = string
  default     = "dev"
}