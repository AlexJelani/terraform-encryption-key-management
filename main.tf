# KMS Key
resource "aws_kms_key" "encryption_key" {
  description             = "${var.project_name}-key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "*"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Read Role to use the key"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.read_role.arn
        }
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey"
        ]
        Resource = "*"
      }
    ]
  })
}
resource "aws_kms_alias" "key_alias" {
  name          = "alias/${var.project_name}-key"
  target_key_id = aws_kms_key.encryption_key.key_id
}

# IAM Roles
resource "aws_iam_role" "write_role" {
  name = "${var.project_name}-write"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role" "read_role" {
  name = "${var.project_name}-read"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Role Policies
resource "aws_iam_role_policy_attachment" "write_lambda_execute" {
  role       = aws_iam_role.write_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "write_s3_full" {
  role       = aws_iam_role.write_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "read_lambda_execute" {
  role       = aws_iam_role.read_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "read_s3_read" {
  role       = aws_iam_role.read_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# S3 Bucket
resource "aws_s3_bucket" "encrypted_bucket" {
  bucket = local.bucket_name
  }
resource "random_string" "suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  bucket_name = "cand-c3-l3-ex2-bucket-${random_string.suffix.result}"
}


resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.encrypted_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.encryption_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Lambda Functions
resource "aws_lambda_function" "write_function" {
  filename      = "${path.module}/lambda/write.zip"
  function_name = "${var.project_name}-lambda-write"
  role          = aws_iam_role.write_role.arn
  handler       = "write.lambda_handler"
  runtime       = "python3.9"

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.encrypted_bucket.id
      KEY_ARN   = aws_kms_key.encryption_key.arn
    }
  }
}

resource "aws_lambda_function" "read_function" {
  filename      = "${path.module}/lambda/read.zip"
  function_name = "${var.project_name}-lambda-read"
  role          = aws_iam_role.read_role.arn
  handler       = "read.lambda_handler"  # This matches your Python file name and function
  runtime       = "python3.9"

  environment {
    variables = {
      S3_BUCKET = aws_s3_bucket.encrypted_bucket.id
    }
  }
}

