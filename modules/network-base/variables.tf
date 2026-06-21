# modules/network-base/variables.tf

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/24"
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  default     = "10.0.0.0/25"
  description = "CIDR block for the public subnet (must be within vpc_cidr)"
}

variable "private_subnet_cidr" {
  type        = string
  default     = "10.0.0.128/25"
  description = "CIDR block for the private subnet (must be within vpc_cidr)"
}

variable "name_prefix" {
  type        = string
  description = "Prefix applied to all resource Name tags"
}

variable "nat_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "EC2 instance type for the NAT instance (must remain Free Tier eligible)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to all resources"
}
