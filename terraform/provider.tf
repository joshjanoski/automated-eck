# Create AWS provider and set to region variable in variables.tf

provider "aws" {
  region = var.aws_region
}

# Set Terraform and AWS provider versions

terraform {
  required_version = ">=1.12"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
