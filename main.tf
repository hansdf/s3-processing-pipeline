provider "aws" {
  region = "us-east-1"
}

# two S3 buckets, one for input that will trigger the initial workflow, and another for output processed files
resource "aws_s3_bucket" "input_bucket" {
  bucket = "input-bucket-s3-img-processing-pipeline-hansdf"
}
resource "aws_s3_bucket" "output_bucket" {
  bucket = "output-bucket-s3-img-processing-pipeline-hansdf" 
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

# IAM policy for lambda
resource "aws_iam_policy" "lambda_policy" {
  name   = "serverless_processing_policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:GetObject"],
        Resource = "${aws_s3_bucket.input_bucket.arn}/*"
      },
      {
        Effect   = "Allow",
        Action   = ["s3:PutObject"],
        Resource = "${aws_s3_bucket.output_bucket.arn}/*" 
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_policy" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
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

# S3 trigger that starts the lambda
resource "aws_s3_bucket_notification" "bucket_trigger" {
  bucket = aws_s3_bucket.input_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.processing_function.arn
    events              = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_lambda_permission.allow_s3]
}

resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processing_function.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.input_bucket.arn
}
