output "s3_export_path" {
  value       = local.enabled ? "s3://${var.s3_bucket_id}/${var.s3_prefix}/" : null
  description = "A path to exported data in an AWS S3 bucket"
}

output "lambda_arn" {
  value       = local.enabled ? module.lambda[0].arn : null
  description = "The AWS Lambda function ARN"
}
