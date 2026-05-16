# Landing Zone Structure Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create a bash script to generate an enterprise-grade Terraform Landing Zone project directory structure and bootstrap the management environment.

**Architecture:** A single bash script `setup_structure.sh` that uses `mkdir -p` and `touch` for structure generation and `rm -- "$0"` for self-cleanup.

**Tech Stack:** Bash

---

### Task 1: Create the Generation Script

**Files:**
- Create: `setup_structure.sh`

- [ ] **Step 1: Write the script content**

```bash
#!/bin/bash

# Create environment directories
mkdir -p environments/management
mkdir -p environments/shared-services
mkdir -p environments/dev
mkdir -p environments/staging
mkdir -p environments/prod

# Create module directories
mkdir -p modules/account-vending
mkdir -p modules/network-base
mkdir -p modules/sso-assignment

# Bootstrap management environment files
touch environments/management/main.tf
touch environments/management/variables.tf
touch environments/management/outputs.tf
touch environments/management/backend.tf

echo "Landing Zone structure generated successfully."

# Self-cleanup
rm -- "$0"
```

- [ ] **Step 2: Make the script executable**

Run: `chmod +x setup_structure.sh`

- [ ] **Step 3: Commit the script (Optional but good for tracking before run)**

```bash
git add setup_structure.sh
git commit -m "feat: add landing zone structure generation script"
```

---

### Task 2: Execute and Verify

- [ ] **Step 1: Run the script**

Run: `./setup_structure.sh`
Expected: "Landing Zone structure generated successfully."

- [ ] **Step 2: Verify directory structure**

Run: `ls -R environments modules`
Expected:
```text
environments:
dev  management  prod  shared-services  staging

environments/dev:

environments/management:
backend.tf  main.tf  outputs.tf  variables.tf

environments/prod:

environments/shared-services:

environments/staging:

modules:
account-vending  network-base  sso-assignment

modules/account-vending:

modules/network-base:

modules/sso-assignment:
```

- [ ] **Step 3: Verify self-cleanup**

Run: `ls setup_structure.sh`
Expected: `ls: cannot access 'setup_structure.sh': No such file or directory`

- [ ] **Step 4: Commit the generated structure**

```bash
git add environments/ modules/
git commit -m "chore: initialize landing zone project structure"
```
