
# Define the Lambda function
resource "aws_lambda_function" "delete_expired_records" {
  filename         = "./delete_expired.py"
  function_name    = "delete_expired_records"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  timeout          = 60
  memory_size      = 128
}


