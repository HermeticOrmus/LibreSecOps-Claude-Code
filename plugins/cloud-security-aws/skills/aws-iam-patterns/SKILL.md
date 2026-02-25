# AWS IAM Patterns

> Secure IAM policy patterns, least-privilege templates, and the policy evaluation logic that governs all AWS access control.

## Knowledge Base

### IAM Policy Evaluation Logic

This is the most important concept in AWS security. Every API call is evaluated as follows:

1. **Explicit Deny** -- If ANY policy says Deny, the action is denied. Period. No override.
2. **Organizations SCP** -- If no SCP allows it, denied (SCPs are allowlists for member accounts).
3. **Resource-based policy** -- If a resource policy grants access, it can allow cross-account access without an identity policy (except for IAM roles in the same account).
4. **Identity-based policy** -- The policies attached to the user/role/group.
5. **Permissions boundary** -- If set, the effective permissions are the INTERSECTION of the identity policy and the boundary.
6. **Session policy** -- For assumed roles or federated users, further restricts to the intersection.
7. **Implicit Deny** -- If nothing explicitly allows it, denied.

Understanding this chain is what separates a secure AWS environment from a breached one.

### Policy Types and When to Use Each

| Policy Type | Attached To | Use Case |
|-------------|-------------|----------|
| Identity-based (managed) | Users, roles, groups | Standard permissions for principals |
| Identity-based (inline) | Single user/role/group | Exception permissions that should not be reusable |
| Resource-based | S3 buckets, KMS keys, SQS queues, Lambda, etc. | Cross-account access, service principal access |
| Permissions boundary | Users, roles | Delegation -- let developers create roles within a boundary |
| SCP | Organization OU/account | Guardrails -- prevent entire categories of actions |
| Session policy | AssumeRole, GetFederationToken | Further restrict a specific session |

## Patterns

