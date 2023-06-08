variable "lambda_runtime" {
  type        = string
  default     = "python3.9"
  description = "The runtime environment for the Lambda function you are uploading"
}

variable "lambda_architectures" {
  type        = list(string)
  default     = ["arm64"]
  description = "Instruction set architecture for AWS Lambda function"
}

variable "lambda_timeout" {
  type        = number
  default     = 5
  description = "The amount of time the Lambda Function has to run in seconds"
}

variable "lambda_memory" {
  type        = number
  default     = 128
  description = "Amount of memory in MB the Lambda Function can use at runtime"
}

variable "lambda_description" {
  type        = string
  default     = "This Lambda function automates RDS snapshot export to S3"
  description = "Description of what the Lambda Function does"
}

variable "lambda_log_retention" {
  type        = number
  default     = 30
  description = "Specifies the number of days you want to retain log events in the specified log group"
}

variable "lambda_policy_description" {
  type        = string
  default     = "IAM policy for role used by lambda that starts the export task"
  description = "The description of the IAM policy for the lambda role"
}

variable "lambda_role_description" {
  type        = string
  default     = "IAM role used by lambda that starts the export task"
  description = "The description of the IAM role for the lambda function"
}

variable "s3_folder" {
  type        = string
  default     = "instance"
  description = "The Amazon S3 bucket folder to use as path of the exported data"
}

variable "key_deletion" {
  type        = number
  default     = 14
  description = "Duration in days after which the key is deleted after destruction of the resource"
}

variable "key_description" {
  type        = string
  default     = "KMS key used by an export task"
  description = "The description of the key used by an export task"
}

variable "role_description" {
  type        = string
  default     = "IAM role used by an export task"
  description = "The description of the IAM role used by an export task"
}

variable "role_policy_description" {
  type        = string
  default     = "IAM policy for the role that is used by an export task"
  description = "The description of the IAM policy used by an export task"
}
