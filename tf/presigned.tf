module "presignedurl_lambda" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "3.1.0"

  function_name = local.presigned_lambda_name
  description   = "Presigned URL Lambda"
  handler       = "handler.presigned"
  runtime       = "python3.9"
  source_path   = "../src/presigned-url"
  publish       = true
  timeout       = 120
  memory_size   = 2048


  attach_policy_statements = true
   policy_statements = {
    kms_rw = {
      effect    = "Allow",
      actions   = ["kms:*"],
      resources = [aws_kms_key.clamav_bucket_key.arn]
    }

    s3_rw = {
      effect    = "Allow",
      actions   = ["s3:*"],
      resources = ["arn:aws:s3:::*", "arn:aws:s3:::*/*"]
    }
  }

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
    }
  }
  environment_variables = {
    bucket = aws_s3_bucket.clamav_bucket.bucket
  }

}
