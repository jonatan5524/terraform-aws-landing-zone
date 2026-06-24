# Runbook: Install ArgoCD on K3s via SSM

Covers the imperative steps to install ArgoCD after K3s has fully stabilised on the K3s Node.
Run this after every EC2 instance replacement (see ADR 0001).

## Prerequisites

- AWS CLI configured with access to the dev account
- `aws ssm` plugin installed (`session-manager-plugin`)
- K3s Node instance ID (from Terraform output `k3s_instance_id`)

## Step 1 — Open an SSM shell session

```bash
aws ssm start-session --target <K3S_INSTANCE_ID> --region eu-west-1
```

## Step 2 — Verify K3s is ready

```bash
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
kubectl get nodes
# Expected: node shows STATUS=Ready
```

## Step 3 — Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=available --timeout=600s deployment/argocd-server -n argocd
```

## Step 4 — Patch ArgoCD to insecure mode

Removes the self-signed TLS cert from the ArgoCD server. Safe here because all access is via SSM port-forwarding (see ADR 0002).

```bash
kubectl patch deployment argocd-server -n argocd \
  --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--insecure"}]'
kubectl rollout status deployment/argocd-server -n argocd
```

## Step 5 — Apply the guestbook Application CR

Copy the contents of `k8s/argocd/guestbook-app.yaml` from the repo and paste them into the SSM session:

```bash
kubectl apply -f - <<EOF
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: guestbook
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/jonatan5524/terraform-aws-landing-zone
    targetRevision: main
    path: k8s/guestbook
  destination:
    server: https://kubernetes.default.svc
    namespace: guestbook
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
EOF
```

## Step 6 — Verify ArgoCD sync

```bash
kubectl get applications -n argocd
# Expected: guestbook shows STATUS=Synced, HEALTH=Healthy
```

## Step 7 — Access the ArgoCD UI via SSM port-forwarding

Run this **locally** (not inside the SSM session):

```bash
aws ssm start-session \
  --target <K3S_INSTANCE_ID> \
  --region eu-west-1 \
  --document-name AWS-StartPortForwardingSession \
  --parameters '{"portNumber":["30080"],"localPortNumber":["8080"]}'
```

Then open http://localhost:8080 in your browser to reach the guestbook frontend.

For the ArgoCD UI (NodePort 30081 — see Step 8), change `portNumber` to `30081` and `localPortNumber` to `8081`.

## Step 8 — Expose ArgoCD UI on a NodePort (optional)

By default ArgoCD server is only reachable as a ClusterIP. Patch it to NodePort for SSM forwarding:

```bash
kubectl patch svc argocd-server -n argocd \
  -p '{"spec":{"type":"NodePort","ports":[{"port":80,"nodePort":30081},{"port":443,"nodePort":30082}]}}'
```

Then SSM-forward port 30081 locally to access the ArgoCD dashboard.

Retrieve the initial admin password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath='{.data.password}' | base64 -d
```
