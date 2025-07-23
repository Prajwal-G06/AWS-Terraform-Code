#--------------- S3 variables ---------------#

variable "region" {
  description = "Region for infrastructure deployment"
}

variable "environment" {
  description = "Environment tag"
}

variable "s3_conf" {
  description = "All s3 and related configurations"
}
