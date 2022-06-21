variable "region" {
  description = "Cloud provider region name"
  type        = string
}

variable "project_environment" {
  description = "Business name of Kidsloop environment (e.g. test)"
  type        = string
}

variable "project_region" {
  description = "Business name of Kidsloop region (e.g. uk/in/id/vn etc)"
  type        = string
}

variable "service_owner" {
  description = "Owner of deployment (which team manages?)"
  type        = string
}

variable "project" {
  description = "The Project name"
  type        = string
  default     = "kidskube"
}

variable "tags" {
  description = "Any additional tags to add to resources deployed by this stack."
  type        = map(any)
  default     = {}
}

#Variables for Subscriptions DB instance
variable "db_name" {
  description = "Database name for the User Service"
  type        = string
  default     = "subscriptions_db"
}

variable "db_service" {
  description = "The RDS service e.g cms, user"
  type        = string
  default     = "subscriptions"
}

variable "db_engine" {
  description = "RDS Database Engine type (without aurora-)"
  type        = string
  default     = "postgresql"
}

variable "db_engine_version" {
  description = "RDS Database Engine version"
  type        = string
  default     = "12.8"
}

variable "db_instance_class" {
  description = "The db instance type"
  type        = string
  default     = "db.t3.medium"
}

variable "db_port" {
  description = "User service PostgreSQL port"
  type        = string
  default     = "5432"
}

variable "preferred_backup_window" {
  description = "The default preferred backup window for the database clusters"
  type        = string
  default     = "00:00-00:30"
}

variable "preferred_maintenance_window" {
  description = "The default preferred maintenance window for the database clusters"
  type        = string
  default     = "mon:22:20-mon:22:50"
}

variable "skip_final_snapshot" {
  description = "If you want terraform to make a final snapshot of the db before deleting the cluster"
  type        = bool
  default     = true
}

variable "enhanced_monitoring_role_enabled" {
  type        = bool
  description = "A boolean flag to enable/disable the creation of the enhanced monitoring IAM role. If set to `false`, the module will not create a new role and will use `rds_monitoring_role_arn` for enhanced monitoring"
  default     = true
}

variable "backup_retention" {
  description = "Database backup retention days"
  type        = number
  default     = 5
}

variable "deletion_protection" {
  description = "The database can't be deleted when this value is set to true"
  type        = bool
  default     = true
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Object containing the cloudwatch log types to be exported"

  type = object({
    mysql      = list(string)
    postgresql = list(string)
    docdb      = list(string)
  })

  default = {
    mysql      = ["audit", "error", "general", "slowquery"]
    postgresql = ["postgresql"]
    docdb      = ["audit", "profiler"]
  }
}

variable "master_username" {
  description = "Master username for the database clusters"
  type        = string
  default     = "kidsloop"
}

variable "monitoring_interval" {
  description = "Monitoring interval (in seconds)"
  type        = number
  default     = 60
}

# Kubernetes inputs
variable "service_account_name" {
  description = "Subscriptions service account name in Kubernetes"
  type        = string
  default     = "subscriptions-sa"
}

variable "namespace" {
  description = "The kubernetes namespace for the product offering"
  type        = string
  default     = "subscriptions"
}

variable "aws_target_role_arn" {
  description = "AWS Provider details, coming from Terraform Variable set"
  type        = string
}

variable "aws_session_name" {
  description = "AWS Provider details, coming from Terraform Variable set"
  type        = string
}

variable "aws_target_external_id" {
  description = "AWS Provider details, coming from Terraform Variable set"
  type        = string
}

variable "subscriptions_firehose_s3_prefix" {
  description = "S3 prefix for data sent from firehose"
  type        = string
  default     = "datalake/events/subscriptions/raw_data/year=!{timestamp:yyyy}/mon=!{timestamp:MM}/date=!{timestamp:dd}/hour=!{timestamp:HH}/"
}

variable "subscriptions_error_output_prefix" {
  description = "S3 error prefix for data sent from firehose"
  type        = string
  default     = "datalake/events/subscriptions/errors/"
}