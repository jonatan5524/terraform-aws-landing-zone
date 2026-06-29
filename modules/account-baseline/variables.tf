# modules/account-baseline/variables.tf
variable "management_account_id" {
  type        = string
  description = "AWS account ID of the management account, used to scope TerraformExecutionRole trust policy"
}

variable "state_bucket_name" {
  type        = string
  description = "Name for the Terraform state S3 bucket in this account"
}
