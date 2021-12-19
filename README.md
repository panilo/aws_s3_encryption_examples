# Encryption

## SSE-S3

In this case, the Server Side Encryption is completely managed by the AWS S3 service. The key and the actions of encrypting/decrypting are done directly in the S3 service with no interaction with KMS.

The key used Amazon S3 master-key (SSE-S3) is stored in the S3 service, not KMS.

SSE-S3 uses AES256 to encrypt bucket objects.

If you set public access to this bucket then the objects in it will be accessible by anyone, regardless of the access to the key used to encrypt the data, you basically lose a security layer.

In this case, you don’t need any KMS permission to work with bucket encryption.

## SSE-KMS

### Default key

In this scenario AWS will generate a key on our behalf to be used by S3 for encrypting/decrypting the data in the bucket.

You will need KMS permissions to read and use the default key.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "GrantKMSReadOnlyAWSDefault",
      "Effect": "Allow",
      "Action": ["kms:Decrypt", "kms:GenerateDataKey*", "kms:DescribeKey"],
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "kms:RequestAlias": "alias/aws/*"
        }
      }
    }
  ]
}
```

Regardless of the public access, you will not be able to read the object unless you have access to the KSM key.

> NB Once the bucket is encrypted with KMS you will need to pass ALWAYS an AWS Signature Header (v4)

### Customer managed key

Similar to what is described in the chapter above, the customer managed key adds the flexibility of choosing who can handle your bucket’s object by specifying permission in the bucket policy and the KMS key policy.

The IAM entity you’re using will need the following permission to work with KMS.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadWriteKMS",
      "Effect": "Allow",
      "Action": [
        "kms:ListKeys",
        "kms:Decrypt",
        "kms:ListKeyPolicies",
        "kms:GetKeyRotationStatus",
        "kms:GetKeyPolicy",
        "kms:GenerateDataKey",
        "kms:DescribeKey",
        "kms:CreateKey",
        "kms:ListResourceTags"
      ],
      "Resource": "*"
    }
  ]
}
```

Again the public access is not possible unless you have access to the key.

## SSE-C

This latter example shows how to encrypt objects by using a customer-generated key that is not stored in AWS.

You can create a bucket with no specific encryption method, your objects will be uploaded programmatically (e.g. aws cli) and the headers `x-amz-server-side​-encryption​-customer-algorithm`, `x-amz-server-side​-encryption​-customer-key` and `x-amz-server-side​-encryption​-customer-key-MD5` have to be specified during the upload/download request. Amazon S3 will use the specified key to encrypt/decrypt the object.

`aws s3 cp example.txt s3://sse-c-test-webbame/example.txt --sse-c --sse-c-key 7D139D4BB99FC6B8AAD8CA952AD4D82F`

You will always need the key to access the object.

### Key generation

You can generate a key using `openssl enc -aes-128-cbc -k secret -P`
