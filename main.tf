provider "aws" {
  region = "us-east-1"
}

# two S3 buckets, one for input that will trigger the initial workflow, and another for output processed files
resource "aws_s3_bucket" "input_bucket" {
  bucket = "input-bucket-s3-img-processing-pipeline"
}
resource "aws_s3_bucket" "output_bucket" {
  bucket = "output-bucket-s3-img-processing-pipeline" 
}

# IAM role for lambda func
resource "aws_iam_role" "lambda_exec_role" {
  name = "serverless_processing_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# lambda func itself
resource "aws_lambda_function" "processing_function" {
  function_name    = "serverless-file-processor"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "process_file.lambda_handler"
  runtime          = "python3.9"
  filename         = "deployment_package.zip"
  source_code_hash = filebase64sha256("deployment_package.zip")
}

# MISSING:
# IAM policy for lambda
# attach policy to role
# s3 Trigger that calls the lambda func
# permission for s3?
