# Management Account Configuration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Initialize the AWS Management account with an Organization and a secure, zero-cost S3 backend using Terraform 1.10+ native locking.

**Architecture:** A bootstrap-capable Terraform configuration that manages its own state bucket and organization. Uses S3 native state locking (`use_lockfile = true`) to avoid DynamoDB costs.

**Tech Stack:** Terraform 1.10+, AWS Provider 5.0+

---

### Task 1: Define Provider and Resources

**Files:**
- Create: `environments/management/provider.tf`
- Create: `environments/management/main.tf`
- Create: `environments/management/outputs.tf`

- [ ] **Step 1: Define the AWS Provider**

```hcl
# environments/management/provider.tf
terraform {
  required_version = ">= 1.10.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"

  default_tags {
    tags = {
      Project     = "PomeloInfra-LandingZone"
      Environment = "Management"
      ManagedBy   = "Terraform"
    }
  }
}
```

- [ ] **Step 2: Define Organization and State Bucket**

```hcl
# environments/management/main.tf
resource "aws_organizations_organization" "this" {
  feature_set = "ALL"
}

resource "aws_s3_bucket" "state" {
  bucket = "pomeloinfra-tf-state-backend"

  # Prevent accidental deletion of this bucket
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "state" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

- [ ] **Step 3: Define Outputs**

```hcl
# environments/management/outputs.tf
output "organization_id" {
  description = "The ID of the AWS Organization"
  value       = aws_organizations_organization.this.id
}

output "state_bucket_name" {
  description = "The name of the S3 bucket used for Terraform state"
  value       = aws_s3_bucket.state.id
}
```

- [ ] **Step 4: Commit the configuration**

```bash
git add environments/management/*.tf
git commit -m "feat: define management account organization and state bucket"
```

---

### Task 2: Local Bootstrap and Resource Creation

**Files:**
- None (Execution Task)

- [ ] **Step 1: Initialize Terraform locally**

Run: `terraform -chdir=environments/management init`
Expected: "Terraform has been successfully initialized!"

- [ ] **Step 2: Apply the configuration**

Run: `terraform -chdir=environments/management apply`
Expected: Verify creation of `aws_organizations_organization.this` and `aws_s3_bucket.state`.

- [ ] **Step 3: Verify resources in AWS (Optional but recommended)**

Run: `aws organizations describe-organization` and `aws s3api get-bucket-versioning --bucket pomeloinfra-tf-state-backend`

---

### Task 3: Configure and Migrate to S3 Backend

**Files:**
- Create: `environments/management/backend.tf`

- [ ] **Step 1: Add the backend configuration**

```hcl
# environments/management/backend.tf
terraform {
  backend "s3" {
    bucket       = "pomeloinfra-tf-state-backend"
    key          = "management/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
```

- [ ] **Step 2: Migrate state to S3**

Run: `terraform -chdir=environments/management init -migrate-state`
Expected: When prompted "Do you want to copy existing state to the new backend?", type `yes`.

- [ ] **Step 3: Verify migration**

Run: `terraform -chdir=environments/management plan`
Expected: "No changes. Your infrastructure matches the configuration."
Check S3: `aws s3 ls s3://pomeloinfra-tf-state-backend/management/terraform.tfstate`

- [ ] **Step 4: Commit the backend configuration**

```bash
git add environments/management/backend.tf
git commit -m "chore: migrate management account state to S3 with native locking"
```
