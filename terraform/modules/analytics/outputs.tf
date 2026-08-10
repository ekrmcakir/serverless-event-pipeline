output "glue_database_name" {
  description = "Glue Catalog Database Name"
  value       = aws_glue_catalog_database.analytics_db.name
}

output "athena_workgroup_name" {
  description = "Athena Workgroup Name"
  value       = aws_athena_workgroup.analytics_workgroup.name
}

output "athena_results_bucket" {
  description = "S3 Bucket storing Athena SQL query results"
  value       = aws_s3_bucket.athena_results.id
}