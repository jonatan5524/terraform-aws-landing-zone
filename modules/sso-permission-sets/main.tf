# modules/sso-permission-sets/main.tf
locals {
  instance_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_sets = {
    BillingAdministrator = "arn:aws:iam::aws:policy/job-function/Billing"
    SecurityAudit        = "arn:aws:iam::aws:policy/SecurityAudit"
    PowerUserAccess      = "arn:aws:iam::aws:policy/PowerUserAccess"
  }
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each     = local.permission_sets
  name         = each.key
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = local.permission_sets
  instance_arn       = local.instance_arn
  managed_policy_arn = each.value
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}
