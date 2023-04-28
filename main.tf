# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket

#tfsec:ignore:aws-s3-enable-bucket-logging Citadel uses CloudTrail S3 data events logging
resource "aws_s3_bucket" "this" {
  bucket              = var.bucket_name
  bucket_prefix       = var.bucket_name_prefix
  object_lock_enabled = var.object_lock.enabled

  tags = var.tags

  lifecycle {
    precondition {
      condition     = var.bucket_name != null || var.bucket_name_prefix != null
      error_message = "Either bucket_name or bucket_name_prefix must be set."
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  dynamic "rule" {
    for_each = var.abort_incomplete_multipart_upload != null ? [var.abort_incomplete_multipart_upload] : []
    content {
      id     = "abort-multipart-upload"
      status = "Enabled"

      abort_incomplete_multipart_upload {
        days_after_initiation = rule.value.days_after_initiation
      }
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.custom_kms_key_arn != null ? var.custom_kms_key_arn : "alias/aws/s3"
      sse_algorithm     = "aws:kms"
    }
    bucket_key_enabled = true
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning
resource "aws_s3_bucket_versioning" "this" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = "Enabled"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_ownership_controls
resource "aws_s3_bucket_ownership_controls" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = var.public_access_block.block_public_acls
  block_public_policy     = var.public_access_block.block_public_policy
  ignore_public_acls      = var.public_access_block.ignore_public_acls
  restrict_public_buckets = var.public_access_block.restrict_public_buckets
}


resource "aws_s3_bucket_object_lock_configuration" "this" {
  count  = (var.object_lock.enabled && var.object_lock.default_retention != null) ? 1 : 0
  bucket = aws_s3_bucket.this.id

  rule {
    default_retention {
      mode  = var.object_lock.default_retention.mode
      days  = var.object_lock.default_retention.days
      years = var.object_lock.default_retention.years
    }
  }
}
