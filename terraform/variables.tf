# terraform/outputs.tf
output "bucket_name" {
  value = aws_s3_bucket.demo_bucket.id
}