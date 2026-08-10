terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# 1. S3 Storage Module
module "s3" {
  source = "./modules/s3"

  project_name = var.project_name
  environment  = var.environment
}

# 2. SQS Queue Module
module "sqs" {
  source = "./modules/sqs"

  project_name = var.project_name
  environment  = var.environment
}

# 3. IAM Module
module "iam" {
  source = "./modules/iam"

  project_name         = var.project_name
  environment          = var.environment
  raw_bucket_arn       = module.s3.raw_bucket_arn
  analytics_bucket_arn = module.s3.analytics_bucket_arn
  sqs_queue_arn        = module.sqs.queue_arn
}

# 4. Lambda Module
module "lambda" {
  source = "./modules/lambda"

  project_name         = var.project_name
  environment          = var.environment
  raw_bucket_id        = module.s3.raw_bucket_name
  raw_bucket_arn       = module.s3.raw_bucket_arn
  analytics_bucket_id  = module.s3.analytics_bucket_name
  sqs_queue_arn        = module.sqs.queue_arn
  ingestion_role_arn   = module.iam.ingestion_lambda_role_arn
  transformer_role_arn = module.iam.transformer_lambda_role_arn
}

# 5. Analytics Module (Glue & Athena)
module "analytics" {
  source = "./modules/analytics"

  project_name         = var.project_name
  environment          = var.environment
  analytics_bucket_id  = module.s3.analytics_bucket_name
  analytics_bucket_arn = module.s3.analytics_bucket_arn
}