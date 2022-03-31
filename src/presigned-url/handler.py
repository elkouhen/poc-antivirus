import boto3
import os 
import json
from botocore.client import Config
    
def create_presigned_post(bucket_name, object_name,
                          fields=None, conditions=None, expiration=3600):

    # Generate a presigned S3 POST URL
    s3_client = boto3.client('s3', config=boto3.session.Config(signature_version = 's3v4'))
    try:
        response = s3_client.generate_presigned_post(bucket_name,
                                                     object_name,
                                                     Fields=fields,
                                                     Conditions=conditions,
                                                     ExpiresIn=expiration)
    except ClientError as e:
        logging.error(e)
        return None

    # The response contains the presigned URL and required fields
    return response

def presigned(event, context): 
    
    presigned_url = create_presigned_post(bucket_name=os.environ['bucket'], object_name="toto") 

    print (presigned_url)

    return {
        'statusCode': 200,        
        'body': json.dumps(presigned_url)
    }
