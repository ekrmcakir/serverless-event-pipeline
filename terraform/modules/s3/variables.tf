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