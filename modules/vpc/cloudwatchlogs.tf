//====================================================================================\\
//                          Creation of Cloudwatch Logs Resource                      \\
//====================================================================================\\

resource "aws_cloudwatch_log_group" "vpc_cloudwatch_logs" {
  name              = var.vpc_conf.vpc_cloudwatch_logs.name
  retention_in_days = var.vpc_conf.vpc_cloudwatch_logs.retention_in_days
  kms_key_id        = var.vpc_conf.vpc_cloudwatch_logs.create_kms ? aws_kms_key.cloudwatch_kms[0].arn : null

  depends_on = [aws_kms_key.cloudwatch_kms]
  tags = {
    "Environment" = var.environment
  }
}