# Main Terraform file
provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "jenkins-sk-main-${var.env}"
  force_destroy = true
  
  tags = {
    Environment = var.env
    CreatedBy  = "jenkins-pipeline"
    ManagedBy  = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "demo_bucket_versioning" {
  bucket = aws_s3_bucket.demo_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}