locals {
  enabled = module.this.enabled

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
  count = local.enabled ? 1 : 0

  source  = "rallyware/lambda-function/aws"
  version = "0.1.0"

  handler       = "main.lambda_handler"
  filename      = data.archive_file.build[0].output_path
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
      BACKUP_S3_BUCKET   = var.s3_bucket_id
      BACKUP_KMS_KEY     = var.kms_key_id
      BACKUP_EXPORT_ROLE = var.export_task_role_arn
      BACKUP_FOLDER      = var.s3_prefix
    }
  }

  context = module.this.context
}
