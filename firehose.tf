resource "aws_cloudwatch_log_group" "api_usage_log_group" {
  name = "${local.name_prefix}-api-usage-firehose-stream"
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-api-usage-firehose-stream"
      RESOURCE_GROUP = "Monitoring"
    }
  )
}

resource "aws_cloudwatch_log_stream" "api_usage_log_group_stream" {
  name           = "ERROR_LOG"
  log_group_name = aws_cloudwatch_log_group.api_usage_log_group.name
}


# Common/core infrastructure
# Firehose
# Buckets for it
# Database, if it's shared across services per environment
resource "aws_kinesis_firehose_delivery_stream" "stream" {
  name        = "${local.name_prefix}-api-usage"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.firehose.arn

    # Example prefix using partitionKeyFromQuery, applicable to JQ processor
    prefix              = var.api_usage_firehose_s3_prefix
    error_output_prefix = var.api_usage_error_output_prefix

    # https://docs.aws.amazon.com/firehose/latest/dev/dynamic-partitioning.html
    buffer_size        = 64
    buffer_interval    = 600
    compression_format = "GZIP"
    # kms_key_arn        = aws_kms_key.firehose.arn
    dynamic_partitioning_configuration {
      enabled = true
    }
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "${local.name_prefix}-api-usage-firehose-stream"
      log_stream_name = "ERROR_LOG"
    }
    processing_configuration {
      enabled = "true"

      # Multi-record deaggregation processor example
      processors {
        type = "RecordDeAggregation"
        parameters {
          parameter_name  = "SubRecordType"
          parameter_value = "JSON"
        }
      }
      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{SubscriptionId:.subscription_id}"
        }
      }
    }
  }
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-api-usage"
      RESOURCE_GROUP = "Data"
    }
  )
}

resource "aws_iam_policy" "s3_firehose_policy" {
  name = "${local.name_prefix}-api-usage-s3-firehose"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject"
        ],
        "Resource" : [
          "${aws_s3_bucket.firehose.arn}",
          "${aws_s3_bucket.firehose.arn}/*"
        ]
      }
    ]
  })
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-api-usage-s3-firehose"
      RESOURCE_GROUP = "IAM"
    }
  )
}

# resource "aws_iam_policy" "firehose_kms_policy" {

#   name = "${local.name_prefix}-api-usage-kms-access"

#   policy = jsonencode({
#     "Version" : "2012-10-17",
#     "Statement" : [
#       {
#         "Effect" : "Allow",
#         "Action" : [
#           "kms:Decrypt",
#           "kms:GenerateDataKey"
#         ],
#         "Resource" : aws_kms_key.firehose.arn,
#         "Condition" : {
#           "StringEquals" : {
#             "kms:ViaService" : "s3.${var.region}.amazonaws.com"
#           },
#           "StringLike" : {
#             "kms:EncryptionContext:aws:s3:arn" : "${aws_s3_bucket.firehose.arn}/*"
#           }
#         }
#       }
#     ]
#   })

#   tags = merge(
#     local.tags,
#     {
#       Name           = "${local.name_prefix}-api-usage-kms-access"
#       RESOURCE_GROUP = "IAM"
#     }
#   )
# }

resource "aws_iam_policy" "firehose_cloudwatch_policy" {

  name = "${local.name_prefix}-api-usage-cloudwatch-access"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "Logs:PutLogEvents",
        ],
        "Resource" : "arn:aws:logs::log-group:${local.name_prefix}-api-usage-firehose-stream:*"
      }
    ]
  })

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-api-usage-cloudwatch-access"
      RESOURCE_GROUP = "IAM"
    }
  )
}

resource "aws_iam_role" "firehose" {
  name = "${local.name_prefix}-api-usage-s3-firehose"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "firehose.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-api-usage-s3-firehose"
      RESOURCE_GROUP = "IAM"
    }
  )
}

resource "aws_iam_role_policy_attachment" "s3_firehose" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.s3_firehose_policy.arn
}
# resource "aws_iam_role_policy_attachment" "firehose_kms" {
#   role       = aws_iam_role.firehose.name
#   policy_arn = aws_iam_policy.firehose_kms_policy.arn
# }
resource "aws_iam_role_policy_attachment" "firehose_cloudwatch" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.firehose_cloudwatch_policy.arn
}

# TODO(Add VPC Link to Firehose)
# TODO(Separate core infrastructure to separate module/service)

resource "aws_iam_policy" "firehose-s3-output" {
  name = "${local.name_prefix}-firehose-s3-output"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject",
        ],
        "Resource" : [
          "${aws_s3_bucket.firehose.arn}",
          "${aws_s3_bucket.firehose.arn}/*"
        ]
      }
    ]
  })
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-firehose-s3-output"
      RESOURCE_GROUP = "IAM"
    }
  )
}