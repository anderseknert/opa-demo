package kubernetes.api_client

resource_group_mapping := {
	"services": "api/v1",
	"pods": "api/v1",
	"configmaps": "api/v1",
	"secrets": "api/v1",
	"persistentvolumeclaims": "api/v1",
	"daemonsets": "apis/apps/v1",
	"deployments": "apis/apps/v1",
	"statefulsets": "apis/apps/v1",
	"horizontalpodautoscalers": "api/autoscaling/v1",
	"jobs": "apis/batch/v1",
	"cronjobs": "apis/batch/v1beta1",
	"ingresses": "api/extensions/v1beta1",
	"replicasets": "apis/apps/v1",
	"networkpolicies": "apis/networking.k8s.io/v1",
}

# Query for given resource/name in provided namespace
query_ns(resource, name, namespace) = http.send({
	"url": sprintf("https://kubernetes.default.svc/%v/namespaces/%v/%v/%v", [
		resource_group_mapping[resource],
		namespace,
		resource,
		name,
	]),
	"method": "get",
	"headers": {"authorization": sprintf("Bearer %v", [opa.runtime().env.KUBERNETES_API_TOKEN])},
	"tls_ca_cert_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
	"raise_error": false,
})

# Query for all resources of type resource in all namespaces
query_all(resource) = http.send({
	"url": sprintf("https://kubernetes.default.svc/%v/%v", [
		resource_group_mapping[resource],
		resource,
	]),
	"method": "get",
	"headers": {"authorization": sprintf("Bearer %v", [opa.runtime().env.KUBERNETES_API_TOKEN])},
	"tls_ca_cert_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt",
	"raise_error": false,
})

q := query_all("pods")

#query_label_selector()
#?labelSelector=environment%3Dproduction,tier%3Dfrontend
