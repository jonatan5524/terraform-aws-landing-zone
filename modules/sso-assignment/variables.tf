# modules/sso-assignment/variables.tf
variable "sso_instance_arn" {
  type        = string
  description = "ARN of the SSO instance"
}

variable "account_id" {
  type        = string
  description = "ID of the target AWS account"
}

variable "group_id" {
  type        = string
  description = "ID of the IAM Identity Store group"
}

variable "permission_set_arns" {
  type        = map(string)
  description = "Map of permission set name to ARN — keys are used as stable for_each identifiers"
}
