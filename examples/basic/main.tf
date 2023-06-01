module "export" {
  source = "../../"

  namespace   = "exl"
  environment = "dev"
  name        = "rds-export"
}
