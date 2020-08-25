#!/usr/bin/env bash

# Reload application and policies in running cluster

k() {
    kubectl --context kind-opa-demo "$@"
}

opa build microservice-authz/policy/
aws s3 cp bundle.tar.gz s3://opa-demo/
rm bundle.tar.gz

cd microservice-authz
docker build -t eknert/opa-demo-app:test .
kind load docker-image eknert/opa-demo-app:test --name opa-demo
k delete pods -l app=opa-demo
cd -