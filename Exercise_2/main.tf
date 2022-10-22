# Designate a cloud provider, region, and credentials
provider "aws" {
  profile = "default"
  region = var.aws_region
}

resource "aws_cloudwatch_log_group" "greet_lambda_log_group" {
  name = "/aws/lambda/${aws_lambda_function.greet_lambda.function_name}"
  retention_in_days = 30
}

resource "aws_lambda_permission" "logging" {
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.greet_lambda.function_name
  principal     = "logs.us-east-1.amazonaws.com"
  source_arn    = "${aws_cloudwatch_log_group.greet_lambda_log_group.arn}:*"
}


# this definition was copied and modified from the Terraform example:
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function
resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#####
resource "aws_iam_policy" "iam_logging_for_lambda" {
  name = "iam_logging_for_lambda"
  description = "policy to allow lambda function to log in CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
      "Action": [
        #"logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
       }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "logging_lambda_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.iam_logging_for_lambda.arn

}

# Add Basic Execute Policy
resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
#####

data "archive_file" "lambda" {
  type = "zip"
  source_file = "./greet_lambda.py"
  output_path = "./greet_lambda.zip"
}

resource "aws_lambda_function" "greet_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename      = data.archive_file.lambda.output_path
  function_name = "greet_lambda"
  role          = aws_iam_role.iam_for_lambda.arn
  handler       = "greet_lambda.lambda_handler"


  runtime = "python3.8"

  environment {
    variables = {
      greeting = "Hello, Olley"
    }
  }
}
