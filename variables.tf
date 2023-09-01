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

variable "cloudwatch_event_rules" {
  type = list(object(
    {
      name = string
      event_pattern = object(
        {
          detail_type = list(string)
          detail = object(
            {
              message = list(string)
            }
          )
        }
      )
    }
  ))
  default = [
    {
      event_pattern = {
        detail = {
          message = ["Automated snapshot created"]
        }
        detail_type = ["RDS DB Snapshot Event"]
      }
      name = "rds-automated-snapshot-created"
    }
  ]
  description = "A list of CloudWatch Event Rules to trigger the Lambda function"
}

variable "s3_folder" {
  type        = string
  default     = "instance"
  description = "The Amazon S3 bucket folder to use as path of the exported data"
}

variable "s3_lifecycle_configuration_rules" {
  type = list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload_days = number

    filter_and = any
    expiration = any
    transition = list(any)

    noncurrent_version_expiration = any
    noncurrent_version_transition = list(any)
  }))
  default     = []
  description = "A list of lifecycle V2 rules"
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

variable "allowed_kms_aliases" {
  type        = list(string)
  default     = ["alias/*rds*"]
  description = "A list of KMS aliases that are allowed to be used by the lambda function"
}
