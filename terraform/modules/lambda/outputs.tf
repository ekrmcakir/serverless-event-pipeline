output "ingestion_lambda_arn" {
  description = "ARN of the Ingestion Lambda"
  value       = aws_lambda_function.ingestion.arn
}

output "transformer_lambda_arn" {
  description = "ARN of the Transformer Lambda"
  value       = aws_lambda_function.transformer.arn
}