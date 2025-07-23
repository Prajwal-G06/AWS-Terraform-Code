//====================================================================================\\
//                                 Creation of KMS Resource                           \\
//====================================================================================\\

data "aws_caller_identity" "current" {}

resource "aws_kms_alias" "kms_alias" {
  count         = var.vpc_conf.vpc_cloudwatch_logs.create_kms ? 1 : 0

  name          = "alias/${var.environment}-${var.vpc_conf.cloudwatch_kms.alias_name}"
  target_key_id = aws_kms_key.cloudwatch_kms[0].key_id
}

resource "aws_kms_key" "cloudwatch_kms" {
  count = var.vpc_conf.vpc_cloudwatch_logs.create_kms ? 1 : 0

  description             = var.vpc_conf.cloudwatch_kms.description
  enable_key_rotation     = var.vpc_conf.cloudwatch_kms.enable_key_rotation
  deletion_window_in_days = var.vpc_conf.cloudwatch_kms.deletion_window_in_days

  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "key-cloudwatch-and-admin"
    Statement = [
      {
        Sid    = "Allow CloudWatch Logs to use the key for all log groups"
        Effect = "Allow"
        Principal = {
          Service = "logs.${var.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Sid    = "Allow account to manage key"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "kms:*"
        Resource = "*"
      }
    ]
  })

  tags = {
    "Name"        = "${var.environment}-cloudwatch-kms"
    "Environment" = var.environment
  }
}


