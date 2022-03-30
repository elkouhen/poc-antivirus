locals {
  bucket_name           = "s3-clamav-123458"
  lambda_name           = "lambda-clamav"
  presigned_lambda_name = "lambda-presigned"
  image_uri             = "629923658207.dkr.ecr.eu-west-1.amazonaws.com/clamav:1.1"
}

provider "aws" {
  
  region  = "eu-west-1" 
}

resource "aws_kms_key" "clamav_bucket_key" {
  description             = "clamav_bucket_key"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.clamav_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.clamav_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "clamav_bucket" {
  bucket = local.bucket_name
}

resource "aws_lambda_permission" "allow_bucket" {

  statement_id = "AllowExecutionFromS3Bucket"

  action        = "lambda:InvokeFunction"
  function_name = module.clamav_lambda.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.clamav_bucket.arn
}

resource "aws_s3_bucket_notification" "clamav_bucket_notification" {
  bucket = aws_s3_bucket.clamav_bucket.id


  lambda_function {
    lambda_function_arn = module.clamav_lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}


module "clamav_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.1.0"

  function_name  = local.lambda_name
  description    = "Clamav Lambda"
  create_package = false

  image_uri    = local.image_uri
  package_type = "Image"
  timeout      = 120
  memory_size  = 2048

  attach_policy_statements = true
  policy_statements = {
    s3_read = {
      effect    = "Allow",
      actions   = ["s3:HeadObject", "s3:GetObject", "s3:PutObjectTagging"],
      resources = ["arn:aws:s3:::${aws_s3_bucket.clamav_bucket.bucket}/*"]
    },
    kms_read = {
      effect    = "Allow",
      actions   = ["kms:*"],
      resources = [aws_kms_key.clamav_bucket_key.arn]
    }
  }

  environment_variables = {
    
  }

}
