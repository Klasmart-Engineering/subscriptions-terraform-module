resource "aws_iam_role" "service_account" {

  name = "${local.name_prefix}-sa"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : var.eks_oidc_provider_arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            "${var.eks_oidc_provider_id}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account_name}"
          }
        }
      }
    ]
  })

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-sa"
      RESOURCE_GROUP = "IAM"
    }
  )
}
