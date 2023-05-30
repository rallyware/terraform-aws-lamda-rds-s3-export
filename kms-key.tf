module "kms_key" {
  source                  = "cloudposse/kms-key/aws"
  version                 = "0.12.1"
  name                    = "${var.names}-backup-kms-key"
  description             = var.kms_description
  deletion_window_in_days = 7
  enable_key_rotation     = false
  context                 = module.this.context
}
