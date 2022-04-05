resource "aws_api_gateway_rest_api" "api" {

  name = "presigned url"

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


resource "aws_api_gateway_resource" "presigned-url" {
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "presignedurl"
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_authorizer" "this" {
  name          = "cognito"
  rest_api_id   = aws_api_gateway_rest_api.api.id
  type          = "COGNITO_USER_POOLS"
  provider_arns = [module.cognito-user-pool.arn]
}

resource "aws_api_gateway_method" "presigned-url" {
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.this.id
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.presigned-url.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
}


resource "aws_api_gateway_integration" "presigned-url" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.presigned-url.id
  http_method             = aws_api_gateway_method.presigned-url.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.presignedurl_lambda.lambda_function_invoke_arn
}

