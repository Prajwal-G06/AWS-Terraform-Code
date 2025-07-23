//====================================================================================\\
//                                    VPC Module                                      \\
//====================================================================================\\

module "vpc" {
  source      = "./modules/vpc"
  region      = var.region
  vpc_conf    = var.vpc_conf
  environment = var.environment

  count = var.create.vpc ? 1 : 0
}

module "vpc_existing" {
  source   = "./modules/existing_vpc"
  vpc_conf = var.vpc_conf
  create = var.create

  count = var.create.existing_vpc ? 1 : 0
}

//====================================================================================\\
//                                     S3 Module                                      \\
//====================================================================================\\

module "s3" {
  source      = "./modules/s3"
  region      = var.region
  environment = var.environment
  s3_conf     = var.s3_conf

  count = var.create.s3 ? 1 : 0
}
