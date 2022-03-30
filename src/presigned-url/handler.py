import boto3
import os 

def create_presigned_url(bucket_name, object_name, expiration=600):
    s3 = boto3.client('s3',region_name="eu-west-1",config=boto3.session.Config(signature_version='s3v4',s3={'addressing_style': 'path'}))
    
    return s3.generate_presigned_url(ClientMethod='get_object',Params={'Bucket': bucket_name,'Key': object_name},ExpiresIn=expiration)
    

def presigned(event, context): 
    
    presigned_url = create_presigned_url(bucket_name=os.environ['bucket'], object_name="toto") 

    return {
        'statusCode': 200,        
        'body': presigned_url
    }
