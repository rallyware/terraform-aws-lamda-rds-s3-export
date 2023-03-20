output "s3_path" {
  value       = "${var.s3_bucket_id}/${var.s3_prefix}/"
  description = "A path to exported data in an AWS S3 bucket"
}

output "lambda_name" {
  value       = module.lambda.function_name
  description = "The AWS Lambda function name"
}
