# SSO Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a decentralized AWS IAM Identity Center (SSO) configuration where Permission Sets are defined centrally in Management, but assignments are managed dynamically within individual Account Vending files.

**Architecture:** Split responsibility model. Management owns permission definitions via a new module. Accounts environment owns assignments via a reusable assignment module called from individual account files.

**Tech Stack:** Terraform 1.10+, AWS Provider 5.0+

---

### Task 1: Create SSO Permission Sets Module

**Files:**
- Create: `modules/sso-permission-sets/provider.tf`
- Create: `modules/sso-permission-sets/main.tf`
- Create: `modules/sso-permission-sets/outputs.tf`

- [ ] **Step 1: Define providers and data source**
```hcl
# modules/sso-permission-sets/provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

data "aws_ssoadmin_instances" "this" {}
```

- [ ] **Step 2: Define Permission Sets and attachments**
```hcl
# modules/sso-permission-sets/main.tf
locals {
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  permission_sets = {
    BillingAdministrator = "arn:aws:iam::aws:policy/job-function/Billing"
    SecurityAudit        = "arn:aws:iam::aws:policy/SecurityAudit"
    PowerUserAccess      = "arn:aws:iam::aws:policy/PowerUserAccess"
  }
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each     = local.permission_sets
  name         = each.key
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each           = local.permission_sets
  instance_arn       = local.instance_arn
  managed_policy_arn = each.value
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}
```

- [ ] **Step 3: Define Outputs**
```hcl
# modules/sso-permission-sets/outputs.tf
output "permission_set_arns" {
  description = "Map of permission set names to their ARNs"
  value       = { for k, v in aws_ssoadmin_permission_set.this : k => v.arn }
}

output "sso_instance_arn" {
  description = "The ARN of the SSO Instance"
  value       = local.instance_arn
}
```

- [ ] **Step 4: Commit**
```bash
git add modules/sso-permission-sets/*.tf
git commit -m "feat: create sso-permission-sets module"
```

---

### Task 2: Integrate Permission Sets into Management

**Files:**
- Modify: `environments/management/main.tf`
- Modify: `environments/management/outputs.tf`

- [x] **Step 1: Call the module in `main.tf`**
```hcl
module "sso_permission_sets" {
  source = "../../modules/sso-permission-sets"
}
```

- [x] **Step 2: Export ARNs in `outputs.tf`**
```hcl
output "sso_permission_set_arns" {
  description = "ARNs of the created SSO Permission Sets"
  value       = module.sso_permission_sets.permission_set_arns
}

output "sso_instance_arn" {
  description = "The ARN of the SSO Instance"
  value       = module.sso_permission_sets.sso_instance_arn
}
```

- [x] **Step 3: Apply and Commit**
Run: `terraform -chdir=environments/management init && terraform -chdir=environments/management apply -auto-approve`
```bash
git add environments/management/main.tf environments/management/outputs.tf
git commit -m "feat: integrate sso-permission-sets into management environment"
```

---

### Task 3: Create SSO Assignment Module

**Files:**
- Create: `modules/sso-assignment/provider.tf`
- Create: `modules/sso-assignment/variables.tf`
- Create: `modules/sso-assignment/main.tf`

- [ ] **Step 1: Define required providers**
```hcl
# modules/sso-assignment/provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

- [ ] **Step 2: Define Variables**
```hcl
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
  type        = list(string)
  description = "List of Permission Set ARNs to assign"
}
```

- [ ] **Step 3: Define Account Assignment**
```hcl
# modules/sso-assignment/main.tf
resource "aws_ssoadmin_account_assignment" "this" {
  for_each           = toset(var.permission_set_arns)
  instance_arn       = var.sso_instance_arn
  target_id          = var.account_id
  target_type        = "AWS_ACCOUNT"
  principal_id       = var.group_id
  principal_type     = "GROUP"
  permission_set_arn = each.value
}
```

- [ ] **Step 4: Commit**
```bash
git add modules/sso-assignment/*.tf
git commit -m "feat: create reusable sso-assignment module"
```

---

### Task 4: Setup Accounts Environment for SSO Assignments

**Files:**
- Modify: `environments/accounts/data.tf`

- [ ] **Step 1: Add data source for "developers" group**
```hcl
# Append to environments/accounts/data.tf
data "aws_ssoadmin_instances" "this" {}

data "aws_identitystore_group" "developers" {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  alternate_identifier {
    unique_attribute {
      attribute_path  = "DisplayName"
      attribute_value = "developers"
    }
  }
}
```

- [ ] **Step 2: Commit**
```bash
git add environments/accounts/data.tf
git commit -m "feat: add identity store group lookup for developers"
```

---

### Task 5: Configure SSO Assignments for accounts

**Files:**
- Modify: `environments/accounts/account_dev.tf`
- Modify: `environments/accounts/account_log_archive.tf`

- [ ] **Step 1: Add assignment to Dev account**
Append to `environments/accounts/account_dev.tf`:
```hcl
module "sso_assignment_dev" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = aws_organizations_account.dev.id
  group_id            = data.aws_identitystore_group.developers.id
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["PowerUserAccess"]]
}
```

- [ ] **Step 2: Add assignment to Log Archive account**
Append to `environments/accounts/account_log_archive.tf`:
```hcl
module "sso_assignment_log_archive" {
  source              = "../../modules/sso-assignment"
  sso_instance_arn    = data.terraform_remote_state.management.outputs.sso_instance_arn
  account_id          = aws_organizations_account.log_archive.id
  group_id            = data.aws_identitystore_group.developers.id
  permission_set_arns = [data.terraform_remote_state.management.outputs.sso_permission_set_arns["SecurityAudit"]]
}
```

- [ ] **Step 3: Validate and Commit (User to apply manually)**
Run: `terraform -chdir=environments/accounts init && terraform -chdir=environments/accounts validate`
```bash
git add environments/accounts/account_dev.tf environments/accounts/account_log_archive.tf
git commit -m "feat: configure sso assignments for dev and log archive accounts"
```
