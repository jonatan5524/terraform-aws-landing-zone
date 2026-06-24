# environments/accounts/account_dev.tf
resource "aws_organizations_account" "dev" {
  name      = "Dev"
  email     = "jonatan5524+dev@gmail.com"
  parent_id = data.terraform_remote_state.management.outputs.organizational_units["Workloads"]
}

resource "time_sleep" "wait_60_seconds_dev" {
  depends_on      = [aws_organizations_account.dev]
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
  source                = "../../modules/account-baseline"
  depends_on            = [time_sleep.wait_60_seconds_dev]
  management_account_id = data.aws_caller_identity.current.account_id
  state_bucket_name     = "pomeloinfra-tf-state-dev"
  providers = {
    aws = aws.dev
  }
}

module "sso_assignment_dev_platform_engineers" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = aws_organizations_account.dev.id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["platform-engineers"]
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["PlatformEngineerAccess"]]
}

module "sso_assignment_dev_developers" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = aws_organizations_account.dev.id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["developers"]
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["DeveloperAccess"]]
}

module "sso_assignment_dev_security_audit" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = aws_organizations_account.dev.id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["security-audit"]
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["SecurityAudit"]]
}
