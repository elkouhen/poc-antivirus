resource "aws_api_gateway_rest_api" "api" {

  body = templatefile("api.yaml", {
    presignedurl_lambda_arn = module.presignedurl_lambda.lambda_function_arn
  })

  name           = "presigned url"
  api_key_source = "HEADER"

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

resource "aws_api_gateway_usage_plan" "api_usageplan" {
  name = "api_usageplan"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.live.stage_name
  }
}

resource "aws_api_gateway_api_key" "api_key" {
  name = "my_key"
}

resource "aws_api_gateway_usage_plan_key" "main" {
  key_id        = aws_api_gateway_api_key.api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usageplan.id
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

