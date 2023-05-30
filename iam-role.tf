data "aws_iam_policy_document" "resource_full_access" {
  count = local.enabled ? 1 : 0

  statement {
    sid       = "FullAccess"
    effect    = "Allow"
    resources = ["${module.bucket.bucket_arn}/*"]

    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:GetBucketLocation",
      "s3:AbortMultipartUpload"
    ]
  }
}

data "aws_iam_policy_document" "base" {
  count = local.enabled ? 1 : 0

  statement {
    sid    = "BaseAccess"
    effect = "Allow"

    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions"
    ]

    resources = [
      module.bucket.bucket_arn
    ]
  }
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
  policy_description    = "IAM policy for s3 bucket"
  role_description      = "IAM for s3 bucket"
  context               = module.this.context
}

resource "aws_kms_key" "export" {}

resource "aws_kms_alias" "export" {
  name          = "alias/rds-snapshot-export-key"
  target_key_id = aws_kms_key.export.key_id
}

data "aws_iam_policy_document" "export_assume" {
  version = "2012-10-17"

  statement {
    sid = "ExportAssumeRole"
    actions = [
      "sts:AssumeRole"
    ]
    principals {
      type = "Service"
      identifiers = [
        "export.rds.amazonaws.com"
      ]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "export" {
  version = "2012-10-17"

  statement {
    sid = "AllowS3"
    actions = [
      "s3:PutObject*",
      "s3:ListBucket",
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::${module.bucket.bucket_id}",
      "arn:aws:s3:::${module.bucket.bucket_id}/*"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "export" {
  name   = "export-task-policy"
  policy = data.aws_iam_policy_document.export.json
}

resource "aws_iam_role" "export" {
  name               = "export-task-role"
  assume_role_policy = data.aws_iam_policy_document.export_assume.json
}

resource "aws_iam_role_policy_attachment" "export" {
  role       = aws_iam_role.export.name
  policy_arn = aws_iam_policy.export.arn
}

data "aws_iam_policy_document" "lambda" {
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
      aws_iam_role.export.arn
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
      aws_kms_key.export.arn
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "lambda" {
  name   = "export-lambda-policy"
  policy = data.aws_iam_policy_document.lambda.json
}
