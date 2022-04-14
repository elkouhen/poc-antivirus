import boto3
import os
import json
from botocore.client import Config
import uuid

s3_client = boto3.client(
    's3', config=boto3.session.Config(signature_version='s3v4'))


class PresignedService:

    def __init__(self, bucket_name, fields=None, conditions=None, expiration=3600):

        self.bucket_name = bucket_name
        self.fields = fields
        self.conditions = conditions
        self.expiration = expiration

    def create_presigned_post(self, object_name):

        # Generate a presigned S3 POST URL
        try:
            response = s3_client.generate_presigned_post(self.bucket_name,
                                                         object_name,
                                                         Fields=self.fields,
                                                         Conditions=self.conditions,
                                                         ExpiresIn=self.expiration)
        except ClientError as e:
            logging.error(e)
            return None

        # The response contains the presigned URL and required fields
        return response


def presigned(event, context):

    print(context)

    username = event["requestContext"]["authorizer"]["claims"]["cognito:username"]
    group = event["requestContext"]["authorizer"]["claims"]["cognito:groups"]
    
    fields = {'x-amz-meta-username': username, 'x-amz-meta-group': group }

    presigned_service = PresignedService(
        bucket_name=os.environ['bucket'], fields=fields, conditions=[{'x-amz-meta-username': username },{ 'x-amz-meta-group': group }])

    print(event["requestContext"]["authorizer"])

    print(f"{username} {group}")

    presigned_url = presigned_service.create_presigned_post(
        object_name=str(uuid.uuid1()))

    return {
        'statusCode': 200,
        'body': json.dumps(presigned_url)
    }
