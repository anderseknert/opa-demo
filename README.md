

# Running 

token=$(jwt encode --secret supersecret --sub anders '{"roles": ["developer"], "aud": "opa-demo"}')

curl -H 'Content-Type: application/json' \
     -d "{\"input\": {\"token\": \"$token\"}}" \
     http://localhost:8181/v1/data/authz