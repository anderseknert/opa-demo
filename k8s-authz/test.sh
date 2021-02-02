#!/usr/bin/env bash

k() {
    kubectl --context kind-opa-authorizer "$@"
}

expect() {
    if [[ "$1" != "$2" ]]; then
        echo "Expected $1 == $2"
        exit 1
    fi
}

expect_ends_with() {
    if [[ "$1" != *"$2" ]]; then
        echo "Expected $1 == *$2"
        exit 1
    fi
}

opa_pod=$(k --namespace opa get pods -l app=opa -o jsonpath='{.items[0].metadata.name}')

k --namespace opa wait --for=condition=Ready pods/"$opa_pod" > /dev/null

# Access to kube-system should be denied
result=$(k --namespace kube-system --as=someuser --as-group=system:authenticated get pods 2>&1)
expect "$?" 1
expect_ends_with "$result" "OPA: denied access to namespace kube-system"

# Access to opa namespace denied unless in devops group
result=$(k --namespace opa --as=someuser --as-group=system:authenticated get pods 2>&1)
expect "$?" 1
expect_ends_with "$result" "OPA: provided groups (system:authenticated) does not include all required groups: (devops, system:authenticated)"

# Access to opa namespace allowed if in devops group
result=$(k --namespace opa --as=someuser --as-group=system:authenticated --as-group=devops get pods 2>&1)
expect "$?" 0

echo "All tests successful"