### Pattern 1: Least-Privilege Role for a Lambda Function

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadSpecificDynamoDBTable",
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:Query",
        "dynamodb:BatchGetItem"
      ],
      "Resource": "arn:aws:dynamodb:us-east-1:123456789012:table/orders"
    },
    {
      "Sid": "WriteToSpecificS3Prefix",
      "Effect": "Allow",
      "Action": [
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::reports-bucket/lambda-output/*"
    },
    {
      "Sid": "AllowLogging",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:us-east-1:123456789012:log-group:/aws/lambda/my-function:*"
    }
  ]
}
```

**Why this works**: Each statement names the exact actions, targets the exact resource ARN, and includes only what the function needs. No wildcards in actions or resources.

### Pattern 2: Permissions Boundary for Developer Self-Service

Allow developers to create IAM roles for their applications, but constrain what those roles can do:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCommonServices",
      "Effect": "Allow",
      "Action": [
        "s3:*",
        "dynamodb:*",
        "sqs:*",
        "sns:*",
        "logs:*",
        "xray:*",
        "lambda:InvokeFunction"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyPrivilegeEscalation",
      "Effect": "Deny",
      "Action": [
        "iam:CreateUser",
        "iam:CreateRole",
        "iam:AttachRolePolicy",
        "iam:PutRolePolicy",
        "iam:AddUserToGroup",
        "iam:CreateAccessKey",
        "organizations:*",
        "account:*"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenySecurityServiceChanges",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "guardduty:DeleteDetector",
        "config:StopConfigurationRecorder"
      ],
      "Resource": "*"
    }
  ]
}
```

**Why this works**: Developers can create roles that use common services, but the boundary prevents those roles from modifying IAM, disabling security tools, or escalating privileges. The explicit denies cannot be overridden.

### Pattern 3: SCP Guardrails for an Organization

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "DenyLeavingOrganization",
      "Effect": "Deny",
      "Action": "organizations:LeaveOrganization",
      "Resource": "*"
    },
    {
      "Sid": "ProtectCloudTrail",
      "Effect": "Deny",
      "Action": [
        "cloudtrail:StopLogging",
        "cloudtrail:DeleteTrail",
        "cloudtrail:PutEventSelectors"
      ],
      "Resource": "arn:aws:cloudtrail:*:*:trail/organization-trail",
      "Condition": {
        "StringNotLike": {
          "aws:PrincipalArn": "arn:aws:iam::*:role/SecurityAdmin"
        }
      }
    },
    {
      "Sid": "RequireIMDSv2",
      "Effect": "Deny",
      "Action": "ec2:RunInstances",
      "Resource": "arn:aws:ec2:*:*:instance/*",
      "Condition": {
        "StringNotEquals": {
          "ec2:MetadataHttpTokens": "required"
        }
      }
    },
    {
      "Sid": "DenyPublicS3",
      "Effect": "Deny",
      "Action": "s3:PutBucketPublicAccessBlock",
      "Resource": "*",
      "Condition": {
        "StringNotLike": {
          "aws:PrincipalArn": "arn:aws:iam::*:role/SecurityAdmin"
        }
      }
    }
  ]
}
```

**Why this works**: SCPs operate at the organization level and cannot be bypassed by any IAM policy in member accounts. These prevent the most dangerous actions organization-wide while allowing a specific security role to make exceptions when needed.

### Pattern 4: Cross-Account Access with External ID

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AllowCrossAccountAssume",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::987654321098:role/vendor-integration"
      },
      "Action": "sts:AssumeRole",
      "Condition": {
        "StringEquals": {
          "sts:ExternalId": "unique-secret-per-customer-abc123"
        }
      }
    }
  ]
}
```

**Why this works**: The External ID prevents the "confused deputy" problem -- where a third party could trick the role into assuming access on behalf of a different customer. Always require External ID for third-party cross-account access.

## Anti-Patterns

### Anti-Pattern 1: The Admin Policy

```json
{
  "Effect": "Allow",
  "Action": "*",
  "Resource": "*"
}
```

**Why it is dangerous**: Grants full access to every AWS service and every resource. A single compromised credential means full account takeover. Even "admin" users should have bounded permissions with explicit denies on the most dangerous actions.

### Anti-Pattern 2: PassRole Without Resource Constraint

```json
{
  "Effect": "Allow",
  "Action": "iam:PassRole",
  "Resource": "*"
}
```

**Why it is dangerous**: `iam:PassRole` allows a user to assign an IAM role to a service (e.g., Lambda, EC2). With `Resource: *`, the user can pass a high-privilege role to a service they control, effectively escalating to that role's permissions. Always constrain to specific role ARNs.

### Anti-Pattern 3: Wildcard Principal in Resource Policy

```json
{
  "Effect": "Allow",
  "Principal": "*",
  "Action": "s3:GetObject",
  "Resource": "arn:aws:s3:::my-bucket/*"
}
```

**Why it is dangerous**: This makes every object in the bucket accessible to anyone on the internet. If the bucket contains any sensitive data, this is a breach. Use specific account IDs, role ARNs, or VPC endpoint conditions instead.

### Anti-Pattern 4: Not Using Conditions

Policies without conditions are usually too broad. Key conditions to use:
- `aws:SourceIp` -- Restrict by IP range (for human users)
- `aws:PrincipalOrgID` -- Restrict to your organization
- `aws:RequestedRegion` -- Restrict to approved regions
- `aws:SecureTransport` -- Require TLS
- `ec2:MetadataHttpTokens` -- Require IMDSv2

## References

- [IAM Policy Evaluation Logic](https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_evaluation-logic.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS IAM Access Analyzer](https://docs.aws.amazon.com/IAM/latest/UserGuide/what-is-access-analyzer.html)
- [Parliament -- IAM Policy Linting](https://github.com/duo-labs/parliament)
- [Cloudsplaining -- IAM Security Assessment](https://github.com/salesforce/cloudsplaining)
- [Rhino Security Labs -- AWS IAM Privilege Escalation](https://rhinosecuritylabs.com/aws/aws-privilege-escalation-methods-mitigation/)
