# modules/sso-permission-sets/main.tf
locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  managed_permission_sets = {
    BillingAdministrator = "arn:aws:iam::aws:policy/job-function/Billing"
    SecurityAudit        = "arn:aws:iam::aws:policy/SecurityAudit"
    PowerUserAccess      = "arn:aws:iam::aws:policy/PowerUserAccess"
  }

  groups = ["platform-engineers", "developers", "security-audit", "billing", "management-admins"]
}

data "aws_ssoadmin_instances" "this" {}

resource "aws_identitystore_group" "this" {
  for_each          = toset(local.groups)
  display_name      = each.key
  description       = "${each.key} group"
  identity_store_id = local.identity_store_id
}

# Managed-policy permission sets (billing, audit, management-account power user)
resource "aws_ssoadmin_permission_set" "this" {
  for_each     = local.managed_permission_sets
  name         = each.key
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = local.managed_permission_sets
  instance_arn       = local.instance_arn
  managed_policy_arn = each.value
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}

# PlatformEngineerAccess — PowerUserAccess + scoped IAM for EC2 instance profiles
resource "aws_ssoadmin_permission_set" "platform_engineer" {
  name         = "PlatformEngineerAccess"
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "platform_engineer" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
  permission_set_arn = aws_ssoadmin_permission_set.platform_engineer.arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "platform_engineer" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.platform_engineer.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "IAMInstanceProfileManagement"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:PutRolePermissionsBoundary",
        ]
        Resource = "*"
        # Enforce EC2InstanceBoundary on every role created by this identity
        Condition = {
          StringLike = {
            "iam:PermissionsBoundary" = "arn:aws:iam::*:policy/EC2InstanceBoundary"
          }
        }
      },
      {
        Sid      = "IAMReadOnly"
        Effect   = "Allow"
        Action   = ["iam:Get*", "iam:List*"]
        Resource = "*"
      },
      {
        Sid      = "PassRoleToEC2Only"
        Effect   = "Allow"
        Action   = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "ec2.amazonaws.com"
          }
        }
      },
      {
        Sid      = "AssumeTerraformExecutionRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::*:role/TerraformExecutionRole"
      }
    ]
  })
}

# ManagementAdminAccess — for the management account only.
# PowerUserAccess blocks iam:* and organizations:*, both of which Terraform needs
# in the management account to manage the org, SSO, SCPs, and state bucket.
resource "aws_ssoadmin_permission_set" "management_admin" {
  name         = "ManagementAdminAccess"
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "management_admin" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.management_admin.arn
}

# DeveloperAccess — read-only infra visibility + log tailing, no write permissions
resource "aws_ssoadmin_permission_set" "developer" {
  name         = "DeveloperAccess"
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_permission_set_inline_policy" "developer" {
  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.developer.arn
  inline_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InfraReadOnly"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "logs:GetLogEvents",
          "logs:FilterLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "cloudwatch:GetMetricData",
          "cloudwatch:ListMetrics",
        ]
        Resource = "*"
      }
    ]
  })
}
