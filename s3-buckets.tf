data "aws_s3_bucket" "name" {
  bucket = "kidskube-uk-apifactory-logs"
}

output "bucket_region" {
  description = "The region of a bucket"
  value       = data.aws_s3_bucket.name.region
}