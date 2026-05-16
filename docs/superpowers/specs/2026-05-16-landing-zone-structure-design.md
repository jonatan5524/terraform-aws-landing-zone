# Design Spec: Landing Zone Project Structure Generator

## 1. Overview
This specification describes a bash script to automate the creation of a standard AWS Landing Zone directory structure. The goal is to provide a clean, consistent starting point for multi-account Terraform management.

## 2. Goals
- Automate the creation of a hierarchical directory structure.
- Ensure all required environments and modules are present.
- Bootstrap the `management` environment with core Terraform files.
- Self-cleanup after execution.

## 3. Directory Structure
The script will create the following structure relative to the project root:
- `environments/`
    - `management/` (with `main.tf`, `variables.tf`, `outputs.tf`, `backend.tf`)
    - `shared-services/`
    - `dev/`
    - `staging/`
    - `prod/`
- `modules/`
    - `account-vending/`
    - `network-base/`
    - `sso-assignment/`

## 4. Implementation Details
- **Script Name:** `setup_structure.sh`
- **Language:** Bash
- **Method:** Uses `mkdir -p` for directory creation and `touch` for file initialization.
- **Cleanup:** The script will delete itself (`rm -- "$0"`) as its final action.

## 5. Verification Plan
1. Run the script: `bash setup_structure.sh`.
2. Verify all directories exist using `ls -R`.
3. Verify files exist in `environments/management/`.
4. Verify the script `setup_structure.sh` has been removed.
