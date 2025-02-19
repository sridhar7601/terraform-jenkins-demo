# terraform/main.tf
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "jenkins-terraform-srsu-${var.environment}"
  force_destroy = true
}

resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}