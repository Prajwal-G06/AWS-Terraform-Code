//====================================================================================\\
//                                 Creation of VPC Resource                           \\
//====================================================================================\\

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_conf.vpc.cidr_vpc
  enable_dns_support   = var.vpc_conf.enable_dns_support
  enable_dns_hostnames = var.vpc_conf.enable_dns_hostnames
  tags = {
    "Name"        = "${var.environment}-vpc"
    "Environment" = var.environment
  }
}

//====================================================================================\\
//                             Creation of Internet Gateway                           \\
//====================================================================================\\

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name"        = "${var.environment}-internet-gateway"
    "Environment" = var.environment
  }
}

//====================================================================================\\
//                               Creation of Elastic IP's                             \\
//====================================================================================\\

resource "aws_eip" "natA" {
  domain = "vpc"
}

//====================================================================================\\
//                               Creation of Nat F=Gateway                            \\
//====================================================================================\\

resource "aws_nat_gateway" "ngwA" {
  depends_on    = [aws_internet_gateway.igw]
  allocation_id = aws_eip.natA.id
  subnet_id     = aws_subnet.public_subnets[0].id
  tags = {
    "Name"        = "${var.environment}-nat-gateway"
    "Environment" = var.environment
  }
}

//====================================================================================\\
//                               Creation of Public Subnets                           \\
//====================================================================================\\

resource "aws_subnet" "public_subnets" {
  count                   = length(var.vpc_conf.subnets.public_subnets.cidr)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = var.vpc_conf.map_public_ip_on_launch
  cidr_block              = element(var.vpc_conf.subnets.public_subnets.cidr, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        = "${var.environment}-public-subnet-${count.index}"
    Environment = var.environment
  }
}

//====================================================================================\\
//                              Creation of Private Subnets                           \\
//====================================================================================\\

resource "aws_subnet" "private_subnets" {
  count             = length(var.vpc_conf.subnets.private_subnets.cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.vpc_conf.subnets.private_subnets.cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        = "${var.environment}-private-subnet-${count.index}"
    Environment = var.environment
  }
}

//====================================================================================\\
//                            Creation of Private DB Subnets                          \\
//====================================================================================\\

resource "aws_subnet" "private_db_subnets" {
  count             = length(var.vpc_conf.subnets.private_db_subnets.cidr)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = element(var.vpc_conf.subnets.private_db_subnets.cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name        = "${var.environment}-private-db-subnet-${count.index}"
    Environment = var.environment
  }
}

//====================================================================================\\
//                            Creation of Public Route Table                          \\
//====================================================================================\\

resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.vpc_conf.cidr_block
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    "Name"        = "${var.environment}-public-route-table"
    "Environment" = var.environment
  }
}

//====================================================================================\\
//                           Creation of Private Route Table                          \\
//====================================================================================\\

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = var.vpc_conf.cidr_block
    gateway_id = aws_nat_gateway.ngwA.id
  }
  tags = {
    "Name"        = "${var.environment}-private-route-table"
    "Environment" = var.environment
  }
}

//====================================================================================\\
//                          Creation of Private DB Route Table                        \\
//====================================================================================\\

resource "aws_route_table" "private_db_rtb" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name"        = "${var.environment}-private-route-table-db"
    "Environment" = var.environment
  }
}

//====================================================================================\\
//                        Creation of Public Route Table Association                  \\
//====================================================================================\\

resource "aws_route_table_association" "public_route_association" {
  count          = length(var.vpc_conf.subnets.public_subnets.cidr)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_rtb.id
}

//====================================================================================\\
//                       Creation of Private Route Table Association                  \\
//====================================================================================\\

resource "aws_route_table_association" "private_route_association" {
  count          = length(var.vpc_conf.subnets.private_subnets.cidr)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_rtb.id
}

//====================================================================================\\
//                     Creation of Private DB Route Table Association                 \\
//====================================================================================\\

resource "aws_route_table_association" "private_db_route_association" {
  count          = length(var.vpc_conf.subnets.private_db_subnets.cidr)
  subnet_id      = aws_subnet.private_db_subnets[count.index].id
  route_table_id = aws_route_table.private_db_rtb.id
}

//====================================================================================\\
//                              Creation of VPC Flow Logs                             \\
//====================================================================================\\

resource "aws_flow_log" "vpc_flow_logs" {
  iam_role_arn    = aws_iam_role.vpc_flow_logs_role.arn
  log_destination = aws_cloudwatch_log_group.vpc_cloudwatch_logs.arn
  traffic_type    = var.vpc_conf.vpc_flow_logs.traffic_type
  vpc_id          = aws_vpc.vpc.id
}

resource "aws_iam_role" "vpc_flow_logs_role" {
  name               = "${var.environment}-${var.vpc_conf.vpc_flow_logs.iam_role_name}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "iam_doc" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name   = "${var.environment}-${var.vpc_conf.vpc_flow_logs.iam_policy_name}"
  role   = aws_iam_role.vpc_flow_logs_role.id
  policy = data.aws_iam_policy_document.iam_doc.json
}