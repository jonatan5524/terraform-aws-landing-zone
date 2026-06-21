# environments/dev/provider.tf

terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn = "arn:aws:iam::${var.dev_account_id}:role/OrganizationAccountAccessRole"
  }

  default_tags {
    tags = {
      Project   = "aws-landing-zone"
      ManagedBy = "terraform"
      CostCenter = "free-tier"
    }
  }
}
