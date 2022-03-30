resource "aws_api_gateway_rest_api" "api" {

  body = templatefile("api.yaml", {
    presignedurl_lambda_arn = module.presignedurl_lambda.lambda_function_arn
  })

  name           = "presigned url"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "deploy" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.api.body))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "live" {
  deployment_id = aws_api_gateway_deployment.deploy.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = "live"

}

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

  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
    }
  }
  environment_variables = {
    bucket = local.bucket_name
  }

}

