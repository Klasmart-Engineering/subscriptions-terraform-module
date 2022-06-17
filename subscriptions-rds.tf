###################################################
## Generate random passwords for db master username
###################################################
resource "random_password" "db_password" {
  length  = 16
  special = false
}

module "db_cluster" {
  # Module source
  source  = "app.terraform.io/kidsloop-infrastructure/rds-cluster/aws"
  version = "1.0.2"

  # Module inputs
  cluster_identifier              = "${local.name_prefix}-cluster"
  db_subnet_group_name            = local.database_subnet_group
  engine                          = "aurora-${var.db_engine}"
  engine_version                  = var.db_engine_version
  database_name                   = var.db_name
  master_username                 = var.master_username
  db_service                      = var.db_service
  port                            = var.db_port
  backup_retention                = var.backup_retention
  deletion_protection             = var.deletion_protection
  master_password                 = random_password.db_password.result
  vpc_security_group_ids          = [aws_security_group.postgresql_security_group.id]
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports.postgresql
  kms_key_arn                     = local.kms_key_arn
  skip_final_snapshot             = var.skip_final_snapshot

  # RDS Instance
  instance_class                   = var.db_instance_class
  enhanced_monitoring_role_enabled = var.enhanced_monitoring_role_enabled
  monitoring_interval              = var.monitoring_interval

  tags = merge(
    local.tags,
    {
      RESOURCE_GROUP = "Storage"
    }
  )
}

resource "aws_security_group" "postgresql_security_group" {

  #checkov:skip=CKV2_AWS_5:False positive, attached to database through module above

  name        = "${local.name_prefix}-postgresql-sg1"
  description = "Security group for database"
  vpc_id      = local.vpc_id

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-db-sg"
      RESOURCE_GROUP = "Networking"
    }
  )
}

resource "aws_security_group_rule" "postgresql_ingress" {

  security_group_id = aws_security_group.postgresql_security_group.id

  description      = "Allow ingress to DB from private EKS nodes"
  type             = "ingress"
  from_port        = var.db_port
  to_port          = var.db_port
  protocol         = "tcp"
  cidr_blocks      = local.private_ip_range
  ipv6_cidr_blocks = []
  prefix_list_ids  = []
}