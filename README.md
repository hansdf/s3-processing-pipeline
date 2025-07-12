> **Note:** This project is a work in progress and is not yet complete.

# My Serverless AWS Processing Pipeline

This is a personal project built to practice and showcase my skills in cloud computing, automation, and DevOps. My goal was to create a fully automated, event-driven pipeline on AWS using modern infrastructure-as-code and CI/CD practices.

## What It Does

At its core, this project is a **reusable template for serverless file processing**. While I've implemented a simple image thumbnail generator as the initial example, the image processing itself is not the focus. The real goal is the underlying architecture, which can be easily adapted for other tasks like analyzing text files, redacting data, or converting document formats.

The entire process is serverless and fully automated:

1.  Starts by uploading a file to a specific S3 bucket.
2.  This upload event automatically triggers an AWS Lambda function, which holds the Python processing script.
3.  The script then performs a processes the file somehow, currently generating an thumbnail image of the image initially uploaded.
4.  Finally, the script saves the resulting output into a separate S3 bucket.

The entire system is "hands-off." It just waits for a new file and processes it on its own.

## Technologies Used

* **AWS Lambda, S3, and IAM** for the core serverless architecture and security.
* **Python (with Boto3)** to write the processing logic that runs inside the Lambda function.
* **Terraform** to define and manage all of the AWS infrastructure as code.
* **GitHub Actions** to create a CI/CD pipeline that automatically deploys the Python code whenever I push an update to this repository.