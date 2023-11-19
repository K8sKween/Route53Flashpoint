data "archive_file" "lambda_zip" {
    type        = "zip"
    source_file = "create_record.py"
    output_path = "${path.module}/create_record.zip"
}

variable "hosted_zone_id" {
    type        = string
    description = "The ID of the hosted zone in which to create the record."

    validation {
        condition     = length(regexall("^[A-Z0-9]{14}$", var.hosted_zone_id)) == 1
        error_message = "The hosted_zone_id must be a valid ID in the format of a 14-character string containing only uppercase letters and digits."
    }
}

resource "aws_lambda_function" "create_record_lambda" {
    filename         = data.archive_file.lambda_zip.output_path
    function_name    = "create_record_lambda"
    role             = aws_iam_role.lambda_execution_role.arn
    handler          = "create_record.lambda_handler"
    runtime          = "python3.8"
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256

    environment {
        variables = {
            HOSTED_ZONE_ID = var.hosted_zone_id
        }
    }
}
