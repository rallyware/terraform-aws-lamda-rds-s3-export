module "kms_key" {
  source                  = "cloudposse/kms-key/aws"
  version                 = "0.12.1"
  description             = var.key_description
  deletion_window_in_days = var.key_deletion
  enable_key_rotation     = false

  context = module.this.context
}
