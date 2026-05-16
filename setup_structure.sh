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
