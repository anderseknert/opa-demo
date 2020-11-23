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

# TODO: non-namespaced query
ns_query(resource, name, namespace) = http.send({
	"url": sprintf("https://kubernetes.default.svc/%v/namespaces/%v/%v/%v", [
		resource_group_mapping[resource],
		namespace,
		resource,
		name,
	]),
	"method": "get",
	"headers": {"authorization": sprintf("Bearer %v", [api_token])},
	"tls_ca_cert_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
	"raise_error": false,
})

# TODO: alternative way of getting token?
api_token = opa.runtime().env.KUBERNETES_API_TOKEN
