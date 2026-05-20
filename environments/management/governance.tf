resource "aws_budgets_budget" "zero_spend" {
  name         = "zero-spend-budget"
  budget_type  = "COST"
  limit_amount = "0.01"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_notification_email]
  }
}

resource "aws_budgets_budget" "free_tier_compute" {
  name         = "free-tier-compute-budget"
  budget_type  = "USAGE"
  limit_amount = "750"
  limit_unit   = "Hrs"
  time_unit    = "MONTHLY"

  cost_filter {
    name = "Service"
    values = [
      "Amazon Elastic Compute Cloud - Compute",
    ]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_notification_email]
  }
}

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
