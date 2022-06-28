# User service database password secret
resource "kubernetes_secret" "outputs" {
  metadata {
    name      = "tf-outputs"
    namespace = var.namespace
  }

  data = {
    username                      = var.master_username
    password                      = random_password.db_password.result
    hostname                      = module.db_cluster.rds_cluster_endpoint
    db_port                       = module.db_cluster.rds_cluster_port
    db_name                       = module.db_cluster.rds_cluster_database_name
    application_aws_iam_role_arn  = aws_iam_role.microgateway_service_account.arn
    microgateway_aws_iam_role_arn = aws_iam_role.service_account.arn
    athena_workgroup              = aws_athena_workgroup.athena.id
    athena_database               = aws_athena_database.athena.id
    db_master_usename             = data.kubernetes_secret.core-db-secret.data.username
    db_master_password            = data.kubernetes_secret.core-db-secret.data.password
    db_master_name                = data.kubernetes_secret.core-db-secret.data.db_name
    db_username                   = var.db_usename
    db_password                   = random_password.db_password.result
    db_hostname                   = data.kubernetes_secret.core-db-secret.data.hostname
    db_logical_name               = var.db_usename
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
      "name"      = "kidsloop-net"
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

resource "kubernetes_annotations" "application-service-account" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.service_account.arn
  }
}

resource "kubernetes_annotations" "microgateway-firehose-sa" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name      = var.service_account_microgateway_name
    namespace = var.namespace
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = aws_iam_role.microgateway_service_account.arn
  }
}

data "kubernetes_secret" "core-db-secret" {
  metadata {
    name      = "tf-outputs"
    namespace = "products-core"
  }
}