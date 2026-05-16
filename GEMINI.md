# Project Context: Zero-Cost AWS Startup Landing Zone

## Project Goal

The objective of this project is to build an enterprise-grade, multi-account AWS Landing Zone tailored for a startup environment using Terraform, while strictly keeping cloud costs at $0.00. This infrastructure demonstrates modern Site Reliability Engineering (SRE) and platform engineering practices, including automated account vending, GitOps, and shift-left security, without relying on expensive managed services.

## Core Constraints & Principles

* **Strict Zero Cost (Free Tier Only):** Expensive managed services like Amazon EKS, AWS NAT Gateways, and AWS Transit Gateways are strictly prohibited. The architecture relies exclusively on free-tier eligible resources (e.g., `t2.micro` or `t3.micro` EC2 instances) to stay within the monthly allowance of 750 compute hours and 750 hours of public IPv4 address usage.
* **Infrastructure as Code:** Everything must be deployed declaratively using Terraform 1.10+ utilizing native S3 state locking, which eliminates the need for an additional DynamoDB table.
* **Modular Design:** The project strictly separates reusable modules from environment-specific configurations to minimize blast radius, enable code reusability, and ensure state isolation across different AWS accounts.

## Architecture Overview

* **AWS Organizations & Account Vending:** A custom Terraform `for_each` module is used to dynamically vend member accounts (Management, Log Archive, Shared Services, Dev/Sandbox) across defined Organizational Units (OUs). This approach avoids the mandatory non-free-tier charges associated with managed solutions like AWS Control Tower.
* **Identity & Access Management:** Traditional IAM users and long-lived access keys are explicitly banned. Human access is centralized via AWS IAM Identity Center (SSO) integrated with Google Cloud Identity Free Edition. Automated CI/CD pipelines authenticate securely using OpenID Connect (OIDC) federation.
* **Cost Guardrails (FinOps):** Service Control Policies (SCPs) actively block the creation of non-free-tier EC2 instance types and expensive services like `ec2:CreateNatGateway`. AWS Budgets are configured to trigger email alerts at $0.01 of actual spend and at 80% of the 750-hour free tier compute limit.
* **Networking:** The architecture uses standard VPCs with public subnets. Outbound internet traffic for private workloads is routed through a lightweight EC2 NAT instance utilizing the open-source `fck-nat` module rather than a managed NAT Gateway.
* **Compute & Workload:** Instead of incurring the $73/month control plane fee for Amazon EKS, the development environment runs K3s, a highly optimized and lightweight Kubernetes distribution designed to run on resource-constrained machines.
* **Continuous Deployment:** ArgoCD is deployed inside the K3s cluster to enforce GitOps workflows, automatically synchronizing a 3-tier microservices guestbook application directly from the Git repository to the cluster.