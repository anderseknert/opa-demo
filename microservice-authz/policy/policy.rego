package authz

# returned array is of the form [valid, header, payload]
decoded := io.jwt.decode_verify(input.token, {
    "aud": "opa-demo",
    "secret": "supersecret",
})

deny[reason] {
    not input.token
    reason = "No token provided in request"
}

deny[reason] {
    valid := decoded[0]
    not valid
    reason = "Provided JWT failed verification"
}

deny[reason] {
    payload := decoded[2]
    not in(payload.roles, "developer")
    reason = "Role 'developer' missing"
}

decision = {
    "allow": count(deny) == 0,
    "message": concat(", ", deny)
}

in(coll, item) {
    coll[_] == item
}