#!/usr/bin/env bash

# Install gatekeeper
k apply -f https://raw.githubusercontent.com/open-policy-agent/gatekeeper/master/deploy/gatekeeper.yaml
k apply -f constrainttemplate.yaml
sleep 5 # Wait for constraint template to register before deploying the constraint
k apply -f constraint.yaml