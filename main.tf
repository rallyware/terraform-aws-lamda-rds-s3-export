locals {
  enabled            = module.this.enabled
  lambda_src         = "${path.module}/lambda"
  lambda_policy_name = join(module.this.delimiter, [module.this.id])
  lambda_policy_arn  = one(aws_iam_policy.lambda[*].arn)
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

data "aws_iam_policy_document" "lambda" {
  count = local.enabled ? 1 : 0

  version = "2012-10-17"

  statement {
    sid = "AllowExportDescribeSnapshot"
    actions = [
      "rds:StartExportTask",
      "rds:DescribeDBSnapshots"
    ]
    resources = [
      "*"
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowGetPassRole"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [
      module.role.arn
    ]
    effect = "Allow"
  }

  statement {
    sid = "AllowExportKeyKMS"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:GenerateDataKeyWithoutPlaintext",
      "kms:ReEncryptFrom",
      "kms:ReEncryptTo",
      "kms:CreateGrant",
      "kms:DescribeKey",
      "kms:RetireGrant",
    ]
    resources = [
      module.kms_key.key_arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "lambda" {
  count = local.enabled ? 1 : 0

  name   = local.lambda_policy_name
  policy = data.aws_iam_policy_document.lambda[0].json
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
    local.lambda_policy_arn
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
      BACKUP_FOLDER      = var.s3_folder
      BACKUP_KMS_KEY     = module.kms_key.key_id
      BACKUP_EXPORT_ROLE = module.role.arn
    }
  }

  context = module.this.context
}
