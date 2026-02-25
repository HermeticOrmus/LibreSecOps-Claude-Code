# AWS S3 Security

> S3 bucket security configurations, access control models, encryption patterns, and data exposure prevention.

## Knowledge Base

### S3 Access Control Layers

S3 has multiple overlapping access control mechanisms. Understanding the hierarchy prevents misconfigurations:

1. **Block Public Access (Account level)** -- Master switch. If enabled at account level, overrides all bucket-level settings. This is your first line of defense.
2. **Block Public Access (Bucket level)** -- Per-bucket controls. Four independent settings:
   - `BlockPublicAcls` -- Rejects PUT requests with public ACLs
   - `IgnorePublicAcls` -- Ignores existing public ACLs
   - `BlockPublicPolicy` -- Rejects bucket policies that grant public access
   - `RestrictPublicBuckets` -- Restricts access to bucket with public policies to AWS principals only
3. **Bucket Policy** -- JSON policies attached to the bucket. Most flexible control.
4. **ACLs (Legacy)** -- Predates bucket policies. AWS recommends disabling ACLs entirely (S3 Object Ownership set to "Bucket owner enforced").
5. **IAM Policies** -- Control what IAM principals can do with S3.
6. **Access Points** -- Named network endpoints with their own access policies, scoped to specific prefixes.
7. **VPC Endpoint Policies** -- Control which buckets can be accessed from a VPC endpoint.

### S3 Encryption Models

| Type | Key | Description | Use Case |
|------|-----|-------------|----------|
| SSE-S3 | AWS managed, auto-rotated | S3 manages everything | Default encryption, no key management overhead |
| SSE-KMS | Customer managed or AWS managed KMS key | Separate key management, audit trail via CloudTrail | When you need key rotation control, access auditing, or cross-account key sharing |
| SSE-C | Customer provided per request | Customer sends key with each request | Regulatory requirement to hold keys outside AWS |
| Client-side | Customer managed entirely | Encrypt before upload | Zero-trust of AWS, end-to-end encryption |

**Default recommendation**: SSE-KMS with a customer-managed key. It provides the best balance of security, auditability, and operational simplicity.

## Patterns

### Pattern 1: Secure Bucket Baseline (Terraform)

```hcl
resource "aws_s3_bucket" "secure" {
  bucket = "my-secure-bucket"
}

resource "aws_s3_bucket_public_access_block" "secure" {
  bucket = aws_s3_bucket.secure.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_ownership_controls" "secure" {
  bucket = aws_s3_bucket.secure.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_versioning" "secure" {
  bucket = aws_s3_bucket.secure.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "secure" {
  bucket = aws_s3_bucket.secure.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3.arn
    }
    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_logging" "secure" {
  bucket = aws_s3_bucket.secure.id

  target_bucket = aws_s3_bucket.logs.id
  target_prefix = "s3-access-logs/my-secure-bucket/"
}

resource "aws_s3_bucket_lifecycle_configuration" "secure" {
  bucket = aws_s3_bucket.secure.id

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
```

**Why this works**: Every security control is explicit. Public access is blocked at bucket level, ACLs are disabled, versioning protects against deletion, KMS encryption provides auditability, access logging captures all requests, and lifecycle rules manage version accumulation.

### Pattern 2: Bucket Policy Requiring TLS and Limiting Access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyNonTLS",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-secure-bucket",
        "arn:aws:s3:::my-secure-bucket/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      }
    },
    {
      "Sid": "RestrictToOrganization",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:*",
      "Resource": [
        "arn:aws:s3:::my-secure-bucket",
        "arn:aws:s3:::my-secure-bucket/*"
      ],
      "Condition": {
        "StringNotEquals": {
          "aws:PrincipalOrgID": "o-abc123def4"
        }
      }
    },
    {
      "Sid": "DenyUnencryptedUploads",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::my-secure-bucket/*",
      "Condition": {
        "StringNotEquals": {
          "s3:x-amz-server-side-encryption": "aws:kms"
        }
      }
    }
  ]
}
```

**Why this works**: Three deny statements that cannot be overridden: all traffic must use TLS, all access must come from within the organization, and all uploads must use KMS encryption.

### Pattern 3: S3 Access Point for Scoped Access

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowAnalyticsTeamReadOnly",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/analytics-team"
      },
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:us-east-1:123456789012:accesspoint/analytics-readonly",
        "arn:aws:s3:us-east-1:123456789012:accesspoint/analytics-readonly/object/data/processed/*"
      ]
    }
  ]
}
```

**Why this works**: Access Points let you create named entry points with their own policies, restricted to specific prefixes. Instead of one complex bucket policy serving many use cases, each consumer gets their own scoped access point.

## Anti-Patterns

### Anti-Pattern 1: Public Bucket for "Convenience"

Making a bucket public because "the app needs to read from it" is never the right answer. Alternatives:
- **CloudFront Origin Access Control (OAC)** -- Serve public content via CloudFront while keeping the bucket private
- **Presigned URLs** -- Grant time-limited access to specific objects
- **S3 Access Points** -- Scoped access for specific applications

### Anti-Pattern 2: Relying on ACLs

ACLs are a legacy access control mechanism from before bucket policies existed. They are confusing, limited, and error-prone. The canonical ACL `public-read` has caused countless data breaches.

**Fix**: Set Object Ownership to "Bucket owner enforced" which disables ACLs entirely. Use bucket policies for all access control.

### Anti-Pattern 3: No Versioning on Critical Data

Without versioning, a compromised credential or ransomware actor can permanently delete or overwrite data. With versioning + MFA Delete, even a compromised root account cannot immediately destroy data.

### Anti-Pattern 4: Same-Account Logging

Storing S3 access logs in the same account as the data means a compromised account can delete its own audit trail. Send logs to a dedicated security/logging account with its own access controls.

### Anti-Pattern 5: Bucket Names Containing Sensitive Information

S3 bucket names are globally unique and can be enumerated. Names like `company-production-database-backups` or `company-pii-data` tell attackers exactly what to target. Use opaque names or at least avoid revealing the data classification.

## References

- [S3 Security Best Practices](https://docs.aws.amazon.com/AmazonS3/latest/userguide/security-best-practices.html)
- [S3 Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- [S3 Access Points](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-points.html)
- [S3 Encryption](https://docs.aws.amazon.com/AmazonS3/latest/userguide/serv-side-encryption.html)
- [Flaws.cloud](http://flaws.cloud/) -- Educational S3 misconfiguration challenges
- [GrayhatWarfare](https://buckets.grayhatwarfare.com/) -- Public bucket search engine (demonstrates the exposure risk)
