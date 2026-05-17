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
