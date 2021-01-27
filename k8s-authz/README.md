# Kubernetes authorizer webhook using OPA

## Caveats

### Configuration

Unlike admission controllers, authorizer modules can't be configured
dynamically. This means that the configuration options for the authorizer
webhook may only be provided as flags to the API server when starting them.
This level of control is rarely provided in any of the cloud provider managed
solutions, and to my knowledge none of the big ones (AWS, GCP, Azure) allow
you to configure arbitrary flags for `kube-apiserver`. Using authorization
webhooks is thus limited to self-managed kubernetes clusters.

### DNS

Since the API server starts before most other components in the cluster -
including DNS services like CoreDNS - it can't rely on them for resolving
hostnames in the authorizer configuration. This means that pointing your
authorizer webhook to an internal service URL like
`https://opa-authorizer.opa-namespace.svc.cluster.local` won't work.

Possible options include:

1. Run OPA outside of the cluster, on a host resolvable by the Kubernetes
   API server.
2. Run OPA inside the cluster, with an ingress controller configured to
   route external traffic. The kubernetes API server authorizer webhook
   may then be pointed to the ingress routed address of the OPA server.
3. Configure the OPA service to run with a static `clusterIP`, and have
   your API server configuration point directly to the IP address rather
   than a hostname. Since the webhook URL must use the HTTPS scheme, this
   doesn't work well with most certificates, as they often are issued for
   hostnames rather than IP addresses.
4. Above option, but with a modified /etc/hosts on the API servers resolving
   the `clusterIP` of the OPA service to the hostname matching the certificate.

For the purpose of this demo the third option is used. This works well since we
use a self-signed certificate issued for the known `clusterIP`, but is obviously
not a good fit for production use cases. Consider one of the other options for
those.

https://github.com/kubernetes/kubernetes/issues/52511
https://github.com/kubernetes/kubernetes/pull/68890
https://github.com/kubernetes/kubernetes/pull/71010
https://itnext.io/kubernetes-authorization-via-open-policy-agent-a9455d9d5ceb
https://itnext.io/optimizing-open-policy-agent-based-kubernetes-authorization-via-go-execution-tracer-7b439bb5dc5b
https://kubernetes.io/docs/reference/command-line-tools-reference/kube-apiserver/
