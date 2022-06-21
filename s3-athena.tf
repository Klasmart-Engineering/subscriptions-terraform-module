resource "aws_s3_bucket" "athena" {
  bucket = "${local.name_prefix}-subscriptions-athena"
  tags = merge(
    local.tags,
    {
      Name           = "${local.name_prefix}-subscriptions-athena"
      RESOURCE_GROUP = "Storage"
    }
  )
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.athena.id
  acl    = "private"
}

resource "aws_kms_key" "athena" {
  description             = "This key is used to encrypt subscriptions Athena bucket objects"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket_server_side_encryption_configuration" "athena" {
  bucket = aws_s3_bucket.athena.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.athena.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "athena" {
  bucket                  = aws_s3_bucket.athena.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_logging" "athena" {
  bucket        = aws_s3_bucket.athena.id
  target_bucket = local.logs_bucket_id
  target_prefix = "S3/${local.name_prefix}-bucket"
}
