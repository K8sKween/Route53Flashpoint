

resource "aws_cloudwatch_event_rule" "check_expired_records" {
  name                = "check-expired-route53-records"
  description         = "Trigger Lambda to check and delete expired Route53 DNS records"
  schedule_expression = var.expired_records_check_rate_expression
}

resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule      = aws_cloudwatch_event_rule.check_expired_records.name
  target_id = "InvokeLambdaToDeleteExpiredRecords"
  arn       = aws_lambda_function.delete_expired.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_expired.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.check_expired_records.arn
}
