resource "aws_s3_bucket" "export" {
  bucket = "bucket-for-rds-snapshots-export"
}

resource "aws_s3_bucket_acl" "export" {
  bucket = aws_s3_bucket.export.id
  acl    = "private"
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
      "arn:aws:s3:::${aws_s3_bucket.export.id}",
      "arn:aws:s3:::${aws_s3_bucket.export.id}/*"
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

module "lambda" {
  source = "../../"

  s3_bucket_id         = aws_s3_bucket.export.id
  kms_key_id           = aws_kms_key.export.key_id
  export_task_role_arn = aws_iam_role.export.arn
  lambda_policy_arn    = aws_iam_policy.lambda.arn
}
