module "bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.2"

  sse_algorithm      = "aws:kms"
  kms_master_key_arn = module.kms_key.key_arn

  context = module.this.context
}
