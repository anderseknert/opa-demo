#!/usr/bin/env bash

k() {
    kubectl --context kind-opa-kubernetes-client "$@"
}

kind create cluster --name opa-kubernetes-client --config kind-config.yaml

# Install nginx ingress controller and wait for it to become ready
k apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/kind/deploy.yaml
k wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=180s

k apply -k .
