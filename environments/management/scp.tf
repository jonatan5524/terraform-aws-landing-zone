# SCP: Deny Expensive Services
data "aws_iam_policy_document" "deny_expensive_services" {
  statement {
    sid       = "DenyExpensiveServices"
    effect    = "Deny"
    actions   = ["ec2:CreateNatGateway", "eks:CreateCluster"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "deny_expensive_services" {
  name        = "deny-expensive-services"
  description = "Prevents creation of expensive non-free-tier services like NAT Gateways and EKS clusters"
  content     = data.aws_iam_policy_document.deny_expensive_services.json
}

# SCP: Restrict Instance Types
data "aws_iam_policy_document" "restrict_instance_types" {
  statement {
    sid       = "RestrictInstanceTypes"
    effect    = "Deny"
    actions   = ["ec2:RunInstances"]
    resources = ["arn:aws:ec2:*:*:instance/*"]

    condition {
      test     = "StringNotEquals"
      variable = "ec2:InstanceType"
      values   = ["t2.micro", "t3.micro"]
    }
  }
}

resource "aws_organizations_policy" "restrict_instance_types" {
  name        = "restrict-instance-types"
  description = "Restricts EC2 instance types to only free-tier eligible types (t2.micro, t3.micro)"
  content     = data.aws_iam_policy_document.restrict_instance_types.json
}

# SCP: Deny Non-Approved Regions
data "aws_iam_policy_document" "deny_non_approved_regions" {
  statement {
    sid       = "DenyNonApprovedRegions"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1", "il-central-1"]
    }

    # Global services that don't operate in a specific region
    condition {
      test     = "StringNotLike"
      variable = "aws:PrincipalARN"
      values   = ["arn:aws:iam::*:root"]
    }
  }

  statement {
    sid    = "AllowGlobalServices"
    effect = "Allow"
    actions = [
      "iam:*",
      "sts:*",
      "cloudfront:*",
      "route53:*",
      "budgets:*",
      "organizations:*",
      "support:*",
      "trustedadvisor:*",
      "health:*",
      "account:*",
    ]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "deny_non_approved_regions" {
  name        = "deny-non-approved-regions"
  description = "Restricts all AWS actions to us-east-1 and il-central-1 only, with exemptions for global services"
  content     = data.aws_iam_policy_document.deny_non_approved_regions.json
}

# SCP: Deny Root Account Usage
data "aws_iam_policy_document" "deny_root_usage" {
  statement {
    sid       = "DenyRootUsage"
    effect    = "Deny"
    actions   = ["*"]
    resources = ["*"]

    condition {
      test     = "StringLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::*:root"]
    }
  }
}

resource "aws_organizations_policy" "deny_root_usage" {
  name        = "deny-root-usage"
  description = "Blocks all actions performed by the root user in member accounts"
  content     = data.aws_iam_policy_document.deny_root_usage.json
}

# SCP: Deny CloudTrail Tampering
data "aws_iam_policy_document" "deny_cloudtrail_tampering" {
  statement {
    sid    = "DenyCloudTrailTampering"
    effect = "Deny"
    actions = [
      "cloudtrail:DeleteTrail",
      "cloudtrail:StopLogging",
      "cloudtrail:UpdateTrail",
      "cloudtrail:PutEventSelectors",
    ]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "deny_cloudtrail_tampering" {
  name        = "deny-cloudtrail-tampering"
  description = "Prevents disabling or modifying CloudTrail audit trails"
  content     = data.aws_iam_policy_document.deny_cloudtrail_tampering.json
}

# SCP: Deny Leave Organization
data "aws_iam_policy_document" "deny_leave_organization" {
  statement {
    sid       = "DenyLeaveOrganization"
    effect    = "Deny"
    actions   = ["organizations:LeaveOrganization"]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "deny_leave_organization" {
  name        = "deny-leave-organization"
  description = "Prevents member accounts from leaving the AWS Organization and escaping SCP guardrails"
  content     = data.aws_iam_policy_document.deny_leave_organization.json
}

# SCP: Deny Expensive Storage and Databases
data "aws_iam_policy_document" "deny_expensive_storage_and_db" {
  statement {
    sid    = "DenyNoFreeTierServices"
    effect = "Deny"
    actions = [
      "elasticache:CreateCacheCluster",
      "elasticache:CreateReplicationGroup",
      "es:CreateDomain",
      "opensearch:CreateDomain",
    ]
    resources = ["*"]
  }

  statement {
    sid       = "DenyNonMicroRDS"
    effect    = "Deny"
    actions   = ["rds:CreateDBInstance"]
    resources = ["*"]

    condition {
      test     = "StringNotLike"
      variable = "rds:DatabaseClass"
      values   = ["db.t2.micro", "db.t3.micro"]
    }
  }
}

resource "aws_organizations_policy" "deny_expensive_storage_and_db" {
  name        = "deny-expensive-storage-and-db"
  description = "Blocks ElastiCache, OpenSearch, and non-free-tier RDS instance classes"
  content     = data.aws_iam_policy_document.deny_expensive_storage_and_db.json
}

# SCP: Deny IAM Users and Long-Lived Keys
data "aws_iam_policy_document" "deny_iam_users_and_keys" {
  statement {
    sid    = "DenyIAMUsersAndKeys"
    effect = "Deny"
    actions = [
      "iam:CreateUser",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
    ]
    resources = ["*"]
  }
}

resource "aws_organizations_policy" "deny_iam_users_and_keys" {
  name        = "deny-iam-users-and-keys"
  description = "Enforces SSO+OIDC-only identity by blocking IAM user and static credential creation"
  content     = data.aws_iam_policy_document.deny_iam_users_and_keys.json
}

# Attach SCPs to all OUs
resource "aws_organizations_policy_attachment" "deny_expensive_services" {
  for_each  = aws_organizations_organizational_unit.ou
  policy_id = aws_organizations_policy.deny_expensive_services.id
  target_id = each.value.id
}

resource "aws_organizations_policy_attachment" "restrict_instance_types" {
  for_each  = aws_organizations_organizational_unit.ou
  policy_id = aws_organizations_policy.restrict_instance_types.id
  target_id = each.value.id
}

resource "aws_organizations_policy_attachment" "deny_non_approved_regions" {
  for_each  = aws_organizations_organizational_unit.ou
  policy_id = aws_organizations_policy.deny_non_approved_regions.id
  target_id = each.value.id
}

resource "aws_organizations_policy_attachment" "deny_root_usage" {
  for_each  = aws_organizations_organizational_unit.ou
  policy_id = aws_organizations_policy.deny_root_usage.id
  target_id = each.value.id
}

resource "aws_organizations_policy_attachment" "deny_cloudtrail_tampering" {
  for_each  = aws_organizations_organizational_unit.ou
  policy_id = aws_organizations_policy.deny_cloudtrail_tampering.id
  target_id = each.value.id
}

resource "aws_organizations_policy_attachment" "deny_leave_organization" {
  for_each  = aws_organizations_organizational_unit.ou
  policy_id = aws_organizations_policy.deny_leave_organization.id
  target_id = each.value.id
}

resource "aws_organizations_policy_attachment" "deny_expensive_storage_and_db" {
  for_each  = aws_organizations_organizational_unit.ou
  policy_id = aws_organizations_policy.deny_expensive_storage_and_db.id
  target_id = each.value.id
}

resource "aws_organizations_policy_attachment" "deny_iam_users_and_keys" {
  for_each  = aws_organizations_organizational_unit.ou
  policy_id = aws_organizations_policy.deny_iam_users_and_keys.id
  target_id = each.value.id
}
