variable "lambda_runtime" {
  type        = string
  default     = "python3.9"
  description = "The runtime environment for the Lambda function you are uploading."
}

variable "lambda_architectures" {
  type        = list(string)
  default     = ["arm64"]
  description = "Instruction set architecture for AWS Lambda function."
}

variable "lambda_timeout" {
  type        = number
  default     = 5
  description = "The amount of time the Lambda Function has to run in seconds."
}

variable "lambda_memory" {
  type        = number
  default     = 128
  description = "Amount of memory in MB the Lambda Function can use at runtime."
}

variable "lambda_description" {
  type        = string
  default     = "This Lambda function automates RDS snapshot export to S3"
  description = "Description of what the Lambda Function does."
}

variable "lambda_log_retention" {
  type        = number
  default     = 30
  description = "Specifies the number of days you want to retain log events in the specified log group."
}

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
