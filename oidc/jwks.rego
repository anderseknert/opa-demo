package oidc

jwks_request(url) = http.send({"url": url, "method": "GET", "force_cache": true, "force_cache_duration_seconds": 3600})

# Add query param to second request to avoid both getting the same cache key
jwks_cached = jwks_request("http://127.0.0.1:8080/auth/realms/eknert/protocol/openid-connect/certs").body

jwks_rotated = jwks_request("http://127.0.0.1:8080/auth/realms/eknert/protocol/openid-connect/certs?r=1").body

verified {
	io.jwt.decode(input.token)[0].kid == jwks_cached.keys[_].kid
	io.jwt.verify_rs256(input.token, json.marshal(jwks_cached))
} else {
	io.jwt.verify_rs256(input.token, json.marshal(jwks_rotated))
}
