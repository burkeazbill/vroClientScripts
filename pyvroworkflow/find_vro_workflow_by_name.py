#!/usr/bin/env python
# Copyright (c) 2015 Bob Fraser
# Licensed under the MIT License: http://opensource.org/licenses/MIT

"""
Find a vRealize Orchestrator workflow by name.
"""

import argparse
import getpass
import requests
import sys
import urllib


def get_args():
    parser = argparse.ArgumentParser(
        description='Find a vRealize Orchestrator workflow by name')

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

    parser.add_argument('-n', '--name',
                        required=True,
                        action='store',
                        help='Name of vRO workflow')

    args = parser.parse_args()
    if args.password is None:
        args.password = getpass.getpass(
            prompt='Enter password for host %s and user %s: ' %
                   (args.host, args.user))

    return args


def find_workflow_by_name(host, port, user, password, name):
    """
    Find a vRO workflow by name via the REST API.
    Returns a Request object.
    """

    # Set headers to allow for json format
    headers = {'Content-Type': 'application/json',
               'Accept': 'application/json'}

    """
    Sadly, 'conditions=name=<name>' won't parse with standard
    Requests param parsing. Do it the hard way.
    """
    port_s = str(port)
    name_s = urllib.quote(name)

    url = 'https://' + host + ':' + port_s + \
        '/vco/api/workflows/?conditions=name=' + name_s

    """
    Verify False skips SSL certificate checks. Don't do that in production
    """
    try:
        request = requests.get(url, verify=False, auth=(user, password),
                               headers=headers)
    except requests.exceptions.RequestException as e:
        print 'RequestException: %s' % e
        return None

    return request


def link_to_dict(link):
    """
    Unmarshal a link object into a Python dictionary
    Returns a Dict
    """

    attributes = link['attributes']

    # Use item.get('value') as value may not be defined for some attributes
    d = dict([(item['name'], item.get('value')) for item in attributes])
    return d


def main():
    """
    Simple command-line program for finding a
    vRealize Orchestrator workflow by name.
    """

    args = get_args()
    r = find_workflow_by_name(args.host, args.port, args.user, args.password,
                              args.name)
    if r is None:
        print 'HTTP request failed'
        sys.exit(1)

    if r.status_code != requests.codes['ok']:
        print 'Bad request: HTTP Status code %i - %s' %\
            (r.status_code, r.reason)
        sys.exit(1)

    content = r.json()

    if content['total'] == 0:
        print "Couldn't find workflow named: %s" % args.name
        sys.exit(1)

    # Get the first (should be only) workflow
    link = content['link'][0]
    workflow = link_to_dict(link)
    print 'Found workflow: %s' % workflow['name']
    print
    print 'Workflow info:'

    for k, v in workflow.iteritems():
        print '%s : %s' % (k, v)


# Start program
if __name__ == "__main__":
    main()
