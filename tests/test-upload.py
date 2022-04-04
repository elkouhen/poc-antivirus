import requests
import logging
import json 

import base64
client_id = os.environ["CLIENT_ID"]
client_secret = os.environ["CLIENT_SECRET"]
base64.b64encode(f"{client_id}:{client_secret}".encode())


from aws_requests_auth.boto_utils import BotoAWSRequestsAuth


api_base_url = "https://i536xj8kxk.execute-api.eu-west-1.amazonaws.com/live"


logging.basicConfig() # Setup basic logging to stdout
log = logging.getLogger('urllib3')
log.setLevel(logging.DEBUG)

auth = BotoAWSRequestsAuth(aws_host='i536xj8kxk.execute-api.eu-west-1.amazonaws.com',
                           aws_region='eu-west-1',
                           aws_service='execute-api')

upload_request = requests.post(f"{api_base_url}/presigned-url", json={}, auth=auth)    

presigned_response = json.loads(upload_request.text)


files = {'file': open('./requirements.txt' ,'r')}
presigned_upload = requests.post(presigned_response['url'], data=presigned_response['fields'], files=files)    


print(presigned_response['fields']['key'])