resource "time_static" "timestamp" {}

data "aws_eks_cluster_auth" "cluster" {
  provider = aws
  name     = local.cluster_id
}