package kubernetes.api_client

resource_group_mapping := {
	"services": "api/v1",
	"pods": "api/v1",
	"configmaps": "api/v1",
	"persistentvolumeclaims": "api/v1",
	"deployments": "apis/apps/v1",
	"statefulsets": "apis/apps/v1",
	"horizontalpodautoscalers": "api/autoscaling/v1",
	"jobs": "apis/batch/v1",
	"cronjobs": "apis/batch/v1beta1",
	"ingresses": "api/extensions/v1beta1",
	"replicasets": "apis/apps/v1",
	"networkpolicies": "apis/networking.k8s.io/v1",
}

# TODO
# - caching
# - alternative way of getting token
# - error handling - fail open if desired
query(resource, name, namespace) = response_body {
	token := opa.runtime().env.KUBERNETES_API_TOKEN
	response = http.send({
		"url": resource_url(resource, name, namespace),
		"method": "get",
		"headers": {"authorization": sprintf("Bearer %v", [token])},
		"tls_ca_cert_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
	})

	response_body := response.body
}

resource_url(resource, name, namespace) = url {
	group := resource_group_mapping[resource]
	url := sprintf("https://kubernetes.default.svc/%v/namespaces/%v/%v/%v", [group, namespace, resource, name])
}
