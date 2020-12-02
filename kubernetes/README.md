# opa-kubernetes-client



## Local development and testing with kind

Run the `setup.sh` script to create a local kubernetes cluster using [kind](https://kind.sigs.k8s.io/). This will deploy OPA and an ingress controller to let you access it as if running normally (i.e. on `localhost:8181`). You can then run queries using the [OPA query API](https://www.openpolicyagent.org/docs/latest/rest-api/#query-api) in order to test the functions from the policy.

`POST http://localhost:8181/v1/query`
```json
{
    "query": "x := data.kubernetes.api_client.query_name_ns(\"deployments\",\"opa-kubernetes-client\", \"default\").body"
}
```

`POST http://localhost:8181/v1/query`
```json
{
    "query": "x := data.kubernetes.api_client.query_all(\"deployments\").body"
}
```
