//====================================================================================\\
//                               S3 CMK policy                                        \\
//====================================================================================\\

data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = ["*"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
  statement {
    sid    = "keyUsage"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_session_context.current.issuer_arn]
    }
    actions = [
      "kms:CreateGrant",
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
    resources = [
      "*",
    ]
    condition {
      test     = "StringEquals"
      variable = "kms:CallerAccount"
      values   = ["${data.aws_caller_identity.current.account_id}"]
    }
  }
}

//====================================================================================\\
//                                     S3 CMK                                         \\
//====================================================================================\\

resource "aws_kms_key" "s3" {
  count                   = var.s3_conf.bucket_encryption.create_cmk == true ? 1 : 0
  description             = var.s3_conf.s3_cmk.cmk_description
  deletion_window_in_days = var.s3_conf.s3_cmk.deletion_window_in_days
  enable_key_rotation     = var.s3_conf.s3_cmk.enable_key_rotation
  policy                  = data.aws_iam_policy_document.s3_policy.json
  tags = merge(
    {
      Environment = var.environment
    },
    var.s3_conf.s3_cmk.additional_tags
  )
}

//====================================================================================\\
//                                    S3 CMK Alais                                    \\
//====================================================================================\\

resource "aws_kms_alias" "s3" {
  count         = var.s3_conf.bucket_encryption.create_cmk == true ? 1 : 0
  name          = "alias/${var.environment}-${var.s3_conf.s3_cmk.cmk_name}"
  target_key_id = var.s3_conf.bucket_encryption.create_cmk == true ? aws_kms_key.s3[0].key_id : null
}