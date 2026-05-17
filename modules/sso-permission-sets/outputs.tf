# modules/sso-permission-sets/outputs.tf
output "permission_set_arns" {
  description = "Map of permission set names to their ARNs"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}

output "sso_instance_arn" {
  description = "The ARN of the SSO Instance"
  value       = local.instance_arn
}
