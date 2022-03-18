data "aws_key_pair" "asg_key" {
  key_name = "asg-key"
}

data "archive_file" "zip_file" {
  type = "zip"
  source_file = "lambda_code.py"
  output_path = "lambda_code.zip"
}