# environments/accounts/account_log_archive.tf
resource "aws_organizations_account" "log_archive" {
  name      = "Log Archive"
  email     = "jonatan5524+logarchive@gmail.com"
  parent_id = data.terraform_remote_state.management.outputs.organizational_units["Security"]
}

resource "time_sleep" "wait_60_seconds_log_archive" {
  depends_on      = [aws_organizations_account.log_archive]
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
  source                = "../../modules/account-baseline"
  depends_on            = [time_sleep.wait_60_seconds_log_archive]
  management_account_id = data.aws_caller_identity.current.account_id
  state_bucket_name     = "pomeloinfra-tf-state-log-archive"
  providers = {
    aws = aws.log_archive
  }
}

module "sso_assignment_log_archive_security_audit" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = aws_organizations_account.log_archive.id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["security-audit"]
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["SecurityAudit"]]
}
