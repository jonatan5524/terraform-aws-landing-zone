# environments/accounts/account_dev.tf
resource "aws_organizations_account" "dev" {
  name      = "Dev"
  email     = "jonatan5524+dev@gmail.com"
  parent_id = data.terraform_remote_state.management.outputs.organizational_units["Workloads"]
}

resource "time_sleep" "wait_60_seconds_dev" {
  depends_on = [aws_organizations_account.dev]
  create_duration = "60s"
}

provider "aws" {
  alias  = "dev"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.dev.id}:role/OrganizationAccountAccessRole"
  }
}

module "baseline_dev" {
  source = "../../modules/account-baseline"
  depends_on = [time_sleep.wait_60_seconds_dev]
  providers = {
    aws = aws.dev
  }
}
