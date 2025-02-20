terraform {
  backend "s3" {
    bucket         = "terraform-state-jenkins-sksri"
    key            = "jenkins-pipeline/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
  }
}