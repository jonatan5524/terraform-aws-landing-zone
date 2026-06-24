# environments/management/outputs.tf
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.this.id
}

output "state_bucket_name" {
  description = "The name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.state.id
}

output "organizational_units" {
  description = "Map of Organizational Unit names to their IDs"
  value       = { for k, v in aws_organizations_organizational_unit.ou : k => v.id }
}

output "sso_permission_set_arns" {
  description = "ARNs of the created SSO Permission Sets"
  value       = module.sso_permission_sets.permission_set_arns
}

output "sso_instance_arn" {
  description = "The ARN of the SSO Instance"
  value       = module.sso_permission_sets.sso_instance_arn
}

output "sso_group_ids" {
  description = "Map of SSO group display names to their Identity Store group IDs"
  value       = module.sso_permission_sets.group_ids
}

output "management_account_id" {
  description = "The AWS account ID of the management account"
  value       = data.aws_caller_identity.current.account_id
}
