resource "aws_lambda_function" "SSM_lambda" {
  filename      = data.archive_file.zip_file.output_path
  function_name = "SSM_lambda"
  role          = aws_iam_role.SSM_lambda_role.arn
  handler       = "lambda_code.lambda_handler"

  source_code_hash = filebase64sha256(data.archive_file.zip_file.output_path)

  runtime = "python3.8"
  timeout = 60

  environment {
    variables = {
      foo = "bar"
    }
  }
}