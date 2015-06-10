#!/usr/bin/env python
# Copyright (c) 2015 Bob Fraser
# Licensed under the MIT License: http://opensource.org/licenses/MIT
# Contributors: Thanks to Burke Azbill for his initial contribution.

"""
Invoke a vRealize Orchestrator workflow.
"""

import argparse
import getpass
import requests
import sys


def get_args():
    parser = argparse.ArgumentParser(
        description='Invoke a vRealize Orchestrator workflow')

    parser.add_argument('-s', '--host',
                        required=True,
                        action='store',
                        help='vRealize Orchestrator host to connect to')

    parser.add_argument('-o', '--port',
                        type=int,
                        action='store',
                        help="optional port to use, default 8281",
                        default=8281)

    parser.add_argument('-u', '--user',
                        required=True,
                        action='store',
                        help='User name to use when connecting to host')

    parser.add_argument('-p', '--password',
                        required=False,
                        action='store',
                        help='Password to use when connecting to host')

    parser.add_argument('-i', '--workflowid',
                        required=True,
                        action='store',
                        help='ID of vRO workflow.')

    parser.add_argument('-d', '--datafile',
                        required=True,
                        action='store',
                        help='File containing the JSON payload')

    args = parser.parse_args()
    if args.password is None:
        args.password = getpass.getpass(
            prompt='Enter password for host %s and user %s: ' %
                   (args.host, args.user))

    return args


def run_workflow(host, port, user, password, workflowid, data):
    """
    Invoke a vRO workflow via the REST API.
    Returns a Request object.
    """

    # Set headers to allow for json format
    headers = {'Content-Type': 'application/json',
               'Accept': 'application/json'}
    port_s = str(port)
    url = 'https://' + host + ':' + port_s + '/vco/api/workflows/'
    url += workflowid + '/executions'

    """
    Execute a workflow using a json file for the body
    Verify False skips SSL certificate checks. Don't do that in production
    """
    try:
        request = requests.post(url, data=data, verify=False,
                                auth=(user, password), headers=headers)
    except requests.exceptions.RequestException as e:
        print 'RequestException: %s' % e
        return None

    return request


def main():
    """
    Simple command-line program for invoking a
    vRealize Orchestrator workflow.
    """

    args = get_args()
    data = open(args.datafile).read()
    print 'Invoking workflow with id: %s' % args.workflowid
    r = run_workflow(args.host, args.port, args.user, args.password,
                     args.workflowid, data)
    if r is None:
        print 'HTTP request failed'
        sys.exit(1)

    if r.status_code != requests.codes['accepted']:
        print 'Bad request: HTTP Status code %i - %s' %\
            (r.status_code, r.reason)
        sys.exit(1)

    print 'vRO workflow invocation succeeded.'
    print 'More information about this workflow execution can be found at:'
    print r.headers['location']

# Start program
if __name__ == "__main__":
    main()
