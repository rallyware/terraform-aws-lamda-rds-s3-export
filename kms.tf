module "kms_key" {
  source                  = "cloudposse/kms-key/aws"
  version                 = "0.12.1"
  description             = var.export_key_description
  deletion_window_in_days = var.export_key_deletion
  enable_key_rotation     = false

  attributes = ["key"]
  context    = module.this.context
}
