resource "aws_kms_key" "bucket_kms" {
  description             = "bucket_kms"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.bucket_kms.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "clamav-bucket-123457"

}

resource "aws_lambda_permission" "allow_bucket" {

  statement_id = "AllowExecutionFromS3Bucket"

  action        = "lambda:InvokeFunction"
  function_name = module.lambda.lambda_function_arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.bucket.arn
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.bucket.id


  lambda_function {
    lambda_function_arn = module.lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_bucket]
}


module "lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "2.35.1"

  function_name  = "clamav-lambda"
  description    = "Clamav Lambda"
  create_package = false

  image_uri    = "629923658207.dkr.ecr.eu-west-1.amazonaws.com/clamav:1.0"
  package_type = "Image"
  timeout      = 120
  memory_size  = 2048

  attach_policy_json = true
  policy_json        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject", "s3:PutObjectTagging"
            ],
            "Resource": ["arn:aws:s3:::clamav-bucket-123457/*"]
        }, 
        {
            "Effect": "Allow",
            "Action": [
                "kms:*"
            ],
            "Resource": ["*"]
        }        
    ]
}
EOF

  environment_variables = {
    Serverless = "Terraform"
  }

}
