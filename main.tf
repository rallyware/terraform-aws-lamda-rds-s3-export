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
    aws_iam_policy.lambda.arn
  ]

  cloudwatch_logs_retention_in_days = var.lambda_log_retention
  cloudwatch_event_rules = [
    {
      name = "rds-manual-snapshot-created"
      event_pattern = jsonencode({
        detail-type = ["RDS DB Snapshot Event"],
        detail = {
          Message = ["Manual snapshot created"]
        }
      })
    }
  ]

  lambda_environment = {
    variables = {
      BACKUP_S3_BUCKET   = module.bucket.bucket_id
      BACKUP_KMS_KEY     = module.kms_key.key_id
      BACKUP_EXPORT_ROLE = aws_iam_role.export.arn
      BACKUP_FOLDER      = aws_iam_policy.lambda.arn
    }
  }

  context = module.this.context
}
