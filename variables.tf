variable "s3_bucket_id" {
  type        = string
  description = "The name of the Amazon S3 bucket to export the snapshot to"
}

variable "s3_prefix" {
  type        = string
  default     = "RDS"
  description = "The Amazon S3 bucket prefix to use as the file name and path of the exported data"
}

variable "kms_key_id" {
  type        = string
  description = "The ID of the Amazon Web Services KMS key to use to encrypt the data exported to Amazon S3"
}

variable "export_task_role_arn" {
  type        = string
  description = "The name of the IAM role to use for writing to the Amazon S3 bucket when exporting a snapshot"
}

variable "lambda_policy_arn" {
  type        = string
  description = "The ARN of custom IAM policy for lambda function that starts snapshot export task"
}
