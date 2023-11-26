resource "aws_api_gateway_rest_api" "route53_api" {
  name        = "Route53FlashpointAPI"
  description = "API for Route53Flashpoint DNS Management"
}

resource "aws_api_gateway_resource" "dns_record_resource" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  parent_id   = aws_api_gateway_rest_api.route53_api.root_resource_id
  path_part   = "dnsrecord"
}

resource "aws_api_gateway_method" "dns_record_post" {
  rest_api_id   = aws_api_gateway_rest_api.route53_api.id
  resource_id   = aws_api_gateway_resource.dns_record_resource.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  resource_id = aws_api_gateway_resource.dns_record_resource.id
  http_method = aws_api_gateway_method.dns_record_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_record_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "route53_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  stage_name  = "v1"
}

resource "aws_api_gateway_method_response" "200_response" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  resource_id = aws_api_gateway_resource.dns_record_resource.id
  http_method = aws_api_gateway_method.dns_record_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}
