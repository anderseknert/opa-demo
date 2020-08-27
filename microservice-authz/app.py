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
policy_path = os.environ.get('POLICY_PATH', '/v1/data/authz/decision')
tier = os.environ.get('TIER')

def check_auth(url, method, token):
    input_dict = {
        'input': {
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
        logging.info("Error checking auth, got status %s and message: %s", j.status_code, j.text)
        return {}
    logging.info('Auth response:')
    logging.info(json.dumps(j, indent=2))
    return j

def forward_request(token):
    next_tier = {'api': 'orc', 'orc': 'svc'}[tier]
    url = f'http://opa-demo-{next_tier}.default.svc.cluster.local:8080/opa-demo-{next_tier}'

    try:
        rsp = requests.get(url, headers={'authorization': f'Bearer {token}'})
    except Exception as err:
        logging.info(err)
        return f'Error forwarding request to tier {next_tier}, error: {err}'

    return f'User authorized in {tier} tier' + "\n" + rsp.text


@app.route('/opa-demo-api', defaults={'path': ''})
@app.route('/<path:path>')
def root(path):
    auth_header = request.headers.get('Authorization')
    if auth_header:
        token = auth_header.split('Bearer ')[1]
    else:
        message = f'Error: no Authorization header present in {request.method} request to {path}\n'
        return message, 401

    url = opa_url + policy_path

    j = check_auth(url, request.method, token).get('result', {})
    if j.get('allow', False):
        if tier == 'svc':
            return f'User authorized in {tier} tier\n'
        else:
            return forward_request(token)

    message = f'Authorization failure in {tier} tier: {j["message"]}\n'
    logging.warning(message)

    return message, 401

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
