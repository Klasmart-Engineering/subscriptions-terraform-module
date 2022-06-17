# User service database password secret
resource "kubernetes_secret" "outputs" {
  metadata {
    name      = "tf-outputs"
    namespace = var.namespace
  }

  data = {
    username = var.master_username
    password = random_password.db_password.result
    hostname = module.db_cluster.rds_cluster_endpoint
    db_port  = module.db_cluster.rds_cluster_port
    db_name  = module.db_cluster.rds_cluster_database_name
    aws_iam_role_name = aws_iam_role.service_account.name
    aws_iam_role_id = aws_iam_role.service_account.id
    aws_iam_role_arn = aws_iam_role.service_account.arn
    kms_arn = module.kms.kms_key_arn
  }
}
