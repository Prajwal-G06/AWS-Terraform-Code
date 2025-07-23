#--------------- Global variables ---------------#
variable "region" {
  description = "Region for infrastructure deployment."
}

variable "environment" {
  description = "Environment tag."
}

variable "create" {
  description = "This variable is used to create different AWS services. "
}

#--------------- Module variables ---------------#
variable "vpc_conf" {
  description = "VPC variables."
}

variable "s3_conf" {
  description = "All s3 and related configurations"
}