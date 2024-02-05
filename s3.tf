module "bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.0.1"

  sse_algorithm      = "aws:kms"
  kms_master_key_arn = module.kms_key.key_arn

  lifecycle_configuration_rules = var.s3_lifecycle_rules.enabled ? [{
    enabled = true
    id      = "rds-s3-export-expiration"

    abort_incomplete_multipart_upload_days = 3

    filter_and = null

    expiration = var.s3_lifecycle_rules.expiration_days > 0 ? {
      days = var.s3_lifecycle_rules.expiration_days
    } : null

    transition = var.s3_lifecycle_rules.glacier_transition_days > 0 ? [{
      days          = var.s3_lifecycle_rules.glacier_transition_days
      storage_class = "GLACIER"
    }] : []

    noncurrent_version_expiration = var.s3_lifecycle_rules.noncurrent_expiration_days > 0 ? {
      noncurrent_days = var.s3_lifecycle_rules.noncurrent_expiration_days
    } : {}

    noncurrent_version_transition = []
  }] : []

  context = module.this.context
}
