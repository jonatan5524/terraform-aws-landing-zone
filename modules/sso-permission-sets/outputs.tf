# modules/sso-permission-sets/outputs.tf
output "permission_set_arns" {
  description = "Map of permission set names to their ARNs"
  value = merge(
    { for k, v in aws_ssoadmin_permission_set.this : k => v.arn },
    {
      PlatformEngineerAccess = aws_ssoadmin_permission_set.platform_engineer.arn
      DeveloperAccess        = aws_ssoadmin_permission_set.developer.arn
    }
  )
}

output "sso_instance_arn" {
  description = "The ARN of the SSO Instance"
  value       = local.instance_arn
}

output "group_ids" {
  description = "Map of group display names to their Identity Store IDs"
  value       = { for k, v in aws_identitystore_group.this : k => v.group_id }
}
