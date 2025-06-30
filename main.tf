provider "aws" {
  region = "us-east-1"
}

# two S3 buckets, one for input that will trigger the initial workflow, and another for output processed files
resource "aws_s3_bucket" "input_bucket" {
  bucket = "input_bucket_s3_img_processing_pipeline"
}

resource "aws_s3_bucket" "output_bucket" {
  bucket = "output_bucket_s3_img_processing_pipeline" 
}