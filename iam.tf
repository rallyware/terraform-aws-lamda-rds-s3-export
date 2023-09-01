data "aws_iam_policy_document" "task" {
  count = local.enabled ? 1 : 0

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

  statement {
    sid = "AllowKMSByAlias"
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    condition {
      test     = "StringLike"
      variable = "kms:RequestAlias"
      values   = var.allowed_kms_aliases
    }

    resources = ["*"]
  }
}

module "role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.19.0"

  role_description      = var.role_description
  policy_description    = var.role_policy_description
  policy_document_count = 1
  policy_documents = [
    one(data.aws_iam_policy_document.task[*].json)
  ]

  principals = {
    "Service" : ["export.rds.amazonaws.com"]
  }

  attributes = concat(module.this.attributes, ["task"])

  context = module.this.context
}
