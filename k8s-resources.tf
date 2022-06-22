# User service database password secret
resource "kubernetes_secret" "outputs" {
  metadata {
    name      = "tf-outputs"
    namespace = var.namespace
  }

  data = {
    username          = var.master_username
    password          = random_password.db_password.result
    hostname          = module.db_cluster.rds_cluster_endpoint
    db_port           = module.db_cluster.rds_cluster_port
    db_name           = module.db_cluster.rds_cluster_database_name
    aws_iam_role_name = aws_iam_role.service_account.name
    aws_iam_role_id   = aws_iam_role.service_account.id
    aws_iam_role_arn  = aws_iam_role.service_account.arn
    kms_arn           = module.kms.kms_key_arn
  }
}

resource "kubernetes_manifest" "db-istio-egress-service-entry" {
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "ServiceEntry"
    "metadata" = {
      "name"      = "subscriptions-db"
      "namespace" = "istio-system"
    }
    "spec" = {
      "hosts" = [
        module.db_cluster.rds_cluster_endpoint,
      ]
      "location" = "MESH_EXTERNAL"
      "ports" = [
        {
          "name"     = "postgresql",
          "number"   = 5432
          "protocol" = "TCP"
        }
      ]
      "resolution" = "DNS"
    }
  }
}

resource "kubernetes_manifest" "firehose-istio-egress-service-entry" {
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "ServiceEntry"
    "metadata" = {
      "name"      = "api-usage-firehose"
      "namespace" = "istio-system"
    }
    "spec" = {
      "hosts" = [
        "firehose.${var.region}.amazonaws.com",
      ]
      "location" = "MESH_EXTERNAL"
      "ports" = [
        {
          "name"     = "https",
          "number"   = 443
          "protocol" = "TLS"
        }
      ]
      "resolution" = "DNS"
    }
  }
}

resource "kubernetes_manifest" "athena-istio-egress-service-entry" {
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "ServiceEntry"
    "metadata" = {
      "name"      = "subscriptions-athena"
      "namespace" = "istio-system"
    }
    "spec" = {
      "hosts" = [
        "athena.${var.region}.amazonaws.com",
      ]
      "location" = "MESH_EXTERNAL"
      "ports" = [
        {
          "name"     = "https",
          "number"   = 443
          "protocol" = "TLS"
        }
      ]
      "resolution" = "DNS"
    }
  }
}

resource "kubernetes_manifest" "kidsloop_net-egress-service-entry" {
  manifest = {
    "apiVersion" = "networking.istio.io/v1beta1"
    "kind"       = "ServiceEntry"
    "metadata" = {
      "name"      = "subscriptions-athena"
      "namespace" = "istio-system"
    }
    "spec" = {
      "hosts" = [
        "kidsloop.net",
      ]
      "location" = "MESH_EXTERNAL"
      "ports" = [
        {
          "name"     = "https",
          "number"   = 443
          "protocol" = "TLS"
        }
      ]
      "resolution" = "DNS"
    }
  }
}
