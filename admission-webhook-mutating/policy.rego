package kubernetes.admission.mutating

# Attach ownerReference to any network policy or secret with a matching "app"
# label created in the default namespace
enforce[decision] {
  input.request.object.metadata.namespace == "default"

  applicable_resources := {"NetworkPolicy", "Secret"}
  applicable_resources[input.request.object.kind]

  app := input.request.object.metadata.labels.app
  deployment := data.kubernetes.resources.deployments["default"][app]

  decision := {
    "allowed": true,
    "message": sprintf("Adding ownerReference from deployment matching app label %v", [app]),
    "patch": [{
      "op": "add",
      "path": "/metadata/ownerReferences",
      "value": [{
        "apiVersion": "apps/v1",
        "kind": "Deployment",
        "name": app,
        "uid": deployment.metadata.uid
      }]
    }]
  }
}