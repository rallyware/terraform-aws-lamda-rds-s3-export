module "bucket" {
  source                        = "cloudposse/s3-bucket/aws"
  version                       = "3.1.1"
  acl                           = "private"
  user_enabled                  = true
  force_destroy                 = true
  versioning_enabled            = false
  allow_encrypted_uploads_only  = true
  sse_algorithm                 = var.sse_algorithm
  name                          = var.names
  lifecycle_rules               = var.lifecycle_rules
  kms_master_key_arn            = module.kms_key.key_arn
  allowed_bucket_actions        = var.allowed_bucket_actions
  object_lock_configuration     = var.object_lock_configuration
  context                       = module.this.context

  lifecycle_configuration_rules = var.lifecycle_configuration_rules
}
