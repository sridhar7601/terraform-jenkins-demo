# terraform/variables.tf
variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}