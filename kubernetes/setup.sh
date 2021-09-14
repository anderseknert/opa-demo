#!/usr/bin/env bash

kind create cluster

kubectl create namespace opa

openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -days 100000 -out ca.crt -subj "/CN=admission_ca"

cat >server.conf <<EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
prompt = no
[req_distinguished_name]
CN = opa.opa.svc
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = clientAuth, serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = opa.opa.svc
EOF

openssl genrsa -out server.key 2048
openssl req -new -key server.key -out server.csr -config server.conf
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out server.crt -days 100000 -extensions v3_req -extfile server.conf

kubectl --namespace opa create secret tls opa-server --cert=server.crt --key=server.key

kubectl apply -f admission-controller.yaml

cat > webhook-configuration.yaml <<EOF
kind: ValidatingWebhookConfiguration
apiVersion: admissionregistration.k8s.io/v1
metadata:
  name: opa-validating-webhook
webhooks:
  - name: validating-webhook.openpolicyagent.org
    namespaceSelector:
      matchExpressions:
      - key: openpolicyagent.org/webhook
        operator: NotIn
        values:
        - ignore
    rules:
      - operations: ["CREATE", "UPDATE"]
        apiGroups: ["*"]
        apiVersions: ["*"]
        resources: ["*"]
    clientConfig:
      caBundle: $(cat ca.crt | base64 | tr -d '\n')
      service:
        namespace: opa
        name: opa
    sideEffects: None
    admissionReviewVersions: ["v1"]
EOF

echo "Waiting for OPA pod to be ready"

sleep 30
kubectl --namespace opa wait --for=condition=ready pod -l app=opa

kubectl apply -f webhook-configuration.yaml

rm ca.crt ca.key ca.srl server.conf server.crt server.csr server.key webhook-configuration.yaml

kubectl --namespace opa create configmap policy --from-file=policy.rego

# Test admission controller policy like:
# kubectl apply -f test-deployment.yaml

