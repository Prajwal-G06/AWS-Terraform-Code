//====================================================================================\\
//                                     Global Outputs                                 \\
//====================================================================================\\

#--------------- VPC Outputs ---------------#

output "vpc_id" {
  value       = var.create.vpc ? module.vpc[0].vpc_id : null
}

output "public_subnets_ids" {
  value       = var.create.vpc ? module.vpc[0].public_subnets_ids : null
}

output "private_app_subnets_ids" {
  value       = var.create.vpc ? module.vpc[0].private_app_subnets_ids : null
}

output "private_db_subnets_ids" {
  value       = var.create.vpc ? module.vpc[0].private_db_subnets_ids : null
}

output "public_route_table_id" {
  value       = var.create.vpc ? module.vpc[0].public_route_table_id : null
}

#--------------- Existing VPC Outputs ---------------#

output "existing_vpc_id" {
  value = length(module.vpc_existing) > 0 ? module.vpc_existing[0].existing_vpc_id : null
}

output "existing_public_subnet_ids" {
  value = length(module.vpc_existing) > 0 ? module.vpc_existing[0].existing_public_subnet_ids : []
}

output "existing_private_app_subnet_ids" {
  value = length(module.vpc_existing) > 0 ? module.vpc_existing[0].existing_private_app_subnet_ids : []
}

output "existing_db_private_subnet_ids" {
  value = length(module.vpc_existing) > 0 ? module.vpc_existing[0].existing_db_private_subnet_ids : []
}


#--------------- S3 Outputs ---------------#

output "s3_bucket_arn" {
  value = var.create.s3 ? module.s3[0].s3_bucket_arn : null
}

output "s3_bucket_id" {
  value = var.create.s3 ? module.s3[0].s3_bucket_id : null
}

output "static_website_endpoint" {
  value = (var.create.s3 && var.s3_conf.static_website.enable) ? module.s3[0].static_website_endpoint : null
}

output "s3_cmk_arn" {
  value = (var.create.s3 && var.s3_conf.bucket_encryption.create_cmk) ? module.s3[0].s3_cmk_arn : null
}
