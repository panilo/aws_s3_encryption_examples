# Creating a bucket
resource "aws_s3_bucket" "sse-c-test" {
  bucket = "sse-c-test-webbame"
}

# Giving public access to the bucket
resource "aws_s3_bucket_policy" "sse-c-test-policy" {
  bucket = aws_s3_bucket.sse-c-test.id
  policy = templatefile("./bucket-public-access-policy.json", { bucket_arn = aws_s3_bucket.sse-c-test.arn })
}

# Disable the ACL on the bucket
resource "aws_s3_bucket_ownership_controls" "sse-c-ownership-controls" {
  bucket = aws_s3_bucket.sse-c-test.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# Upload an example object with the CLI specifying the SSE-C key to be used
resource "null_resource" "aws-cli-s3-cp" {
  provisioner "local-exec" {
    command     = "aws s3 cp example.txt s3://sse-c-test-webbame/example.txt --sse-c --sse-c-key 7D139D4BB99FC6B8AAD8CA952AD4D82F"
  }
}
