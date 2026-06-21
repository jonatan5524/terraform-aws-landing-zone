# environments/dev/variables.tf

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region to deploy into"
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR block for the dev VPC"
}

variable "environment_name" {
  type        = string
  default     = "dev"
  description = "Name of the environment (used in resource names and tags)"
}

variable "dev_account_id" {
  type        = string
  description = "AWS account ID of the dev account. Find it via: terraform -chdir=environments/accounts output -json account_ids"

  validation {
    condition     = can(regex("^[0-9]{12}$", var.dev_account_id))
    error_message = "dev_account_id must be a 12-digit AWS account ID."
  }
}
