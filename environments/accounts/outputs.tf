# environments/accounts/outputs.tf

output "account_ids" {
  description = "Map of account names to their AWS account IDs"
  value = {
    dev             = aws_organizations_account.dev.id
    log_archive     = aws_organizations_account.log_archive.id
    shared_services = aws_organizations_account.shared_services.id
  }
}
