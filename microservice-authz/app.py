#!/usr/bin/env python3

# Based on https://github.com/open-policy-agent/contrib/tree/master/api_authz

import base64
import json
import logging
import os
import sys

import requests
from flask import Flask, request

logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)

app = Flask(__name__)

opa_url = os.environ.get('OPA_ADDR', 'http://localhost:8181')
policy_path = os.environ.get('POLICY_PATH', '/v1/data/authz')

def check_auth(url, method, url_as_array, token):
    input_dict = {
        'input': {
            'path': url_as_array,
            'method': method,
            'token': token
        }
    }

    logging.info('Authorizing...')
    logging.info(json.dumps(input_dict, indent=2))
    try:
        rsp = requests.post(url, data=json.dumps(input_dict))
    except Exception as err:
        logging.info(err)
        return {}
    j = rsp.json()
    if rsp.status_code >= 300:
        logging.info("Error checking auth, got status %s and message: %s" % (j.status_code, j.text))
        return {}
    logging.info('Auth response:')
    logging.info(json.dumps(j, indent=2))
    return j

@app.route('/', defaults={'path': ''})
@app.route('/<path:path>')
def root(path):
    auth_header = request.headers.get('Authorization')
    if auth_header:
        token = auth_header.split('Bearer ')[1]
    else:
        return "Error: no Authorization header present in %s request to %s" % (request.method, path), 401

    url = opa_url + policy_path
    path_as_array = path.split('/')

    j = check_auth(url, request.method, path_as_array, token).get('result', {})
    if j.get("allow", False):
        return "Success: user is authorized\n"
    return "Error: user not authorized to %s url /%s \n" % (request.method, path), 401

if __name__ == "__main__":
    app.run(port=8080)
