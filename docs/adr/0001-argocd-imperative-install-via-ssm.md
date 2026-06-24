# ArgoCD installed imperatively via SSM, not in Terraform user_data

ArgoCD's container images total ~500 MB. On a `t2.micro` (961 MB RAM), pulling and starting those images during boot — while K3s itself is initialising — causes PLEG health failures and kubectl timeouts. We install ArgoCD manually via an SSM Session Manager shell session only after K3s has fully stabilised and its page cache is warm. The Terraform `user_data` script only bootstraps K3s itself.

## Consequences

ArgoCD is not automatically reinstalled if the EC2 instance is replaced. A runbook (captured in the GitHub issue) must be re-run via SSM after any instance rebuild.
