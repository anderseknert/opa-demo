package policy

import data.endpoints

default allow = false

allow {
	input.roles[_] == "superadmin"
}

allow {
	public_endpoints := {"/health", "/public", "/static"}
	startswith_any(input.path, public_endpoints)
}

allow {
	endpoint := endpoints[input.path]
	endpoint[k]
	input.roles[_] == k
	input.method == endpoint[k].methods[_]
}

startswith_any(str, coll) {
	c := coll[_]
	startswith(str, c)
}
