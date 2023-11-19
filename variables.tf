variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-west-2"
}

variable "expired_records_check_rate_expression" {
  type    = string
  default = "rate(1 hour)"
}