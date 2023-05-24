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

variable "s3_prefix" {
  type        = string
  default     = "RDS"
  description = "The Amazon S3 bucket prefix to use as the file name and path of the exported data"
}

variable "lambda_policy_arn" {
  type        = string
  description = "The ARN of custom IAM policy for lambda function that starts snapshot export task"
}

variable "use_fullname" {
  type        = bool
  description = "Set 'true' to use `namespace-stage-name` for ecr repository name, else `name`"
  default     = true
}

variable "principals" {
  type        = map(list(string))
  description = "Map of service name as key and a list of ARNs to allow assuming the role as value (e.g. map(`AWS`, list(`arn:aws:iam:::role/admin`)))"
  default = {
    "AWS" : ["*"]
  }
}

variable "names" {
  type        = string
  description = "Bucket name and IAM name"
}

variable "lifecycle_configuration_rules" {
  type = list(object({
    enabled = bool
    id      = string

    abort_incomplete_multipart_upload_days = number

    # `filter_and` is the `and` configuration block inside the `filter` configuration.
    # This is the only place you should specify a prefix.
    filter_and = any
    expiration = any
    transition = list(any)

    noncurrent_version_expiration = any
    noncurrent_version_transition = list(any)
  }))
  default     = []
  description = "A list of lifecycle V2 rules"
}

variable "lifecycle_rules" {
  type = list(object({
    prefix  = string
    enabled = bool
    tags    = map(string)

    enable_glacier_transition            = bool
    enable_deeparchive_transition        = bool
    enable_standard_ia_transition        = bool
    enable_current_object_expiration     = bool
    enable_noncurrent_version_expiration = bool

    abort_incomplete_multipart_upload_days         = number
    noncurrent_version_glacier_transition_days     = number
    noncurrent_version_deeparchive_transition_days = number
    noncurrent_version_expiration_days             = number

    standard_transition_days    = number
    glacier_transition_days     = number
    deeparchive_transition_days = number
    expiration_days             = number
  }))
  default = [{
    prefix  = ""
    enabled = false
    tags    = {}

    enable_glacier_transition            = true
    enable_deeparchive_transition        = false
    enable_standard_ia_transition        = false
    enable_current_object_expiration     = true
    enable_noncurrent_version_expiration = true

    abort_incomplete_multipart_upload_days         = 90
    noncurrent_version_glacier_transition_days     = 30
    noncurrent_version_deeparchive_transition_days = 60
    noncurrent_version_expiration_days             = 90

    standard_transition_days    = 30
    glacier_transition_days     = 60
    deeparchive_transition_days = 90
    expiration_days             = 90
  }]

  description = "A list of lifecycle rules."
}

variable "allowed_bucket_actions" {
  type        = list(string)
  default     = ["s3:PutObject", "s3:PutObjectAcl", "s3:GetObject", "s3:DeleteObject", "s3:ListBucket", "s3:ListBucketMultipartUploads", "s3:GetBucketLocation", "s3:AbortMultipartUpload"]
  description = "List of actions the user is permitted to perform on the S3 bucket"
}

variable "object_lock_configuration" {
  type = object({
    mode  = string # Valid values are GOVERNANCE and COMPLIANCE.
    days  = number
    years = number
  })
  default     = null
  description = "A configuration for S3 object locking. With S3 Object Lock, you can store objects using a `write once, read many` (WORM) model. Object Lock can help prevent objects from being deleted or overwritten for a fixed amount of time or indefinitely."
}