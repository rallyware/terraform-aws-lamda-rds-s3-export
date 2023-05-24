output "s3_export_path" {
  value       = local.enabled ? "s3://${module.bucket.bucket_id}/${var.s3_prefix}/" : null
  description = "A path to exported data in an AWS S3 bucket"
}

output "lambda_arn" {
  value       = module.lambda.arn
  description = "The AWS Lambda function ARN"
}
output "key_arn" {
  value       = module.kms_key.key_arn
  description = "Key ARN"
}

output "key_id" {
  value       = module.kms_key.key_id
  description = "Key ID"
}

output "alias_arn" {
  value       = module.kms_key.alias_arn
  description = "Alias ARN"
}

output "role_name" {
  value       = module.role.name
  description = "The name of the created role"
}

output "role_id" {
  value       = module.role.id
  description = "The stable and unique string identifying the role"
}

output "role_arn" {
  value       = module.role.arn
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "role_policy" {
  value       = module.role.policy
  description = "The Amazon Resource Name (ARN) specifying the role"
}

output "key_alias_name" {
  value       = module.kms_key.alias_name
  description = "KMS key alias name"
}

output "bucket_domain_name" {
  value       = module.bucket.bucket_domain_name
  description = "FQDN of bucket"
}

output "bucket_id" {
  value       = module.bucket.bucket_id
  description = "Bucket Name (aka ID)"
}

output "bucket_arn" {
  value       = module.bucket.bucket_arn
  description = "Bucket ARN"
}
