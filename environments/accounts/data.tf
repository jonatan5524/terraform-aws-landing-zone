# environments/accounts/data.tf
data "aws_caller_identity" "current" {}

data "terraform_remote_state" "management" {
  backend = "s3"
  config = {
    bucket = "pomeloinfra-tf-state-backend"
    key    = "management/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ssoadmin_instances" "this" {}
