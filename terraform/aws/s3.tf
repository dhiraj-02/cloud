resource "aws_s3_bucket" "content" {
  bucket = var.content_bucket_name
  force_destroy = true
}
