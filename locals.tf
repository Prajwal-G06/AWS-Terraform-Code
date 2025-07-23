//====================================================================================\\
//                                    Local Variables                                 \\
//====================================================================================\\

locals {
  vpc_id = var.create.vpc == true ? module.vpc[0].vpc_id : null
  vpc_id_existing = length(module.vpc_existing) > 0 ? module.vpc_existing[0].existing_vpc_id : null

  public_subnets = var.create.vpc == true ? module.vpc[0].public_subnets_ids : []
  public_subnets_existing = length(module.vpc_existing) > 0 ? module.vpc_existing[0].existing_public_subnet_ids : []

  private_app_subnets = var.create.vpc == true ? module.vpc[0].private_app_subnets_ids : []
  private_app_subnets_existing = length(module.vpc_existing) > 0 ? module.vpc_existing[0].existing_private_app_subnet_ids : []

  private_db_subnets = var.create.vpc == true ? module.vpc[0].private_db_subnets_ids : []
  private_db_subnets_existing = length(module.vpc_existing) > 0 ? module.vpc_existing[0].existing_db_private_subnet_ids : []
}
