# Creating a bucket encrypted by SSE-S3
resource "aws_s3_bucket" "sse-s3-test" {
  bucket = "sse-s3-test-webbame"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

# Giving public access to the bucket
resource "aws_s3_bucket_policy" "sse-s3-test-policy" {
  bucket = aws_s3_bucket.sse-s3-test.id
  policy = templatefile("./bucket-public-access-policy.json", { bucket_arn = aws_s3_bucket.sse-s3-test.arn })
}

# Disable the ACL on the bucket
resource "aws_s3_bucket_ownership_controls" "sse-s3-ownership-controls" {
  bucket = aws_s3_bucket.sse-s3-test.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Upload an example object
resource "aws_s3_bucket_object" "sse-s3-example-obj" {
  bucket                 = aws_s3_bucket.sse-s3-test.bucket
  key                    = "example.txt"
  source                 = "./example.txt"
  server_side_encryption = "AES256" # SSE-S3 uses AES256 to encrypt objects
  content_type           = "text/plain"
  etag                   = filemd5("./example.txt")
}
