resource "aws_vpc" "test_vpc" {
  cidr_block = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_movie_analyzer1_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

data "archive_file" "python-code-zip" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/lambda.zip"
}

# Create the Lambda function
resource "aws_lambda_function" "movie_analyzer_function" {
  filename      = data.archive_file.python-code-zip.output_path 
  function_name = "movie_analyzer1_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "python3.9"
  timeout       = 10
}

# Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "movie_api" {
  name = "movie_api"
}

# Create a resource and method for the POST endpoint
resource "aws_api_gateway_resource" "movie_resource" {
  rest_api_id = aws_api_gateway_rest_api.movie_api.id
  parent_id   = aws_api_gateway_rest_api.movie_api.root_resource_id
  path_part   = "movies"
}

resource "aws_api_gateway_method" "movie_method" {
  rest_api_id   = aws_api_gateway_rest_api.movie_api.id
  resource_id   = aws_api_gateway_resource.movie_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

