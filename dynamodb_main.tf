resource "aws_dynamodb_table" "dns_records" {
  name           = "Route53FlashpointDNSRecords"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "RecordName"
  range_key      = "RecordType"

  attribute {
    name = "RecordName"
    type = "S"
  }

  attribute {
    name = "RecordType"
    type = "S"
  }

  attribute {
    name = "ExpirationDate"
    type = "S"
  }
}
