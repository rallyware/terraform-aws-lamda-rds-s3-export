locals {
  enabled    = module.this.enabled
  lambda_src = "${path.module}/lambda"
}

resource "random_id" "build" {
  count = local.enabled ? 1 : 0

  byte_length = 8
  keepers = {
    hash = filesha256("${local.lambda_src}/main.py")
  }
}

data "archive_file" "build" {
  count = local.enabled ? 1 : 0

  source_dir  = local.lambda_src
  output_path = "/tmp/${random_id.build[0].hex}.zip"
  type        = "zip"
}

module "lambda" {
  source  = "rallyware/lambda-function/aws"
  version = "0.1.0"

  handler       = "main.lambda_handler"
  filename      = one(data.archive_file.build[*].output_path)
  description   = var.lambda_description
  runtime       = var.lambda_runtime
  architectures = var.lambda_architectures
  memory_size   = var.lambda_memory
  timeout       = var.lambda_timeout

  custom_iam_policy_arns = [
    var.lambda_policy_arn,
  ]

  cloudwatch_logs_retention_in_days = var.lambda_log_retention
  cloudwatch_event_rules = [
    {
      name = "rds-automated-snapshot-created"
      event_pattern = jsonencode({
        detail-type = ["RDS DB Snapshot Event"],
        detail = {
          Message = ["Automated snapshot created"]
        }
      })
    }
  ]

  lambda_environment = {
    variables = {
      BACKUP_S3_BUCKET   = module.bucket.bucket_id
      BACKUP_KMS_KEY     = module.kms_key.key_id
      BACKUP_EXPORT_ROLE = module.role.name
      BACKUP_FOLDER      = var.s3_prefix
    }
  }

  context = module.this.context
}

module "kms_key" {
  source                  = "cloudposse/kms-key/aws"
  version                 = "0.12.1"
  name                    = "key-key-lrs3"
  description             = "kms-key-lambda-rds-s3"
  deletion_window_in_days = 7
  enable_key_rotation     = false
  context                 = module.this.context
}

module "bucket" {
  source                       = "cloudposse/s3-bucket/aws"
  version                      = "3.1.1"
  acl                          = "private"
  user_enabled                 = true
  force_destroy                = true
  versioning_enabled           = false
  allow_encrypted_uploads_only = true
  sse_algorithm                = "aws:kms"
  name                         = var.names
  lifecycle_rules              = var.lifecycle_rules
  kms_master_key_arn           = module.kms_key.key_arn
  allowed_bucket_actions       = var.allowed_bucket_actions
  object_lock_configuration    = var.object_lock_configuration
  context                      = module.this.context

  lifecycle_configuration_rules = var.lifecycle_configuration_rules
}

module "role" {
  source       = "cloudposse/iam-role/aws"
  version      = "0.18.0"
  name         = var.names
  principals   = var.principals
  use_fullname = true

  policy_documents = [
    join("", data.aws_iam_policy_document.resource_full_access[*].json),
    join("", data.aws_iam_policy_document.base[*].json)
  ]

  policy_document_count = 2
  policy_description    = "IAM policy"
  role_description      = "IAM role"

  context = module.this.context
}
