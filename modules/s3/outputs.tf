//====================================================================================\\
//                                      Outputs                                       \\
//====================================================================================\\

output "s3_bucket_arn" {
  value = aws_s3_bucket.s3_bucket.arn
}

output "s3_bucket_id" {
  value = aws_s3_bucket.s3_bucket.id
}

output "static_website_endpoint" {
  value = (var.s3_conf.static_website.enable == true) ? aws_s3_bucket_website_configuration.s3_website[0].website_endpoint : null
}

output "s3_cmk_arn" {
  value = (var.s3_conf.bucket_encryption.create_cmk == true) ? aws_kms_key.s3[0].arn : null
}
