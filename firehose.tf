resource "aws_cloudwatch_log_group" "subscriptions_log_group" {
  name = "${local.name_prefix}-subscriptions-delivery-stream"
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-firehose-stream"
      RESOURCE_GROUP = "Monitoring"
    }
  )
}


resource "aws_cloudwatch_log_stream" "subscriptions_log_group_stream" {
  name           = "ERROR_LOG"
  log_group_name = aws_cloudwatch_log_group.subscriptions_log_group.name
}


resource "aws_kinesis_firehose_delivery_stream" "subscriptions_stream" {
  name        = "${local.name_prefix}-subscriptions-firehose-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose.arn
    bucket_arn = aws_s3_bucket.firehose.arn

    # Example prefix using partitionKeyFromQuery, applicable to JQ processor
    prefix              = var.subscriptions_firehose_s3_prefix
    error_output_prefix = var.subscriptions_error_output_prefix

    # https://docs.aws.amazon.com/firehose/latest/dev/dynamic-partitioning.html
    buffer_size        = 64
    compression_format = "GZIP"
    kms_key_arn        = aws_kms_key.firehose.arn
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = "${local.name_prefix}-subscriptions-delivery-stream"
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

      # New line delimiter processor example
      processors {
        type = "AppendDelimiterToRecord"
      }

      # JQ processor example
      processors {
        type = "MetadataExtraction"
        parameters {
          parameter_name  = "JsonParsingEngine"
          parameter_value = "JQ-1.6"
        }
        parameters {
          parameter_name  = "MetadataExtractionQuery"
          parameter_value = "{customer_id:.customer_id}"
        }
      }
    }
  }
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-firehose-stream"
      RESOURCE_GROUP = "EventStream"
    }
  )
}

resource "aws_iam_policy" "subscriptions_s3_firehose_policy" {
  name = "${local.name_prefix}-subscriptions-s3-firehose"
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
      Name           = "${local.name_prefix}-subscriptions-s3-firehose"
      RESOURCE_GROUP = "IAM"
    }
  )
}

resource "aws_iam_policy" "subscritpions_firehose_kms_policy" {

  name = "${local.name_prefix}-subscritpions-kms-access"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ],
        "Resource" : aws_kms_key.firehose.arn,
        "Condition" : {
          "StringEquals" : {
            "kms:ViaService" : "s3.${var.region}.amazonaws.com"
          },
          "StringLike" : {
            "kms:EncryptionContext:aws:s3:arn" : "${aws_s3_bucket.firehose.arn}/*"
          }
        }
      }
    ]
  })

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-firehose-kms-access"
      RESOURCE_GROUP = "IAM"
    }
  )
}

resource "aws_iam_policy" "subscriptions_firehose_cloudwatch_policy" {

  name = "${local.name_prefix}-subscriptions-cloudwatch-access"

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "Logs:PutLogEvents",
        ],
        "Resource" : "arn:aws:logs::log-group:${local.name_prefix}-subscriptions-delivery-stream:*"
      }
    ]
  })

  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-cloudwatch-access"
      RESOURCE_GROUP = "IAM"
    }
  )
}

resource "aws_iam_role" "firehose" {
  name = "${local.name_prefix}-subscriptions-s3-firehose"

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
      Name           = "${local.name_prefix}-subscriptions-s3-firehose"
      RESOURCE_GROUP = "IAM"
    }
  )
}

resource "aws_iam_role_policy_attachment" "subscriptions_s3_firehose" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.subscriptions_s3_firehose_policy.arn
}
resource "aws_iam_role_policy_attachment" "subscriptions_firehose_kms" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.subscritpions_firehose_kms_policy.arn
}
resource "aws_iam_role_policy_attachment" "subscriptions_firehose_cloudwatch" {
  role       = aws_iam_role.firehose.name
  policy_arn = aws_iam_policy.subscriptions_firehose_cloudwatch_policy.arn
}
