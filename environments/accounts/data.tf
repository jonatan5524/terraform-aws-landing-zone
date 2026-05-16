# environments/accounts/data.tf
data "terraform_remote_state" "management" {
  backend = "s3"
  config = {
    bucket = "pomeloinfra-tf-state-backend"
    key    = "management/terraform.tfstate"
    region = "us-east-1"
  }
}
