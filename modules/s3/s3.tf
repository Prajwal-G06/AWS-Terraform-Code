//====================================================================================\\
//                   Creation of Random String for S3 Bucket Names                    \\
//====================================================================================\\

resource "random_string" "random" {
  length    = 8
  special   = false
  min_lower = 8
}

//====================================================================================\\
//                                   Creation of S3 Bucket                            \\
//====================================================================================\\

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.environment}-${var.s3_conf.s3_bucket}-${random_string.random.result}"
  force_destroy = true
  tags = merge(
    {
      Name = "${var.environment}-${var.s3_conf.s3_bucket}"
      Env  = var.environment
    },
    var.s3_conf.additional_tags
  )
}

//====================================================================================\\
//                                  Bucket Policy                                     \\
//====================================================================================\\

data "aws_iam_policy_document" "bucket_policy" {
  statement {
    sid    = "AllowSSLRequestsOnly"
    effect = "Deny"
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    actions = [
      "s3:*",
    ]
    resources = [
      "${aws_s3_bucket.s3_bucket.arn}",
      "${aws_s3_bucket.s3_bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json
}



//====================================================================================\\
//                           Enabling S3 Bucket Encryption                            \\
//====================================================================================\\

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  depends_on = [aws_kms_key.s3]
  count      = var.s3_conf.bucket_encryption.is_enabled == true ? 1 : 0
  bucket     = aws_s3_bucket.s3_bucket.id
  rule {
    bucket_key_enabled = var.s3_conf.bucket_encryption.is_enabled
    apply_server_side_encryption_by_default {
      kms_master_key_id = (var.s3_conf.bucket_encryption.create_cmk == true) ? aws_kms_key.s3[0].key_id : null
      sse_algorithm     = var.s3_conf.bucket_encryption.sse_algorithm
    }
  }
}

//====================================================================================\\
//                              Block public access for S3 Bucket                     \\
//====================================================================================\\

resource "aws_s3_bucket_public_access_block" "block_bucket" {
  bucket                  = aws_s3_bucket.s3_bucket.id
  block_public_acls       = var.s3_conf.block.block_public_acls
  block_public_policy     = var.s3_conf.block.block_public_policy
  ignore_public_acls      = var.s3_conf.block.ignore_public_acls
  restrict_public_buckets = var.s3_conf.block.restrict_public_buckets
}

//====================================================================================\\
//                                Enable S3 Bucket Versioning                         \\
//====================================================================================\\

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.s3_bucket.id
  versioning_configuration {
    status = var.s3_conf.versioning_status
  }
}

//====================================================================================\\
//                                Enable S3 static website                            \\
//====================================================================================\\

resource "aws_s3_bucket_website_configuration" "s3_website" {
  count  = (var.s3_conf.static_website.enable == true) ? 1 : 0
  bucket = aws_s3_bucket.s3_bucket.id

  index_document {
    suffix = var.s3_conf.static_website.index_document
  }

  error_document {
    key = var.s3_conf.static_website.error_document
  }
}

//====================================================================================\\
//                                Enable S3 lifecycle rules                           \\
//====================================================================================\\

resource "aws_s3_bucket_lifecycle_configuration" "configuration" {
  bucket     = aws_s3_bucket.s3_bucket.id
  depends_on = [aws_s3_bucket.s3_bucket]
  rule {
    id     = var.s3_conf.lifecycle_rules.rule_name
    status = var.s3_conf.lifecycle_rules.is_enabled

    filter {
      prefix = var.s3_conf.lifecycle_rules.filter_prefix
    }

    transition {
      days          = var.s3_conf.lifecycle_rules.current_version_objects.transition_days
      storage_class = var.s3_conf.lifecycle_rules.current_version_objects.transition_storage_class
    }

    expiration {
      days = var.s3_conf.lifecycle_rules.current_version_objects.expiration_days
    }

    noncurrent_version_transition {
      noncurrent_days = var.s3_conf.lifecycle_rules.non_current_version_objects.transition_days
      storage_class   = var.s3_conf.lifecycle_rules.non_current_version_objects.transition_storage_class
    }

    noncurrent_version_expiration {
      noncurrent_days = var.s3_conf.lifecycle_rules.non_current_version_objects.expiration_days
    }
  }
}