output "dns_record_endpoint" {
  description = "API Gateway endpoint for DNS record resource"
  value       = aws_api_gateway_resource.dns_record_resource.id
}

output "reports_endpoint" {
  description = "API Gateway endpoint for reports resource"
  value       = aws_api_gateway_resource.reports_resource.id
}

output "api_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.route53_api.id
}