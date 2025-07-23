#--------------- Outputs ---------------#

output "existing_vpc_id" {
  value = length(data.aws_vpc.selected) > 0 ? data.aws_vpc.selected[0].id : null
}

output "existing_public_subnet_ids" {
  value = length(data.aws_subnets.public_subnets) > 0 ? data.aws_subnets.public_subnets[0].ids : []
}

output "existing_private_app_subnet_ids" {
  value = length(data.aws_subnets.private_app_subnets) > 0 ? data.aws_subnets.private_app_subnets[0].ids : []
}

output "existing_db_private_subnet_ids" {
  value = length(data.aws_subnets.db_subnets) > 0 ? data.aws_subnets.db_subnets[0].ids : []
}
