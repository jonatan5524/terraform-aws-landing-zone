# environments/accounts/account_management.tf
module "sso_assignment_management_admins" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = data.aws_caller_identity.current.account_id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["management-admins"]
  permission_set_arns = {
    ManagementAdminAccess = data.terraform_remote_state.management.outputs.sso_permission_set_arns["ManagementAdminAccess"]
  }
}

module "sso_assignment_management_security_audit" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = data.aws_caller_identity.current.account_id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["security-audit"]
  permission_set_arns = {
    SecurityAudit = data.terraform_remote_state.management.outputs.sso_permission_set_arns["SecurityAudit"]
  }
}

module "sso_assignment_management_billing" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = data.aws_caller_identity.current.account_id
  group_id            = data.terraform_remote_state.management.outputs.sso_group_ids["billing"]
  permission_set_arns = {
    BillingAdministrator = data.terraform_remote_state.management.outputs.sso_permission_set_arns["BillingAdministrator"]
  }
}
