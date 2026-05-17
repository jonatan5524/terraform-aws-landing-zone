# modules/sso-assignment/main.tf
resource "aws_ssoadmin_account_assignment" "this" {
  for_each           = toset(var.permission_set_arns)
  instance_arn       = var.sso_instance_arn
  target_id          = var.account_id
  target_type        = "AWS_ACCOUNT"
  principal_id       = var.group_id
  principal_type     = "GROUP"
  permission_set_arn = each.value
}
