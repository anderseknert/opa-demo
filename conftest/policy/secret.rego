package main

deny[reason] {
    input.kind != "Secret"
    reason = "Expected resource to be of kind Secret"
}

deny[reason] {
    not input.metadata.namespace
    reason = "Explicit namespace required"
}

deny[reason] {
    not input.metadata.labels["bisnode.com/maintainer-name"]
    reason = "Missing mandatory label \"bisnode.com/maintainer-name\""
}