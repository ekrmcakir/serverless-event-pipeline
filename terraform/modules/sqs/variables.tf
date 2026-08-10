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

variable "visibility_timeout_seconds" {
  description = "Visibility timeout for the main SQS queue in seconds"
  type        = number
  default     = 60
}

variable "max_receive_count" {
  description = "Number of retry attempts before sending message to DLQ"
  type        = number
  default     = 3
}