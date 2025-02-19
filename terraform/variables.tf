# terraform/outputs.tf
variable "env" {
  description = "Deployment environment"
  type        = string
}

variable "bucket_name_prefix" {
  description = "S3 bucket name prefix"
  type        = string
}

