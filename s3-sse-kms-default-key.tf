# Encryption with SSE-KMS using the default aws/s3 key
resource "aws_s3_bucket" "sse-kms-default-test" {
  bucket = "sse-kms-default-test-webbame"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
        # kms_master_key_id is not defined so AWS will automatically generate a key on our behalf
      }
    }
  }
}

# Giving public access to the bucket
resource "aws_s3_bucket_policy" "sse-kms-default-test-policy" {
  bucket = aws_s3_bucket.sse-kms-default-test.bucket
  policy = templatefile("./bucket-public-access-policy.json", { bucket_arn = aws_s3_bucket.sse-kms-default-test.arn })
}

# Disable the ACL on the bucket
resource "aws_s3_bucket_ownership_controls" "sse-kms-default-ownership-controls" {
  bucket = aws_s3_bucket.sse-kms-default-test.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Upload an example object
resource "aws_s3_bucket_object" "sse-kms-default-example-obj" {
  bucket                 = aws_s3_bucket.sse-kms-default-test.bucket
  key                    = "example.txt"
  source                 = "./example.txt"
  server_side_encryption = "aws:kms" # Using the default S3's KMS key generated on our behalf by AWS
  content_type           = "text/plain"
  etag                   = filemd5("./example.txt")
}
