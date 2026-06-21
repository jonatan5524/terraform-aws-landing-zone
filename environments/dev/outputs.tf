# environments/dev/outputs.tf

output "vpc_id" {
  description = "ID of the dev VPC"
  value       = module.network.vpc_id
}

output "nat_instance_id" {
  description = "EC2 instance ID of the NAT instance (public subnet)"
  value       = module.network.nat_instance_id
}

output "nat_public_ip" {
  description = "Public IP of the NAT instance"
  value       = module.network.nat_public_ip
}

output "k3s_instance_id" {
  description = "EC2 instance ID of the K3s node (private subnet)"
  value       = aws_instance.k3s.id
}

output "k3s_private_ip" {
  description = "Private IP of the K3s node (connect via SSM Session Manager)"
  value       = aws_instance.k3s.private_ip
}
