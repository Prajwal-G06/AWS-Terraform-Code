//====================================================================================\\
//                                    Global Variable                                 \\
//====================================================================================\\

environment = "iac-code-modules"
region      = "ap-south-1"

//====================================================================================\\
//                          Input Flags for resource creation                         \\
//====================================================================================\\

create = {
  # Flag for VPC, if VPC is set to true, the vpc will be created or if set to false the existing vpc will be created.
  vpc = false
  existing_vpc = false
  s3  = false
}

//====================================================================================\\
//                                 VPC Configuration                                  \\
//====================================================================================\\

vpc_conf = {
  vpc = {
    cidr_vpc = "10.0.0.0/16"
  }

  subnets = {
    public_subnets = {
      cidr = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
    }
    private_subnets = {
      cidr = ["10.0.48.0/20", "10.0.64.0/20", "10.0.80.0/20"]
    }
    private_db_subnets = {
      cidr = ["10.0.96.0/20", "10.0.112.0/20", "10.0.128.0/20"]
    }
  }

  enable_dns_support      = true        # Enable DNS support for the VPC
  enable_dns_hostnames    = true        # Enable DNS hostname for the VPC
  map_public_ip_on_launch = true        # Map public IP on launch for instances in public subnets
  cidr_block              = "0.0.0.0/0" # CIDR block for the VPC

  vpc_cloudwatch_logs = {
    name              = "/aws/vpc/vpc_flow_logs"
    retention_in_days = 0
  }

  vpc_flow_logs = {
    traffic_type    = "ALL"
    iam_role_name   = "vpc_flow_logs_role"
    iam_policy_name = "vpc_flow_logs_policy"
  }

  cloudwatch_kms = {
    description             = "An example symmetric encryption KMS key"
    enable_key_rotation     = false
    deletion_window_in_days = 28
    alias_name              = "cloudwatch-kms"
  }

  existing_vpc = {
    environment       = "already-formed-vpc"
    existing_vpc_name = "vpc"
    existing_public_subnet_names = [
      "pu-1", "pu-2"
    ]
    existing_private_app_subnet_names = [
      "pv-1", "pv-2"
    ]
    existing_db_subnet_names = [
      "project-subnet-private4-ap-south-1a", "project-subnet-private5-ap-south-1b", "project-subnet-private6-ap-south-1c"
    ]
  }
}

//====================================================================================\\
//                                  S3 Configuration                                  \\
//====================================================================================\\

s3_conf = {
  s3_bucket         = "demo-bucket"
  versioning_status = "Enabled"

  bucket_encryption = {
    is_enabled    = true
    sse_algorithm = "aws:kms"
    create_cmk    = true #If set to false the default aws/s3 AWS KMS master key is used.
  }

  lifecycle_rules = {
    rule_name  = "all"
    is_enabled = "Enabled"
    current_version_objects = {
      transition_days          = 90
      transition_storage_class = "GLACIER"
      expiration_days          = 100
    }
    non_current_version_objects = {
      transition_days          = 90
      transition_storage_class = "GLACIER"
      expiration_days          = 100
    }
    filter_prefix = ""
  }

  static_website = {
    enable         = false #If set to true, provide index and error document values
    index_document = "index.html"
    error_document = "error.html"
  }

  block = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }

  additional_tags = {
    Workload-Type = "bucket"
  }

  s3_cmk = {
    cmk_name                = "s3-cmk"
    cmk_description         = "CMK for s3 encryption"
    deletion_window_in_days = 7
    enable_key_rotation     = true
    additional_tags = {
    }
  }
}

