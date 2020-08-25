#!/usr/bin/env bash

k() {
    kubectl --context kind-opa-demo "$@"
}

kind create cluster --name opa-demo --config kind-config.yaml

# Install nginx ingress controller
k apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml

# Upload policy bundle
opa build microservice-authz/policy/
aws s3 cp bundle.tar.gz s3://opa-demo/
rm bundle.tar.gz

# Build app container and upload it to kind registry
cd microservice-authz
docker build -t eknert/opa-demo-app:test .
kind load docker-image eknert/opa-demo-app:test --name opa-demo

# Wait for ingress controller to be ready
k wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# ..and then, deploy our resources
k apply -k kustomize
cd -
