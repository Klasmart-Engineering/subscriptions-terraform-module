# database outputs
output "db_endpoint" {
  description = "The RDS Cluster endpoint"
  value       = module.db_cluster.rds_cluster_endpoint
}

output "db_name" {
  description = "The database name"
  value       = module.db_cluster.rds_cluster_database_name
}

output "db_master_username" {
  description = "The cluster master username"
  value       = module.db_cluster.rds_cluster_master_username
}

output "db_password" {
  description = "The randomly generated password for database"
  value       = random_password.db_password.result
  sensitive   = true
}

output "db_port" {
  description = "The database port"
  value       = module.db_cluster.rds_cluster_port
}

# IAM outputs
output "aws_iam_role_name" {
  description = "The name of the IAM role"
  value       = aws_iam_role.service_account.name
}
output "aws_iam_role_id" {
  description = "The id of the IAM role"
  value       = aws_iam_role.service_account.id
}
output "aws_iam_role_arn" {
  description = "The ARN of the IAM role"
  value       = aws_iam_role.service_account.arn
}

# KMS output
output "kms_arn" {
  value       = module.kms.kms_key_arn
  description = "The ARN of the KMS key to use to encrypt the Postgres database"
}
