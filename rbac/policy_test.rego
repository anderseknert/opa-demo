package policy_test

import data.policy.allow

test_allow_if_superadmin {
	allow with input as {"roles": ["superadmin", "developer"]}
}

# TODO: Use glob matching instead to avoid /public_not to be matched
test_allow_if_public_path {
	allow with input.path as "/public"
	allow with input.path as "/health?status=true"
	allow with input.path as "/static/logo.png"
	not allow with input.path as "/publik"
}

test_allow_if_endpoint_path_match {
	allow with input as {
		"roles": ["nobody", "developer"],
		"path": "/v1/users",
		"method": "GET",
	}
}
