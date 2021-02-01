# Kubernetes authorizer webhook using OPA

Runnable Kubernetes authorization webhook example using OPA.

## Running

Just run:

```shell
./setup.sh
```

The demo uses [Kind](https://kind.sigs.k8s.io/) to launch a local Kubernetes
cluster and then deploys OPA to that, so you'll obviously need that installed.
Kind uses kubeadm so that's the config format used for providing flags to the
API server (see [kind-conf.yaml](#kind-conf.yaml).

If you want to update the policy, edit `policy/policy.rego` and run:

```shell
kubectl apply -k .
```

You may now issue the usual `kubectl` commands to interact with your local
cluster. Since the default user for kind is a cluster admin with all priveleges
it won't autmoatically be evaluated by the authorizer webhook (as the RBAC
module is configured in front of it). In order to simulate requests from other
users, use the impersonation feature of kubectl:

```shell
$ kubectl get pods \
        --namespace kube-system \
        --as=someuser \
        --as-group=system:authenticated \
        --as-group=devops

Error from server (Forbidden): OPA: denied access to namespace kube-system
```

The OPA server is configured to print decisions to stdout, so simply view the logs
of the OPA pod (in the `opa` namespace) to see requests and responses.

## Updating policy

Change the policy under the policy directory and run `kubectl apply -k .` Note
that it may take a while before the policy change is reflected in the running
system.
