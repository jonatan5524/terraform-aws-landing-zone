# AWS IAM Identity Center (SSO) Configuration Design Spec

**Goal:** Implement a decentralized approach to AWS IAM Identity Center configuration where Permission Sets are defined centrally, but assignments are managed dynamically by the individual Account Vending definitions.

## Architecture

This design relies on a split-responsibility model between the `management` environment and the `accounts` environment, adhering to the "Account Vending Machine" pattern.

### Phase 1: Centralized Definition (`environments/management`)
The Management account owns the definition of what permissions exist, but not who gets them in member accounts.

1.  **Module: `modules/sso-permission-sets`**
    *   **Data Source:** Uses `aws_ssoadmin_instances` to automatically fetch the SSO Instance ARN and Identity Store ID.
    *   **Resources:** Defines `aws_ssoadmin_permission_set` resources. Initially:
        *   `BillingAdministrator` (with the `arn:aws:iam::aws:policy/job-function/Billing` managed policy attached).
        *   `SecurityAudit` (with the `arn:aws:iam::aws:policy/SecurityAudit` managed policy attached).
        *   `PowerUserAccess` (with the `arn:aws:iam::aws:policy/PowerUserAccess` managed policy attached).
    *   **Outputs:** A map of Permission Set names to their generated ARNs.

2.  **Integration (`environments/management/main.tf`):**
    *   Calls the `sso-permission-sets` module.
    *   Exports the module's map of ARNs via `environments/management/outputs.tf` to the remote state.

### Phase 2: Decentralized Assignment (`environments/accounts`)
Each member account explicitly declares which user groups require which permissions within that specific account.

1.  **Module: `modules/sso-assignment`**
    *   **Purpose:** A highly reusable module that attaches a specific group to a specific account for a list of permission sets.
    *   **Inputs:** `account_id`, `group_id`, `permission_set_arns` (list of strings), and the `sso_instance_arn`.
    *   **Resources:** Uses `aws_ssoadmin_account_assignment` with a `for_each` loop iterating over the `permission_set_arns`.

2.  **Integration (`environments/accounts/`):**
    *   **Data Resolution:** Uses the `aws_identitystore_group` data source to dynamically resolve the ID of the "developers" group by name.
    *   **Vending Logic:** Inside `account_dev.tf`, it calls `sso-assignment`, passing the `dev` account ID, the "developers" group ID, and referencing the `PowerUserAccess` ARN from the management remote state.
    *   **Vending Logic:** Inside `account_log_archive.tf`, it repeats this pattern, instead referencing the `SecurityAudit` ARN.

## File Structure Additions

```text
modules/
├── sso-permission-sets/
│   ├── main.tf
│   ├── outputs.tf
│   └── provider.tf
└── sso-assignment/
    ├── main.tf
    ├── variables.tf
    └── provider.tf

environments/
├── management/
│   ├── main.tf (Calls sso-permission-sets)
│   └── outputs.tf (Exports Permission Set ARNs)
└── accounts/
    ├── data.tf (Adds aws_identitystore_group for "developers")
    ├── account_dev.tf (Calls sso-assignment for PowerUserAccess)
    └── account_log_archive.tf (Calls sso-assignment for SecurityAudit)
```

## Tech Stack
- Terraform 1.10+
- AWS Provider 5.0+
