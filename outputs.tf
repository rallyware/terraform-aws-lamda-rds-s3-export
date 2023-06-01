output "lambda_arn" {
  value       = module.lambda.arn
  description = "The AWS Lambda function ARN"
}

output "lambda_role_arn" {
  value       = module.lambda.role_arn
  description = "The AWS Lambda function role ARN"
}

output "export_key_arn" {
  value       = module.kms_key.key_arn
  description = "The ARN of KMS key used by export task"
}

output "export_role_arn" {
  value       = module.role.arn
  description = "The ARN of IAM role used by export task"
}

output "bucket_arn" {
  value       = module.bucket.bucket_arn
  description = "The AWS S3 bucket ARN"
}
