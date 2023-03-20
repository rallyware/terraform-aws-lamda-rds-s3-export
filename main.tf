locals {
  enabled = module.this.enabled
}

resource "random_id" "build_id" {
  count = local.enabled ? 1 : 0

  byte_length = 8
  keepers = {
    "hash" = filesha256("${path.module}/lambda/main.py")
  }
}

data "archive_file" "build" {
  count = local.enabled ? 1 : 0

  source_dir  = "${path.module}/lambda"
  output_path = "/tmp/${random_id.build_id[0].hex}.zip"
  type        = "zip"
}

module "lambda" {
  source = "git@github.com:rallyware/terraform-aws-lambda-function.git"

  filename = join("", data.archive_file.build.*.output_path)

  handler       = "main.lambda_handler"
  runtime       = "python3.9"
  architectures = ["arm64"]
  timeout       = 5

  custom_iam_policy_arns = [
    var.lambda_policy_arn,
  ]

  cloudwatch_logs_retention_in_days = 30
  cloudwatch_event_rules = [
    {
      name = "rds-snapshot-created"
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
