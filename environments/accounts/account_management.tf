# environments/accounts/account_management.tf
module "sso_assignment_management_platform_engineers" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = data.aws_caller_identity.current.account_id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["platform-engineers"]
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["PowerUserAccess"]]
}

module "sso_assignment_management_security_audit" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = data.aws_caller_identity.current.account_id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["security-audit"]
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["SecurityAudit"]]
}

module "sso_assignment_management_billing" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = data.aws_caller_identity.current.account_id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["billing"]
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["BillingAdministrator"]]
}
