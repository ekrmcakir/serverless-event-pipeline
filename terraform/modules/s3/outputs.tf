output "raw_bucket_arn" {
  description = "ARN of the Raw S3 bucket"
  value       = aws_s3_bucket.raw_bucket.arn
}

output "raw_bucket_name" {
  description = "Name of the Raw S3 bucket"
  value       = aws_s3_bucket.raw_bucket.id
}

output "analytics_bucket_arn" {
  description = "ARN of the Analytics S3 bucket"
  value       = aws_s3_bucket.analytics_bucket.arn
}

output "analytics_bucket_name" {
  description = "Name of the Analytics S3 bucket"
  value       = aws_s3_bucket.analytics_bucket.id
}