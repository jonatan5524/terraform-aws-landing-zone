# environments/accounts/account_log_archive.tf
resource "aws_organizations_account" "log_archive" {
  name      = "Log Archive"
  email     = "jonatan5524+logarchive@gmail.com"
  parent_id = data.terraform_remote_state.management.outputs.organizational_units["Security"]
}

resource "time_sleep" "wait_60_seconds_log_archive" {
  depends_on = [aws_organizations_account.log_archive]
  create_duration = "60s"
}

provider "aws" {
  alias  = "log_archive"
  region = "us-east-1"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.log_archive.id}:role/OrganizationAccountAccessRole"
  }
}

module "baseline_log_archive" {
  source = "../../modules/account-baseline"
  depends_on = [time_sleep.wait_60_seconds_log_archive]
  providers = {
    aws = aws.log_archive
  }
}
