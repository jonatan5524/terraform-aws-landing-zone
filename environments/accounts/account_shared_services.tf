# environments/accounts/account_shared_services.tf
resource "aws_organizations_account" "shared_services" {
  name      = "Shared Services"
  email     = "jonatan5524+sharedservices@gmail.com"
  parent_id = data.terraform_remote_state.management.outputs.organizational_units["Infrastructure"]
}

provider "aws" {
  alias  = "shared_services"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.shared_services.id}:role/OrganizationAccountAccessRole"
  }
}

module "baseline_shared_services" {
  source = "../../modules/account-baseline"
  providers = {
    aws = aws.shared_services
  }
}
