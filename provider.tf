terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state in S3. Bucket/key/region are supplied at init time:
  #   terraform init -backend-config=backend.hcl
  # See backend.hcl.example.
  backend "s3" {}
}

# Credentials come from the standard AWS chain (AWS_PROFILE, environment
# variables, SSO, or an instance role). Nothing is hard-coded here.
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = var.project_name
      ManagedBy = "Terraform"
    }
  }
}
