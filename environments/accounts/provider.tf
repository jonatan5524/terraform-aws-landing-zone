# environments/accounts/provider.tf
terraform {
  required_version = ">= 1.10.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  default_tags {
    tags = {
      Project     = "PomeloInfra-LandingZone"
      Environment = "Accounts"
      ManagedBy   = "Terraform"
    }
  }
}
