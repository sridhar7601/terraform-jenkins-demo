# backend.tf
terraform {
  backend "s3" {
    # Empty - values will be supplied by Jenkins pipeline
  }
}