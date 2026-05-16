# Design Spec: AWS Management Account Configuration

## 1. Overview
This specification describes the initial Terraform configuration for the AWS Management account. It establishes the AWS Organization and the secure, zero-cost state management backend using Terraform 1.10+ native S3 locking.

## 2. Goals
- Initialize the AWS Organization with all features enabled.
- Create a secure S3 bucket for central Terraform state management.
- Implement native S3 state locking (removing the need for DynamoDB).
- Ensure all resources stay within the AWS Free Tier (Zero Cost).

## 3. Architecture & Resources

### 3.1 Organization
- **Resource:** `aws_organizations_organization`
- **Feature Set:** `ALL` (Required for SCPs and multi-account management).

### 3.2 State Management (S3)
- **Bucket Name:** `pomeloinfra-tf-state-backend`
- **Region:** `us-east-1`
- **Security Features:**
    - **Versioning:** Enabled (Required for state durability and recovery).
    - **Server-Side Encryption:** AES256 (S3-managed keys, zero cost).
    - **Public Access Block:** All four block settings enabled (Best practice).

### 3.3 Backend Configuration
- **Type:** `s3`
- **Native Locking:** `use_lockfile = true` (New in Terraform 1.10+).
- **Key:** `management/terraform.tfstate`

## 4. Implementation Details
- **Environment:** `environments/management/`
- **Files:**
    - `provider.tf`: AWS provider configuration.
    - `main.tf`: Organization and S3 bucket resources.
    - `backend.tf`: S3 backend configuration with native locking.
    - `outputs.tf`: Exports for organization ID and bucket details.

## 5. Bootstrap Strategy
Since the state bucket is created within the same configuration that uses it, the implementation will follow a two-step process:
1. Initialize with **local state** to create the S3 bucket.
2. Update `backend.tf` and re-initialize to migrate state to S3.

## 6. Verification Plan
1. `terraform init` (local state).
2. `terraform apply` to create the Organization and Bucket.
3. Configure `backend.tf` with `use_lockfile = true`.
4. `terraform init -migrate-state` to move state to S3.
5. Verify the existence of the `.terraform.lock.hcl` and S3 object versioning.
