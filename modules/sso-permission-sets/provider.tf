# modules/sso-permission-sets/provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ssoadmin_instances" "this" {}
