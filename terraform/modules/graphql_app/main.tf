terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
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

#get graphql schema file from s3
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