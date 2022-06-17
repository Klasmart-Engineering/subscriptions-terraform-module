provider "aws" {
  region = var.region
  assume_role {
    role_arn     = var.aws_target_role_arn
    session_name = var.aws_session_name
    external_id  = var.aws_target_external_id
  }
}

# Kubernetes layer
provider "kubernetes" {
  host                   = local.cluster_endpoint
  cluster_ca_certificate = base64decode(local.kubeconfig_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}