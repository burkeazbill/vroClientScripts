"""

	Invoke a vRO workflow via the REST API. Added capability to specify arguments at the command line.

	If you omit the username and password arguments it will prompt for them. The password will be masked.

"""

import argparse
import requests
import json

def getargs():
    parser = argparse.ArgumentParser()
    parser.add_argument('-s', '--server',
                        required=True,
                        action='store',
                        help='vRealize Orchestrator server')
    parser.add_argument('-u', '--username',
                        required=False,
                        action='store',
                        help='Username to access vRealize Orchestrator')
    parser.add_argument('-p', '--password',
                        required=False,
                        action='store',
                        help='The password used to access vRealize Orchestrator')
    parser.add_argument('-w', '--workflow',
                        required=True,
                        action='store',
                        help='Workflow ID')
    parser.add_argument('-j', '--json',
                        required=False,
                        action='store',
                        dest='input_json',
                        help='Path to JSON post body')
    parser.add_argument('--nosslverify',
    					required=False,
    					action='store_true',
    					help='Stop SSL certificate validation')
    args = parser.parse_args()
    return args

def run_workflow(server, username, password, workflow, input_json, nosslverify):
    try:

        with open(input_json, 'r') as f:
            postdata = json.dumps(f)

        r = requests.post(url='https://' + server + 'vco/api/workflows/' + workflow + '/executions',
                          verify=nosslverify,
                          auth=(username, password),
                          headers= {'Content-Type': 'application/json',
                                    'Accept': 'application/json'},
                          data=postdata)

        print r.status_code

    except requests.RequestException as e:
        print e


def main():
    args = getargs()
    server = args.server
    username = args.username
    password = args.password
    workflow = args.workflow
    input_json = args.input_json
    nosslverify = args.nosslverify

    if not username:
        username = raw_input("target host username:")

    if not password:
        password_request = "Target host '%s' Password: " % username
        password = getpass.getpass(password_request)

    run_workflow(server, username, password, workflow, input_json, nosslverify)

if __name__ == '__main__':
    main()




