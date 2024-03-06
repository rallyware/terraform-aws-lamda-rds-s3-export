module "kms_key" {
  source  = "cloudposse/kms-key/aws"
  version = "0.12.2"

  description             = var.key_description
  deletion_window_in_days = var.key_deletion

  context = module.this.context
}
