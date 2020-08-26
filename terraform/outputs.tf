output "bucket_domain_name" {
  value       = aws_s3_bucket.opa_demo_bucket.bucket_domain_name
  description = "Bucket domain name"
}

output "bucket_regional_domain_name" {
  value       = aws_s3_bucket.opa_demo_bucket.bucket_regional_domain_name
  description = "Bucket regional domain name"
}
