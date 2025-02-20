# backend.tf - Place this in your terraform directory
terraform {
  backend "s3" {
    bucket         = "terraform-state-storage-bucket"
    key            = "terraform/jenkins-demo/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-lock-table" # Optional but recommended for state locking
    encrypt        = true
  }
}