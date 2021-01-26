#!/usr/bin/env bash

pwd=$(pwd) envsubst < kind-conf.yaml | kind create cluster --config -

kubectl create namespace opa
kubectl apply -f resources.yaml
