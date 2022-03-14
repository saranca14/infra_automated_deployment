terraform {
  backend "s3" {
    bucket = "ca14-infra-jenkins-deployment"
    key    = "remote_tfstate.tf"
    region = "ap-south-1"
  }
}