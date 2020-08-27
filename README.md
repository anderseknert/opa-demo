# OPA Demo

## Microservice authorization

Example using OPA for authorization in an n-tiered microservice architecture, where the API tier on top forwards requests down to the orchestration tier below, who in turn forwards requests to the service(s) running in the service tier. Where does the authorization happen? Everywhere! Each service is responsible for enforcing it's own authorization decision, as provided by it's OPA sidecar.

### Setup

Run the `setup.sh` script in the project root directory. This will create a new kind cluster and deploy the demo resources to that.

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

### Demo

1. Review setup.sh
2. Review the kubernetes resource definitions and sidecar patch
3. Review the policy
4. Review the python app code
5. If time allows - policy change
