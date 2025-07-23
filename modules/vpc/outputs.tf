#--------------- Outputs ---------------#

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnets_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_app_subnets_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "private_db_subnets_ids" {
  value = aws_subnet.private_db_subnets[*].id
}

output "public_route_table_id" {
  value = aws_route_table.public_rtb.id
}
