resource "aws_dynamodb_table" "dns_records" {
  name         = "Route53FlashpointDNSRecords"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "RecordName"
  range_key    = "RecordType"
  tags         = var.common_tags
  attribute {
    name = "RecordName"
    type = "S"
  }

  attribute {
    name = "RecordType"
    type = "S"
  }

  attribute {
    name = "delete_after"
    type = "S"
  }

  // Define the Global Secondary Index
  global_secondary_index {
    name            = "DeleteAfterIndex"
    hash_key        = "delete_after"
    projection_type = "ALL" // or "KEYS_ONLY" or "INCLUDE"

  }
}