package authz

# returned array is of the form [valid, header, payload]
decoded := io.jwt.decode_verify(input.token, {
	"aud": "opa-demo",
	"secret": "supersecret",
})

claims := decoded[2]

tier := opa.runtime().env.TIER

required_roles_in_tier := {
	"api": {"api-reader"},
	"orc": {"orc-reader"},
	"svc": {"svc-reader"},
}

is_admin {
	claims.roles[_] == "admin"
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
	not tier
	reason := "Environment variable TIER not set"
}

deny[reason] {
	valid_tiers = {"api", "orc", "svc"}
	not valid_tiers[tier]
	reason = sprintf("Tier %v not in list of valid tiers %v", [tier, valid_tiers])
}

deny[reason] {
	not is_admin
	result := required_roles_in_tier[tier] - to_set(claims.roles)
	count(result) > 0
	reason = sprintf("Missing required roles %v in token claims %v", [result, claims.roles])
}

decision = {
	"allow": count(deny) == 0,
	"message": concat(", ", deny),
}

to_set(arr) = s {
	s = {x | x = arr[_]}
}
