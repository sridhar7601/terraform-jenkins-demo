# terraform/outputs.tf

variable "env" {
  description = "The environment to deploy to (dev, stage, prod)"
  type        = string
}

variable "bucket_name_prefix" {
  default     = "myapp-bucket"
  description = "Prefix for S3 bucket name"
}
