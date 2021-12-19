# Encryption with SSE-KMS using a customer defined KMS key

# Creating a new KMS key
resource "aws_kms_key" "my-bucket-key" {
  description             = "My Bucket Key"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 10
}

resource "aws_s3_bucket" "sse-kms-customer-test" {
  bucket = "sse-kms-customer-test-webbame"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = aws_kms_key.my-bucket-key.id
      }
    }
  }
}

# Giving public access to the bucket
resource "aws_s3_bucket_policy" "sse-kms-customer-test-policy" {
  bucket = aws_s3_bucket.sse-kms-customer-test.bucket
  policy = templatefile("./bucket-public-access-policy.json", { bucket_arn = aws_s3_bucket.sse-kms-customer-test.arn })
}

# Disable the ACL on the bucket
resource "aws_s3_bucket_ownership_controls" "sse-kms-customer-ownership-controls" {
  bucket = aws_s3_bucket.sse-kms-customer-test.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Upload an example object
resource "aws_s3_bucket_object" "sse-kms-customer-example-obj" {
  bucket = aws_s3_bucket.sse-kms-customer-test.bucket
  key    = "example.txt"
  source = "./example2.txt"
  # No need to specify the SSE meta argument, TF will pick the encryption method defined at bucket level
  # If you wish to specify the meta argument you need to specify kms_key_id
  content_type = "text/plain"
}
