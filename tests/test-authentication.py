import requests
import logging
import base64
import os
import boto3

logging.basicConfig() # Setup basic logging to stdout
log = logging.getLogger('urllib3')
log.setLevel(logging.INFO)

cognito_api = "https://poc-antivirus.auth.eu-west-1.amazoncognito.com"

client = boto3.client("cognito-idp", region_name="eu-west-1")


username = os.environ["COGNITO_USERNAME"]
password = os.environ["COGNITO_PASSWORD"]

response = client.initiate_auth(
    AuthFlow="USER_PASSWORD_AUTH",
    ClientId="7kipcb6k29v6js79naiu9g2qgd",
    AuthParameters={"USERNAME": username, "PASSWORD": password},
)

access_token = response['AuthenticationResult']['AccessToken']

print(access_token)