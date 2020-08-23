package authz

# returned array is of the form [valid, header, payload]
decoded := io.jwt.decode_verify(input.token, {
    "aud": "opa-demo",
    "secret": "supersecret",
})
claims := decoded[2]

required_roles := to_set(split(opa.runtime().env.JWT_REQUIRED_ROLES, " "))

deny[reason] {
    not required_roles
    reason = "At least one role needs to be provided from env var JWT_REQUIRED_ROLES"
}

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
    result := required_roles - to_set(claims.roles)
    count(result) > 0
    reason = sprintf("Missing required roles %v in token claims %v", [result, claims.roles])
}

decision = {
    "allow": count(deny) == 0,
    "message": concat(", ", deny)
}

to_set(arr) = s {
    s = { x | x = arr[_] }
}