terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# create public s3 ucket for graphql model
resource "aws_s3_bucket" "model_bucket" {
  bucket = "${var.app_name}.model.test.01"
  acl    = "public-read"
  tags   = {
    Name        = "graphql_model"
    Environment = "dev"
  }
}

# upload graphql model to s3
resource "aws_s3_bucket_object" "model" {
  depends_on   = [aws_s3_bucket.model_bucket]
  bucket       = "${var.app_name}.model.test.01"
  content_type = "text/graphqlschema"
  key          = basename(var.model_path)
  source       = var.model_path

  # check integrity of file upload by passing hashed etag header
  etag = filemd5(var.model_path)
}

# get graphql schema file from s3
data "aws_s3_bucket_object" "model_file" {
  depends_on = [aws_s3_bucket_object.model]
  bucket     = "${var.app_name}.model.test.01"
  key        = basename(var.model_path)
}

resource "aws_appsync_graphql_api" "appsync_endpoint" {
  authentication_type = "API_KEY"
  name                = "${var.app_name}.api.test.01"
  schema              = data.aws_s3_bucket_object.model_file.body
}

# get api key for testing
resource "aws_appsync_api_key" "temp_api_key" {
  api_id  = aws_appsync_graphql_api.appsync_endpoint.id
  expires = "2022-05-03T04:00:00Z"
}

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

# deploy functions
resource "aws_lambda_function" "resolver_functions" {
  for_each      = var.resolver_functions
  filename      = "${var.resolver_functions_path}${each.key}.zip"
  function_name = each.key
  handler       = "${each.key}.handler"
  role          = aws_iam_role.iam_for_lambda.arn

  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256("${var.resolver_functions_path}${each.key}.zip")

  runtime = "nodejs12.x"

  environment {
    variables = {
      name = "haslam"
    }
  }
}

# IAM Setup
# TODO: put this some place else
# Below setup from https://elopmental.dev/easy-appsync-with-terraform/

# Lambda role (TODO: do I need this?)
data "aws_iam_policy_document" "iam_lambda_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "iam_lambda_role" {
  name               = "graphapi_iam_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.iam_lambda_role_document.json
}

# Appsync role
data "aws_iam_policy_document" "iam_appsync_role_document" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["appsync.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "iam_appsync_role" {
  name               = "graphapi_iam_appsync_role"
  assume_role_policy = data.aws_iam_policy_document.iam_appsync_role_document.json
}

# Invoke Lambda policy
data "aws_iam_policy_document" "iam_invoke_lambda_policy_document" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "iam_invoke_lambda_policy" {
  name   = "graphapi_iam_invoke_lambda_policy"
  policy = data.aws_iam_policy_document.iam_invoke_lambda_policy_document.json
}

# Attach Invoke Lambda policy to AppSync role.
resource "aws_iam_role_policy_attachment" "appsync_invoke_lambda" {
  role       = aws_iam_role.iam_appsync_role.name
  policy_arn = aws_iam_policy.iam_invoke_lambda_policy.arn
}
