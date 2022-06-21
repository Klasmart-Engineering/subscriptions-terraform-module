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
            "athena:ListEngineVersions",
            "athena:ListWorkGroups",
            "athena:ListDataCatalogs",
            "athena:ListDatabases",
            "athena:GetDatabase",
            "athena:ListTableMetadata",
            "athena:GetTableMetadata"
          ],
          "Resource" : "*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "athena:GetWorkGroup",
            "athena:BatchGetQueryExecution",
            "athena:GetQueryExecution",
            "athena:ListQueryExecutions",
            "athena:StartQueryExecution",
            "athena:StopQueryExecution",
            "athena:GetQueryResults",
            "athena:GetQueryResultsStream",
            "athena:CreateNamedQuery",
            "athena:GetNamedQuery",
            "athena:BatchGetNamedQuery",
            "athena:ListNamedQueries",
            "athena:DeleteNamedQuery",
            "athena:CreatePreparedStatement",
            "athena:GetPreparedStatement",
            "athena:ListPreparedStatements",
            "athena:UpdatePreparedStatement",
            "athena:DeletePreparedStatement"
          ],
          "Resource" : [
            aws_athena_workgroup.athena.arn
          ]
        }
    ] }
  )

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-athena-queries-policy"
      RESOURCE_GROUP = "IAM"
    }
  )
}
