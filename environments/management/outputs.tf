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
