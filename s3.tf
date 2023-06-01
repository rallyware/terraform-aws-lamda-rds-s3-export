module "bucket" {
  source  = "cloudposse/s3-bucket/aws"
  version = "3.1.1"
  acl     = "private"

  attributes = ["storage"]
  context    = module.this.context
}
