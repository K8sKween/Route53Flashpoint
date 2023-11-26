resource "aws_api_gateway_rest_api" "route53_api" {
  name        = "Route53FlashpointAPI"
  description = "API for Route53Flashpoint DNS Management"
  tags        = var.common_tags
}

resource "aws_api_gateway_deployment" "route53_api_deployment" {
  depends_on = [
    aws_api_gateway_integration.create_record_lambda_integration,
    aws_api_gateway_integration.delete_record_lambda_integration,
    aws_api_gateway_integration.reports_lambda_integration,
  ]

  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  stage_name  = "v1"
  #Forces a redeployment of the API Gateway when the Lambda functions are updated
  triggers = {
    redeployment = sha1(join("", tolist([
      aws_api_gateway_integration.create_record_lambda_integration.id,
      aws_api_gateway_integration.delete_record_lambda_integration.id,
      aws_api_gateway_integration.reports_lambda_integration.id,
      var.force_deploy
    ])))
  }
}

resource "aws_api_gateway_resource" "dns_record_resource" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  parent_id   = aws_api_gateway_rest_api.route53_api.root_resource_id
  path_part   = "route53dnsrecord"
}

resource "aws_api_gateway_resource" "reports_resource" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  parent_id   = aws_api_gateway_rest_api.route53_api.root_resource_id
  path_part   = "reports"
}

##Create Route53 Records Endpoint

resource "aws_api_gateway_method" "create_dns_record_post" {
  rest_api_id   = aws_api_gateway_rest_api.route53_api.id
  resource_id   = aws_api_gateway_resource.dns_record_resource.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "create_record_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  resource_id = aws_api_gateway_resource.dns_record_resource.id
  http_method = aws_api_gateway_method.create_dns_record_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.create_record_lambda.invoke_arn

  credentials = aws_iam_role.api_gateway_lambda_role.arn
}

resource "aws_api_gateway_method_response" "create_response_200" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  resource_id = aws_api_gateway_resource.dns_record_resource.id
  http_method = aws_api_gateway_method.create_dns_record_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}


##Delete Route53 Records Endpoint

resource "aws_api_gateway_method" "delete_dns_record_delete" {
  rest_api_id   = aws_api_gateway_rest_api.route53_api.id
  resource_id   = aws_api_gateway_resource.dns_record_resource.id
  http_method   = "DELETE"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "delete_record_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  resource_id = aws_api_gateway_resource.dns_record_resource.id
  http_method = aws_api_gateway_method.delete_dns_record_delete.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.delete_expired_records_lambda.invoke_arn

  credentials = aws_iam_role.api_gateway_lambda_role.arn
}

resource "aws_api_gateway_method_response" "delete_response_200" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  resource_id = aws_api_gateway_resource.dns_record_resource.id
  http_method = aws_api_gateway_method.delete_dns_record_delete.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}


##Reports Endpoint

resource "aws_api_gateway_method" "reports_post" {
  rest_api_id   = aws_api_gateway_rest_api.route53_api.id
  resource_id   = aws_api_gateway_resource.reports_resource.id
  http_method   = "POST"
  authorization = "AWS_IAM"
}

resource "aws_api_gateway_integration" "reports_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  resource_id = aws_api_gateway_resource.reports_resource.id
  http_method = aws_api_gateway_method.reports_post.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.records_report_lambda.invoke_arn

  credentials = aws_iam_role.api_gateway_lambda_role.arn
}

resource "aws_api_gateway_method_response" "reports_response_200" {
  rest_api_id = aws_api_gateway_rest_api.route53_api.id
  resource_id = aws_api_gateway_resource.reports_resource.id
  http_method = aws_api_gateway_method.reports_post.http_method
  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }
}