

# OPA Demo

## Microservice authorization

### Running

```shell
token=$(jwt encode --secret supersecret --sub anders '{"roles": ["developer"], "aud": "opa-demo"}')
```

```shell
curl -H 'Content-Type: application/json' \
     -d "{\"input\": {\"token\": \"$token\"}}" \
     http://localhost:8181/v1/data/authz
```