# ArgoCD server runs in insecure mode (no TLS)

The ArgoCD server is patched with `--insecure` to serve plain HTTP rather than its default HTTPS. TLS between the reverse proxy and ArgoCD adds no meaningful security here: the K3s node is in a private subnet with no public IP, and all operator access is through AWS SSM port-forwarding (an encrypted tunnel). A self-signed cert would only produce browser warnings without providing real protection. If the cluster is ever exposed to a non-private network, this decision must be revisited.
