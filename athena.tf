data "aws_caller_identity" "current" {}

resource "aws_athena_workgroup" "athena" {
  name = "${local.name_prefix}-subscriptions-athena"
  #   configuration {
  #     result_configuration {
  #       encryption_configuration {
  #         encryption_option = "SSE_KMS"
  #         kms_key_arn       = aws_kms_key.athena.arn
  #       }
  #     }
  #   }
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-athena"
      RESOURCE_GROUP = "Data"
    }
  )
}

resource "aws_athena_database" "athena" {
  name   = "subscriptions_api_usage"
  bucket = aws_s3_bucket.athena.id
}

resource "aws_athena_named_query" "foo" {
  name      = "bar"
  workgroup = aws_athena_workgroup.athena.id
  database  = aws_athena_database.athena.name
  query     = "SELECT * FROM ${aws_athena_database.athena.name} limit 10;"
}


resource "aws_iam_policy" "subscriptions_athena_queries_policy" {

  name = "${local.name_prefix}-subscriptions-athena-queries-policy"

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "athena:GetQueryExecution",
            "athena:StartQueryExecution",
          ],
          "Resource" : [
            aws_athena_workgroup.athena.arn
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "s3:GetObject",
            "s3:PutObject",
            "s3:ListBucketMultipartUploads",
            "s3:ListMultipartUploadParts",
            "s3:AbortMultipartUpload",
            "s3:GetBucketLocation",
          ],
          "Resource" : [
            aws_s3_bucket.athena.arn,
            "${aws_s3_bucket.athena.arn}/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "glue:GetDatabase",
            "glue:CreateTable",
            "glue:GetTable",
            "glue:GetTables",
            "glue:CreatePartition",
            "glue:UpdatePartition",
            "glue:GetPartition",
            "glue:GetPartitions",
            "glue:BatchGetPartition",
          ],
          "Resource" : [
            "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/${aws_athena_database.athena.id}",
            "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/default",
          ]
        },
      ]
    }
  )

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-athena-queries-policy"
      RESOURCE_GROUP = "IAM"
    }
  )
}
