resource "aws_s3_bucket" "firehose" {
  bucket = "${local.name_prefix}-subscriptions-firehose"
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-firehose"
      RESOURCE_GROUP = "Storage"
    }
  )
}

resource "aws_s3_bucket_acl" "firehose" {
  bucket = aws_s3_bucket.firehose.id
  acl    = "private"
}

resource "aws_kms_key" "firehose" {
  description             = "This key is used to encrypt subscriptions firehose bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "firehose" {
  bucket = aws_s3_bucket.firehose.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.firehose.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "firehose" {
  bucket                  = aws_s3_bucket.firehose.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_logging" "firehose" {
  bucket        = aws_s3_bucket.firehose.id
  target_bucket = local.logs_bucket_id
  target_prefix = "S3/${aws_s3_bucket.firehose.id}"
}
