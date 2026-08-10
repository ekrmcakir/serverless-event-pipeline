output "ingestion_lambda_role_arn" {
  description = "IAM Role ARN for Ingestion Lambda"
  value       = aws_iam_role.ingestion_lambda_role.arn
}

output "transformer_lambda_role_arn" {
  description = "IAM Role ARN for Transformer Lambda"
  value       = aws_iam_role.transformer_lambda_role.arn
}