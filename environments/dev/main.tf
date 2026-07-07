# environments/dev/main.tf

data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Project     = "aws-landing-zone"
    Environment = var.environment_name
    ManagedBy   = "terraform"
    CostCenter  = "free-tier"
  }
}

# ── Networking (VPC + NAT) ────────────────────────────────────────────────────

module "network" {
  source = "../../modules/network-base"

  name_prefix         = var.environment_name
  vpc_cidr            = var.vpc_cidr
  public_subnet_cidr  = "10.0.0.0/25"
  private_subnet_cidr = "10.0.0.128/25"
  tags                = local.common_tags
}

# ── IAM role for SSM Session Manager (no SSH keys needed) ────────────────────

resource "aws_iam_role" "k3s_ssm" {
  name                 = "${var.environment_name}-k3s-ssm-role"
  permissions_boundary = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/EC2InstanceBoundary"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })

  tags = merge(local.common_tags, { Name = "${var.environment_name}-k3s-ssm-role" })
}

resource "aws_iam_role_policy_attachment" "k3s_ssm" {
  role       = aws_iam_role.k3s_ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "k3s_ssm" {
  name = "${var.environment_name}-k3s-ssm-profile"
  role = aws_iam_role.k3s_ssm.name

  tags = merge(local.common_tags, { Name = "${var.environment_name}-k3s-ssm-profile" })
}

# ── Security group for K3s ────────────────────────────────────────────────────

resource "aws_security_group" "k3s" {
  name        = "${var.environment_name}-k3s-sg"
  description = "K3s node: VPC-internal inbound only, egress via NAT"
  vpc_id      = module.network.vpc_id

  ingress {
    description = "All traffic from private subnet only"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [module.network.private_cidr]
  }

  egress {
    description = "All outbound via NAT"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment_name}-k3s-sg" })
}

# ── K3s EC2 instance (t2.micro — Free Tier) ───────────────────────────────────

resource "aws_instance" "k3s" {
  ami                    = module.network.ami_id
  instance_type          = "t2.micro"
  subnet_id              = module.network.private_subnet_id
  vpc_security_group_ids = [aws_security_group.k3s.id]
  iam_instance_profile   = aws_iam_instance_profile.k3s_ssm.name

  metadata_options {
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  # NAT route must be in place before the bootstrap script reaches the internet
  depends_on = [module.network]

  user_data = <<-EOT
    #!/bin/bash
    set -euxo pipefail

    ATTEMPTS=0
    until curl -sfL https://get.k3s.io -o /tmp/k3s-install.sh; do
      ATTEMPTS=$((ATTEMPTS + 1))
      if [ "$ATTEMPTS" -ge 40 ]; then
        echo "NAT unavailable after 10 minutes, aborting"
        exit 1
      fi
      echo "NAT not ready, retrying in 15s (attempt $ATTEMPTS/40)..."
      sleep 15
    done
    chmod +x /tmp/k3s-install.sh
    /tmp/k3s-install.sh

    export KUBECONFIG=/etc/rancher/k3s/k3s.yaml

    until kubectl get nodes 2>/dev/null | grep -q ' Ready'; do
      sleep 5
    done
  EOT

  tags = merge(local.common_tags, { Name = "${var.environment_name}-k3s" })
}
