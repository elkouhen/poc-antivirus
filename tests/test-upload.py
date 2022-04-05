import boto3 
import requests
import logging
import json 
import os 

logging.basicConfig() # Setup basic logging to stdout
log = logging.getLogger('urllib3')
log.setLevel(logging.DEBUG)


client = boto3.client("cognito-idp", region_name="eu-west-1")

api_base_url = "https://no9kmhk02i.execute-api.eu-west-1.amazonaws.com/live"

username = os.environ["COGNITO_USERNAME"]
password = os.environ["COGNITO_PASSWORD"]

response = client.initiate_auth(
    AuthFlow="USER_PASSWORD_AUTH",
    ClientId="2e9qui74vbo3919iugggmq1spf",
    AuthParameters={"USERNAME": username, "PASSWORD": password},
)

access_token = response['AuthenticationResult']['IdToken']

upload_request = requests.post(f"{api_base_url}/presignedurl", json={}, headers = {"Authorization": f"Bearer {access_token}"})    

presigned_response = json.loads(upload_request.text)

print(upload_request)


files = {'file': open('./requirements.txt' ,'r')}
presigned_upload = requests.post(presigned_response['url'], data=presigned_response['fields'], files=files)    

print(presigned_response['fields']['key'])