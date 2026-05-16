# environments/accounts/backend.tf
terraform {
  backend "s3" {
    bucket       = "pomeloinfra-tf-state-backend"
    key          = "accounts/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
