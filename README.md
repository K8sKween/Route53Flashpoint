# Route53Flashpoint Terraform Module

## Overview

Route53Flashpoint is a Terraform module designed to dynamically manage ephemeral AWS Route 53 DNS records. It automates the lifecycle of DNS records, integrates seamlessly with AWS services like Lambda, API Gateway, and DynamoDB, and offers API-driven interactions for record management and reporting.

## Features

- **Automated DNS Record Management**: Create, update, and delete AWS Route53 DNS records.

- **Expiration Tracking**: Utilize DynamoDB for tracking record expiration and automated deletion.

- **API Endpoints**: Securely add new DNS records and generate reports of active records through API Gateway.

- **Event-Driven Architecture**: Leverage AWS Lambda and EventBridge for efficient, scalable operations.

- **Security and Scalability**: Built with security and scalability in mind, ensuring robust and efficient DNS management.

## Usage

### Terraform

```hcl

module "route53_flashpoint" {
source = "path/to/route53flashpoint"

aws_region =  "us-east-1"
hosted_zone_id =  "ABCDEF1234"
expired_records_check_rate_expression =  "rate(1 hour)"
common_tags =  {
Terraform =  "true",
}

```

### API

Create a new DNS record with expiration date:

```
curl -X POST https://{{API_ID}}.execute-api.{{REGION}}.amazonaws.com/v1/route53dnsrecord \
     -H "Authorization: AWS4-HMAC-SHA256 Credential=YOUR_ACCESS_KEY/20231126/region/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=YOUR_SIGNATURE" \
     -H "x-amz-date: 20231126T000000Z" \
     -H "Content-Type: application/json" \
     -d '{
           "name": "temp_domain.example.com",
           "type": "A",
           "value": "192.0.2.44",
           "ttl": 600,
           "delete_after": "2023-11-28T16:43:59Z"
         }'

```

Check for expired records and delete if found:

```
curl -X DELETE https://{{API_ID}}.execute-api.{{REGION}}.amazonaws.com/v1/route53dnsrecord \
     -H "Authorization: AWS4-HMAC-SHA256 Credential=YOUR_ACCESS_KEY/20231126/region/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=YOUR_SIGNATURE" \
     -H "x-amz-date: 20231126T000000Z" \
     -H "Content-Type: application/json"
```

Get a report on domains and expiration:

```
curl -X POST https://{{API_ID}}.execute-api.{{REGION}}.amazonaws.com/v1/reports \
     -H "Authorization: AWS4-HMAC-SHA256 Credential=YOUR_ACCESS_KEY/20231126/region/service/aws4_request, SignedHeaders=host;x-amz-date, Signature=YOUR_SIGNATURE" \
     -H "x-amz-date: 20231126T000000Z" \
     -H "Content-Type: application/json"
```

## Prerequisites

- Terraform installed (version 0.14 or higher).

## Terraform Version

- Terraform 0.14+

## Providers

- AWS

## Inputs

| Name                                    | Description                                                                                                                          | Type        | Default               | Required |
| --------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ | ----------- | --------------------- | :------: |
| `aws_region`                            | AWS region to deploy resources                                                                                                       | string      | "us-east-1"           |    no    |
| `expired_records_check_rate_expression` | Rate expression for checking expired records                                                                                         | string      | "rate(1 hour)"        |    no    |
| `hosted_zone_id`                        | The ID of the hosted zone in which to create the record. Must be a 14-character string containing only uppercase letters and digits. | string      | -                     |   yes    |
| `common_tags`                           | Common tags to apply to all resources                                                                                                | map(string) | {"Terraform": "true"} |    no    |

## Outputs

| Name                  | Description                                  |
| --------------------- | -------------------------------------------- |
| `dns_record_endpoint` | API Gateway endpoint for DNS record resource |
| `reports_endpoint`    | API Gateway endpoint for reports resource    |

## Resources Created

| Terraform Resources                                          |
| ------------------------------------------------------------ |
| data.archive_file.create_record_lambda_zip                   |
| data.archive_file.delete_expired_records_lambda_zip          |
| data.archive_file.records_report_lambda_zip                  |
| aws_api_gateway_deployment.route53_api_deployment            |
| aws_api_gateway_integration.create_record_lambda_integration |
| aws_api_gateway_integration.delete_record_lambda_integration |
| aws_api_gateway_integration.reports_lambda_integration       |
| aws_api_gateway_method.create_dns_record_post                |
| aws_api_gateway_method.delete_dns_record_delete              |
| aws_api_gateway_method.reports_post                          |
| aws_api_gateway_method_response.create_response_200          |
| aws_api_gateway_method_response.delete_response_200          |
| aws_api_gateway_method_response.reports_response_200         |
| aws_api_gateway_resource.dns_record_resource                 |
| aws_api_gateway_resource.reports_resource                    |
| aws_api_gateway_rest_api.route53_api                         |
| aws_cloudwatch_event_rule.check_expired_records              |
| aws_cloudwatch_event_target.invoke_lambda                    |
| aws_dynamodb_table.dns_records                               |
| aws_iam_role.api_gateway_lambda_role                         |
| aws_iam_role.lambda_execution_role                           |
| aws_iam_role_policy.api_gateway_lambda_policy                |
| aws_iam_role_policy.lambda_policy                            |
| aws_lambda_function.create_record_lambda                     |
| aws_lambda_function.delete_expired_records_lambda            |
| aws_lambda_function.records_report_lambda                    |
| aws_lambda_permission.allow_eventbridge                      |

## Contributions

Contributions to Route53Flashpoint are welcome. Please adhere to conventional pull request workflows and ensure all proposed changes are well documented and tested.
