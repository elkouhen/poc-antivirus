resource "aws_api_gateway_rest_api" "example" {
  body = "${file("api.yaml")}"

  name = "presigned url"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}