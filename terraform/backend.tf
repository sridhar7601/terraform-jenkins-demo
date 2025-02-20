# backend.tf - Place this in your terraform directory
terraform {
  backend "s3" {
    # Empty - values will be supplied by Jenkins pipeline
  }
}