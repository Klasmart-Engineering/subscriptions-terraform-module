resource "aws_iam_policy" "subscriptions_k8s_firehose_stream_policy" {

  name = "${local.name_prefix}-subscriptions-k8s-firehose-stream-policy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "firehose:PutRecord",
            "firehose:PutRecordBatch",
          ],
          "Resource" : [
            aws_kinesis_firehose_delivery_stream.stream.arn
          ]
        }
      ]
    }
  )

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-k8s-firehose-stream-policy"
      RESOURCE_GROUP = "IAM"
    }
  )
}

resource "aws_iam_role" "service_account" {

  name = "${local.name_prefix}-sa"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : local.dep_cluster.eks_oidc_provider_arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            "${local.dep_cluster.eks_oidc_provider_id}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account_name}"
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

resource "aws_iam_role" "microgateway_service_account" {

  name = "${local.name_prefix}-microgateway-sa"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Effect : "Allow",
        Principal : {
          "Federated" : local.dep_cluster.eks_oidc_provider_arn
        },
        Action : "sts:AssumeRoleWithWebIdentity",
        Condition : {
          "StringEquals" : {
            "${local.dep_cluster.eks_oidc_provider_id}:sub" : "system:serviceaccount:${var.namespace}:${var.service_account_microgateway_name}"
          }
        }
      }
    ]
  })

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-microgateway-sa"
      RESOURCE_GROUP = "IAM"
    }
  )
}

resource "aws_iam_role_policy_attachment" "subscriptions_athena_queries" {
  role       = aws_iam_role.service_account.name
  policy_arn = aws_iam_policy.subscriptions_athena_queries_policy.arn
}

resource "aws_iam_role_policy_attachment" "subscriptions_firehose_output" {
  role       = aws_iam_role.service_account.name
  policy_arn = aws_iam_policy.firehose-s3-output.arn
}

resource "aws_iam_role_policy_attachment" "subscriptions_k8s_firehose_stream" {
  role       = aws_iam_role.microgateway_service_account.name
  policy_arn = aws_iam_policy.subscriptions_k8s_firehose_stream_policy.arn
}