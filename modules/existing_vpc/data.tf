#--------------- Data Source ---------------#

data "aws_vpc" "selected" {
  count = var.create.existing_vpc ? 1 : 0

  filter {
    name   = "tag:Name"
    values = [var.vpc_conf.existing_vpc.existing_vpc_name]
  }
}

data "aws_subnets" "public_subnets" {
  count = var.create.existing_vpc ? 1 : 0

  filter {
    name   = "tag:Name"
    values = var.vpc_conf.existing_vpc.existing_public_subnet_names
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }
}

data "aws_subnets" "private_app_subnets" {
  count = var.create.existing_vpc ? 1 : 0

  filter {
    name   = "tag:Name"
    values = var.vpc_conf.existing_vpc.existing_private_app_subnet_names
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }
}

data "aws_subnets" "db_subnets" {
  count = var.create.existing_vpc ? 1 : 0

  filter {
    name   = "tag:Name"
    values = var.vpc_conf.existing_vpc.existing_db_subnet_names
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected[0].id]
  }
}
