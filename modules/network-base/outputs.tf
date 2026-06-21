# modules/network-base/outputs.tf

output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.private.id
}

output "nat_instance_id" {
  description = "EC2 instance ID of the NAT instance"
  value       = aws_instance.nat.id
}

output "nat_public_ip" {
  description = "Public IP of the NAT instance (via EIP)"
  value       = aws_eip.nat.public_ip
}

output "private_cidr" {
  description = "CIDR block of the private subnet"
  value       = aws_subnet.private.cidr_block
}

output "ami_id" {
  description = "AMI ID used for EC2 instances in this module"
  value       = data.aws_ami.amazon_linux_2023.id
}
