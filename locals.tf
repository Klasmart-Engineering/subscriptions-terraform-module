locals {
  # TFC inputs
  terraform_organization = "kidsloop-infrastructure"

  # Imported dependencies (mark as non-sensitive)
  dep_meta    = nonsensitive(data.tfe_outputs.meta.values)
  dep_account = nonsensitive(data.tfe_outputs.account.values)
  dep_network = nonsensitive(data.tfe_outputs.network.values)
  dep_cluster = nonsensitive(data.tfe_outputs.cluster.values)

  region              = var.region
  project_environment = var.project_environment
  project_region      = var.project_region
  service_owner       = var.service_owner

  tags = merge(
    var.tags,
    {
      OWNER_GROUP     = var.service_owner
      OWNER_SUB_GROUP = var.service_owner
      ENVIRONMENT     = var.project_environment
      SERVICE_GROUP   = "Subscriptions"
    }
  )

  # Passthrough
  vpc_id                = local.dep_network.vpc_id
  database_subnet_group = local.dep_network.database_subnet_group
  private_ip_range      = local.dep_network.private_ip_range
  kms_key_arn           = module.kms.kms_key_arn
  name_prefix           = "${var.project}-${var.project_region}-${var.project_environment}"

  master_username = module.db_cluster.rds_cluster_master_username
  db_password     = random_password.db_password.result
  db_endpoint     = module.db_cluster.rds_cluster_endpoint
  db_port         = module.db_cluster.rds_cluster_port
  db_name         = module.db_cluster.rds_cluster_database_name

  # Global EKS Variables
  cluster_endpoint                      = local.dep_cluster.cluster_endpoint
  cluster_id                            = local.dep_cluster.cluster_id
  kubeconfig_certificate_authority_data = local.dep_cluster.kubeconfig_certificate_authority_data

  # logging
  logs_bucket_id = local.dep_account.logs_bucket_id
}
