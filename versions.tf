terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.57"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.3"
    }
  }

  required_version = ">= 1.3.9"
}
