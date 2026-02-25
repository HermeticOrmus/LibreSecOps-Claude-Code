# /aws-sec-audit

> Structured security audit of AWS configuration covering IAM, S3, VPC, CloudTrail, and common misconfigurations.

## Trigger

Use when you need to:
- Review AWS infrastructure configuration for security gaps
- Audit Terraform, CloudFormation, or CDK templates before deployment
- Prepare for a compliance audit or security review
- Validate that security controls are properly configured after changes
- Investigate whether an AWS environment follows security best practices

## Input

One of:
- **Live environment**: AWS CLI access with read-only permissions (SecurityAudit managed policy or equivalent)
- **Infrastructure-as-code**: Terraform files (`.tf`), CloudFormation templates (`.yaml`/`.json`), CDK code
- **Configuration export**: Output from `aws iam get-account-authorization-details`, Security Hub findings, Prowler reports
- **Specific scope**: Focus area if not a full audit (e.g., "IAM only", "S3 buckets", "network exposure")

## Process

### Phase 1: Identity & Access Management

1. **Root account security**
   - MFA enabled on root (`aws iam get-account-summary` -- check `AccountMFAEnabled`)
   - No root access keys (`aws iam get-account-summary` -- check `AccountAccessKeysPresent`)
   - Root usage in CloudTrail (should be near zero)

2. **IAM policies**
   - Scan for `"Effect": "Allow", "Action": "*", "Resource": "*"` (full admin)
   - Check for inline policies vs managed policies (prefer managed)
   - Identify unused IAM roles and users (`aws iam generate-credential-report`)
   - Review cross-account trust relationships in role assume-role policies
   - Check for `iam:PassRole` with wildcard resource (privilege escalation vector)

3. **Access keys**
   - Age of access keys (>90 days is a finding)
   - Users with multiple active access keys
   - Access keys on root account (should not exist)

4. **Password policy**
   - Minimum length >= 14 characters
   - Complexity requirements enabled
   - Password reuse prevention (remember >= 24)

### Phase 2: Storage Security

5. **S3 bucket exposure**
   - Block Public Access at account level (`aws s3control get-public-access-block`)
   - Per-bucket Block Public Access settings
   - Bucket policies granting access to `"Principal": "*"`
   - ACLs granting public access (legacy but still dangerous)
   - Server-side encryption enabled (SSE-S3 minimum, SSE-KMS preferred)
   - S3 access logging enabled
   - Object versioning and MFA Delete for critical buckets

6. **EBS encryption**
   - Default EBS encryption enabled per region
   - Unencrypted snapshots (especially if shared)

### Phase 3: Network Security

7. **Security groups**
   - Ingress `0.0.0.0/0` on sensitive ports (22, 3389, 3306, 5432, 27017)
   - Overly permissive egress rules
   - Unused security groups
   - Security groups attached to public-facing resources

8. **VPC configuration**
   - VPC Flow Logs enabled
   - Default VPC in use (should be deleted or empty)
   - VPC endpoints for AWS services (S3, DynamoDB, SSM) to avoid internet transit
   - NACLs as defense-in-depth layer

### Phase 4: Logging & Monitoring

9. **CloudTrail**
   - Enabled in all regions
   - Log file validation enabled
   - Logs delivered to a secured S3 bucket (separate account preferred)
   - CloudTrail integrated with CloudWatch Logs
   - Management events AND data events for critical services

10. **Monitoring**
    - CloudWatch alarms for: unauthorized API calls, root usage, IAM changes, CloudTrail changes, security group changes, NACL changes, console sign-in failures
    - GuardDuty enabled in all regions
    - Config enabled with required rules

### Phase 5: Cross-Cutting Concerns

11. **Encryption**
    - KMS key rotation enabled
    - KMS key policies scoped appropriately (not `"Principal": "*"`)
    - TLS enforced on all endpoints (S3 bucket policies with `aws:SecureTransport` condition)

12. **Account-level controls**
    - AWS Organizations SCPs restricting dangerous actions
    - Alternate contacts configured
    - Support plan adequate for security response needs

## Output

```
## AWS Security Audit Results

### Scope
- Account(s): [Account IDs]
- Region(s): [Regions assessed]
- Method: [Live/IaC/Config export]
- Date: [Assessment date]

### Summary
| Category | Critical | High | Medium | Low | Pass |
|----------|----------|------|--------|-----|------|
| IAM      |          |      |        |     |      |
| Storage  |          |      |        |     |      |
| Network  |          |      |        |     |      |
| Logging  |          |      |        |     |      |
| Encryption |        |      |        |     |      |

### Findings (by severity)

#### Critical
[Findings with specific remediation steps and CLI commands]

#### High
[Findings]

#### Medium
[Findings]

#### Low
[Findings]

### Remediation Priority
1. [Fix this first -- immediate risk]
2. [Fix this next -- significant exposure]
3. [Then this -- defense in depth]

### Positive Findings
[What is well-configured -- acknowledge good security]
```
