locals {
  bucket_name           = "s3-clamav-123458"
  lambda_name           = "lambda-clamav"
  presigned_lambda_name = "lambda-presigned"
  image_uri             = "629923658207.dkr.ecr.eu-west-1.amazonaws.com/clamav:1.1"
}

provider "aws" {
  
  region  = "eu-west-1" 
}