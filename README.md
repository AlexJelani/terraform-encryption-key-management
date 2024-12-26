# AWS Encryption Key Management with Terraform

This project demonstrates AWS encryption key management using Terraform, including:

- KMS key creation and management
- IAM roles with specific permissions
- Lambda functions for encrypted S3 operations
- S3 bucket with server-side encryption

## Prerequisites

- AWS CLI configured with administrator access
- Terraform installed (version 1.0.0 or later)
- AWS account with appropriate permissions

## Components

- Two IAM roles:
  - `cand-c3-l3-ex2-write` with S3 full access
  - `cand-c3-l3-ex2-read` with S3 read-only access
- KMS key for encryption
- S3 bucket for storing encrypted files
- Two Lambda functions:
  - Write function with encryption capabilities
  - Read function for accessing encrypted content

## Project Structure


terraform-aws-encryption-key-mgmt/
├── main.tf          # Main Terraform configuration
├── variables.tf     # Variable declarations
├── outputs.tf       # Output definitions
├── providers.tf     # Provider configuration
└── lambda/          # Lambda function code
    ├── write.py     # Write function
    └── read.py      # Read function


## Usage

1. Initialize Terraform:
   ```bash
   terraform init
