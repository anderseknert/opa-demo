# OPA Demo

## Microservice authorization

### Running

First, issue a token to use for API authentication. The roles contained in the claims will be used for authorization decisions.

```shell
token=$(jwt encode --secret supersecret --sub anders '{"roles": ["api-reader"], "aud": "opa-demo"}')
```

Next, send a request to the externally exposed service running in the API tier:

```shell
curl -H "Authorization: Bearer ${token}" http://localhost/opa-demo-api
```

The response returned should report authorization status for each tier reached.

```shell
curl -H 'Content-Type: application/json' \
     -d "{\"input\": {\"token\": \"$token\"}}" \
     http://localhost:8181/v1/data/authz
```