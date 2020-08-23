

# OPA Demo

## Microservice authorization

### Running

```shell
token=$(jwt encode --secret supersecret --sub anders '{"roles": ["api-reader"], "aud": "opa-demo"}')
```

```shell
curl -H 'Content-Type: application/json' \
     -d "{\"input\": {\"token\": \"$token\"}}" \
     http://localhost:8181/v1/data/authz
```

```shell
curl -H "Content-Type: application/json" \
     -H "Authorization: Bearer ${token}" \
     http://localhost/opa-demo-api
```