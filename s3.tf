module "bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "4.0.1"

  sse_algorithm      = "aws:kms"
  kms_master_key_arn = module.kms_key.key_arn

  lifecycle_configuration_rules = [{
    enabled = var.s3_lifecycle_rules.enabled
    id      = "rds-s3-export-expiration"

    abort_incomplete_multipart_upload_days = 3

    filter_and = null

    expiration = {
      days = var.s3_lifecycle_rules.expiration_days
    }
    transition = var.s3_lifecycle_rules.glacier_transition_days > 0 ? [{
      days          = var.s3_lifecycle_rules.glacier_transition_days
      storage_class = "GLACIER"
    }] : null

    noncurrent_version_expiration = {
      noncurrent_days = 7
    }
    noncurrent_version_transition = null
  }]

  context = module.this.context
}
