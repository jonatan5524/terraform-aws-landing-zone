# AWS Landing Zone

A zero-cost, enterprise-grade multi-account AWS infrastructure for a startup, built with Terraform. Every resource must stay within AWS Free Tier limits.

## Language

### Accounts & Organisation

**Landing Zone**: The complete multi-account AWS infrastructure managed by this repo — organisation structure, IAM, networking, compute, and GitOps layer combined.
_Avoid_: environment, platform, infrastructure

**Account Vending**: The Terraform-driven process of dynamically provisioning AWS member accounts into Organisational Units via `for_each`. Each account is isolated state.
_Avoid_: account creation, account provisioning

**OU (Organisational Unit)**: An AWS Organizations container grouping member accounts for SCP inheritance. The hierarchy is: Root → OU → Member Account.
_Avoid_: folder, group

**SCP (Service Control Policy)**: An AWS Organizations policy attached to an OU that acts as a permission ceiling — it can only restrict, never grant. Used here to block non-free-tier resources.
_Avoid_: IAM policy, guardrail

### Networking

**NAT Instance**: A `t2.micro` EC2 instance running `fck-nat` that provides outbound internet access for private subnet resources. Used instead of a managed NAT Gateway to stay within free tier.
_Avoid_: NAT Gateway, internet gateway (that's a separate concept)

**Private Subnet**: The subnet (10.0.0.128/25) where the K3s node runs. No public IP; outbound traffic routes via the NAT Instance. Inbound access only via SSM.
_Avoid_: internal subnet, backend subnet

### Compute & GitOps

**K3s Node**: The single `t2.micro` EC2 instance running K3s in the private subnet. The entire Kubernetes workload runs here.
_Avoid_: EKS, Kubernetes node, worker node

**SSM Session Manager**: The sole mechanism for shell access to the K3s node. No SSH keys, no bastion host. Also used for SSM port-forwarding to reach cluster services from a local browser.
_Avoid_: SSH, bastion, remote access

**SSM Port-Forwarding**: An AWS SSM feature that tunnels a port on the K3s node to a local port on the operator's machine. Used to access the ArgoCD UI and application NodePorts without a public endpoint.
_Avoid_: kubectl port-forward (that's a different, in-cluster mechanism)

**Application CR**: The ArgoCD `Application` custom resource that declares what Git path to sync and into which cluster namespace. The unit of GitOps configuration in this repo.
_Avoid_: ArgoCD app, deployment manifest

**GitOps**: The practice of using Git as the single source of truth for cluster state, with ArgoCD continuously reconciling the cluster to match the repo.
_Avoid_: CD pipeline, continuous deployment (those imply push-based delivery)

### Cost Guardrails

**Free Tier**: The AWS allowance of 750 compute hours/month on `t2.micro`/`t3.micro` and 750 public IPv4 hours/month. All architecture decisions are constrained by this limit.
_Avoid_: free, low-cost, cheap
