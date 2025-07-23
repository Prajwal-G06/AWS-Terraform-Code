#--------------- VPC variables ---------------#

variable "region" {
  description = "Region for infrastructure deployment"
}

variable "vpc_conf" {
  description = "VPC variables"
}

variable "environment" {
  description = "Environment tag"
}