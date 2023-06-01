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

variable "export_key_deletion" {
  type        = number
  default     = 14
  description = "Duration in days after which the key is deleted after destruction of the resource"
}

variable "export_key_description" {
  type        = string
  default     = "KMS key used by export task"
  description = "The description of the key as viewed in AWS console"
}

variable "export_role_description" {
  type        = string
  default     = "IAM role used by export task"
  description = "The description of the IAM role that is visible in the IAM role manager"
}

variable "export_role_policy_description" {
  type        = string
  default     = "IAM policy for role that used by export task"
  description = "The description of the IAM policy that is visible in the IAM policy manager"
}
