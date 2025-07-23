//====================================================================================\\
//                                   Terraform Provider                               \\
//====================================================================================\\

provider "aws" {
  profile = "terraform-1"
  region  = var.region
}

terraform {
  required_version = ">= 0.15.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.90.0"
    }
  }

  # Store Terraform state remotely in an encrypted S3 bucket to enable team collaboration and state locking.
  backend "s3" {
    bucket  = "terraform-code-modules"
    key     = "backend/terraform.tfstate"
    region  = "ap-south-1"
    encrypt = true
  }
}

