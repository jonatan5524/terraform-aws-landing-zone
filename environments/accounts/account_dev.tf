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
  source     = "../../modules/account-baseline"
  depends_on = [time_sleep.wait_60_seconds_dev]
  providers = {
    aws = aws.dev
  }
}

module "sso_assignment_dev" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = aws_organizations_account.dev.id
  group_id            = data.aws_identitystore_group.developers.id
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["PowerUserAccess"]]
}
