terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_iam_role" "basic_lambda_role" {
name   = "basic-lambda-role"
assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "basic_lambda_policy" {
 
name         = "basic_lambda_policy"
path         = "/"
description  = "Basic IAM Policy for Lambda"
policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": [
       "logs:CreateLogGroup",
       "logs:CreateLogStream",
       "logs:PutLogEvents"
     ],
     "Resource": "arn:aws:logs:*:*:*",
     "Effect": "Allow"
   }
 ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "policy_role_attachment" {
role        = aws_iam_role.basic_lambda_role.name
policy_arn  = aws_iam_policy.basic_lambda_policy.arn
}

data "archive_file" "code_zip" {
type        = "zip"
source_dir  = "${path.module}/../lambda/"
output_path = "${path.module}/../lambda/hello-world.zip"
}

resource "aws_lambda_function" "terraform_basic_lambda_func" {
filename                       = "${data.archive_file.code_zip.output_path}"
function_name                  = "Basic_Lambda_Function"
role                           = aws_iam_role.basic_lambda_role.arn
handler                        = "index.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.policy_role_attachment]
}