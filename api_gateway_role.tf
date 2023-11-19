resource "aws_iam_role" "api_gateway_lambda_role" {
  name = "api_gateway_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "apigateway.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_role_policy" "api_gateway_lambda_policy" {
  name   = "api_gateway_lambda_policy"
  role   = aws_iam_role.api_gateway_lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ],
        Effect = "Allow",
        Resource = "*"
      },
    ],
  })
}
