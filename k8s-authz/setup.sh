#!/usr/bin/env bash

pwd=$(pwd) envsubst < config/kind-conf.yaml | kind create cluster --config -

kubectl create namespace opa
kubectl apply -k .
