# environments/accounts/data.tf
data "terraform_remote_state" "management" {
  backend = "s3"
  config = {
    bucket = "pomeloinfra-tf-state-backend"
    key    = "management/terraform.tfstate"
    region = "us-east-1"
  }
}

data "aws_ssoadmin_instances" "this" {}

data "aws_identitystore_group" "developers" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "developers"
    }
  }
}
