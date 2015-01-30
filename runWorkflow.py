# Update for your environment here. Use single quotes around each defined value.
usr = {REPLACE WITH YOUR VRO USERNAME}
pwd = {REPLACE WITH YOUR VRO PASSWORD}
wfid = {REPLACE WITH YOUR VRO WORKFLOW ID}
#NOTE: use double \\ or single / when specifying file path
jsonFile = {REPLACE WITH PATH TO JSON BODY FILE}
vroServer = {REPLACE WITH VRO URL:PORT}
 
##### Make no changes below this line ####
# Original article: http://bit.ly/pythonvco
# Import the modules to handle HTTP calls and work with json:
#
# requests: http://docs.python-requests.org/en/latest/user/install/
# To install the "requests" module, python -m pip install requests
# json (http://docs.python.org/2/library/json.html)
#
#####
import requests, json
 
# Create basic authorization for API
vroAuth = requests.auth.HTTPBasicAuth(usr,pwd)
# Set headers to allow for json format
headers = {'Content-Type':'application/json','Accept':'application/json'}
url = 'https://' + vroServer + '/vco/api/workflows/' + wfid + '/executions'
data = open(jsonFile).read()
# NOTE: verify=False tells Python to ignore SSL Cert issues
# Execute a workflow using a json file for the body:
r = requests.post(url, data=data, verify=False, auth=vroAuth, headers=headers)
