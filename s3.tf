module "bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

  sse_algorithm                 = "aws:kms"
  kms_master_key_arn            = module.kms_key.key_arn
  lifecycle_configuration_rules = var.s3_lifecycle_configuration_rules

  context = module.this.context
}
