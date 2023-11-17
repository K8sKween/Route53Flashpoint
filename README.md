# Route53Flashpoint Terraform Module

## Overview

Route53Flashpoint is a Terraform module designed to dynamically manage ephemeral AWS Route 53 DNS records. It automates the lifecycle of DNS records, integrates seamlessly with AWS services like Lambda, API Gateway, and DynamoDB, and offers API-driven interactions for record management and reporting.

## Features

- **Automated DNS Record Management**: Create, update, and delete AWS Route53 DNS records across multiple AWS accounts.
- **Expiration Tracking**: Utilize DynamoDB for tracking record expirations and automated deletion.
- **API Endpoints**: Securely add new DNS records and generate reports of active records through API Gateway.
- **Event-Driven Architecture**: Leverage AWS Lambda and EventBridge for efficient, scalable operations.
- **Security and Scalability**: Built with security and scalability in mind, ensuring robust and efficient DNS management.

## Usage

```hcl
module "route53_flashpoint" {
  source = "path/to/route53flashpoint"

  // Define necessary variables
}
```

## Prerequisites

- AWS Account with necessary permissions.
- Terraform installed (version 0.14 or higher).

## Terraform Version

- Terraform 0.14+

## Providers

- AWS

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
// Define your input variables here

## Outputs

| Name | Description |
|------|-------------|
// Define your outputs here

## Resources Created

- AWS Lambda Functions for DNS management.
- API Gateway for secure API endpoints.
- DynamoDB table for record tracking.
- IAM roles and policies for secure operation.

## Security

- Ensure API keys for API Gateway are securely managed.
- Review IAM roles and policies for least privilege access.


## Contributions

Contributions to Route53Flashpoint are welcome. Please adhere to conventional pull request workflows and ensure all proposed changes are well documented and tested.
