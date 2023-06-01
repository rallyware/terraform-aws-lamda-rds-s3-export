data "aws_iam_policy_document" "export" {
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
}

module "role" {
  source  = "cloudposse/iam-role/aws"
  version = "0.18.0"

  role_description = var.export_role_description

  policy_description    = var.export_role_policy_description
  policy_document_count = 1
  policy_documents = [
    one(data.aws_iam_policy_document.export[*].json)
  ]

  principals = {
    "Service" : ["export.rds.amazonaws.com"]
  }

  attributes = ["role"]
  context    = module.this.context
}
