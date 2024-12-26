output "kms_key_arn" {
  description = "The ARN of the KMS key"
  value       = aws_kms_key.encryption_key.arn
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.encrypted_bucket.id
}

output "write_function_name" {
  description = "The name of the write Lambda function"
  value       = aws_lambda_function.write_function.function_name
}

output "read_function_name" {
  description = "The name of the read Lambda function"
  value       = aws_lambda_function.read_function.function_name
}
