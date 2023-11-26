variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "expired_records_check_rate_expression" {
  type    = string
  default = "rate(1 hour)"
}

variable "hosted_zone_id" {
    type        = string
    description = "The ID of the hosted zone in which to create the record."

    validation {
        condition     = length(regexall("^[A-Z0-9]{14}$", var.hosted_zone_id)) == 1
        error_message = "The hosted_zone_id must be a valid ID in the format of a 14-character string containing only uppercase letters and digits."
    }
}