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
