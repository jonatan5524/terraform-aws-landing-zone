# environments/accounts/account_shared_services.tf
resource "aws_organizations_account" "shared_services" {
  name      = "Shared Services"
  email     = "jonatan5524+sharedservices@gmail.com"
  parent_id = data.terraform_remote_state.management.outputs.organizational_units["Infrastructure"]
}

resource "time_sleep" "wait_60_seconds_shared_services" {
  depends_on      = [aws_organizations_account.shared_services]
  create_duration = "60s"
}

provider "aws" {
  alias  = "shared_services"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.shared_services.id}:role/OrganizationAccountAccessRole"
  }
}

module "baseline_shared_services" {
  source     = "../../modules/account-baseline"
  depends_on = [time_sleep.wait_60_seconds_shared_services]
  providers = {
    aws = aws.shared_services
  }
}
