# Cloud Security: AWS

> Defensive security patterns, audit workflows, and hardening guidance for Amazon Web Services environments.

---

## Overview

AWS is the most widely adopted cloud platform, and its breadth creates an enormous attack surface. Misconfigured S3 buckets, overly permissive IAM policies, and exposed security groups account for the majority of cloud breaches -- not sophisticated exploits. This plugin provides Claude Code agents, commands, and knowledge bases focused on identifying and remediating these common AWS security gaps before attackers find them.

The focus is defensive and educational. Every pattern here teaches you WHY a configuration is dangerous, not just that it is. Understanding the mechanism is what separates a checklist operator from a security engineer.

---

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| AWS Security Architect | `agents/aws-security-architect.md` | Reviews and designs secure IAM policies, VPC architectures, S3 configurations, and cross-service security patterns |
| AWS Compliance Auditor | `agents/aws-compliance-auditor.md` | Audits AWS environments against CIS Benchmarks, AWS Well-Architected Framework security pillar, and organizational security baselines |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/aws-sec-audit` | `commands/aws-sec-audit.md` | Structured audit of AWS configuration covering IAM, S3, VPC, CloudTrail, and common misconfigurations |

### Skills (Knowledge Bases)

| Skill | Directory | Purpose |
|-------|-----------|---------|
| AWS IAM Patterns | `skills/aws-iam-patterns/` | Secure IAM policy patterns, least-privilege templates, and common policy anti-patterns |
| AWS S3 Security | `skills/aws-s3-security/` | S3 bucket security configurations, access control models, encryption, and data exposure prevention |

---

## Usage

### Quick Audit

Use `/aws-sec-audit` when you need a structured review of an AWS configuration, Terraform plan, or CloudFormation template. The command walks through critical security areas systematically.

### Architecture Review

Activate the `aws-security-architect` agent when designing new infrastructure or reviewing existing architecture. It focuses on IAM boundaries, network segmentation, encryption at rest and in transit, and cross-account access patterns.

### Compliance Check

The `aws-compliance-auditor` agent maps configurations against CIS AWS Foundations Benchmark controls and the AWS Well-Architected Framework security pillar. Useful for pre-audit preparation or continuous compliance monitoring.

### Learning

The skills directories contain reference material you can consult independently. `aws-iam-patterns` is particularly valuable for understanding the IAM policy evaluation logic -- the single most important security mechanism in AWS.

---

## Key Principles

1. **Identity is the perimeter.** In AWS, IAM policies are your primary security control. Network controls matter but are secondary to identity.
2. **Default deny, explicit allow.** AWS IAM denies by default. Every permission must be explicitly granted. The danger is in overly broad grants.
3. **Encryption is table stakes.** S3 default encryption, EBS encryption, RDS encryption -- these should be on by default, enforced by SCPs.
4. **Logging is non-negotiable.** CloudTrail in all regions, S3 access logging, VPC Flow Logs. You cannot defend what you cannot see.
5. **Blast radius matters.** Use AWS Organizations, SCPs, and account boundaries to limit the impact of any single compromise.

---

## Prerequisites

- AWS CLI configured with appropriate read-only credentials for auditing
- Familiarity with AWS IAM, VPC, and S3 concepts
- For infrastructure-as-code reviews: Terraform, CloudFormation, or CDK files available locally

---

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `cloud-security-gcp` | Equivalent patterns for Google Cloud Platform |
| `cloud-security-azure` | Equivalent patterns for Microsoft Azure |
| `identity-access-management` | Cloud-agnostic IAM architecture and access control models |
| `cryptography-essentials` | Deeper coverage of encryption algorithms and key management |
| `compliance-frameworks` | Regulatory frameworks (SOC 2, PCI DSS, HIPAA) that drive AWS security requirements |
| `container-security` | Security for ECS, EKS, and Fargate workloads running on AWS |

---

## References

- [CIS Amazon Web Services Foundations Benchmark](https://www.cisecurity.org/benchmark/amazon_web_services)
- [AWS Well-Architected Framework -- Security Pillar](https://docs.aws.amazon.com/wellarchitected/latest/security-pillar/)
- [AWS Security Best Practices (whitepaper)](https://docs.aws.amazon.com/whitepapers/latest/aws-security-best-practices/)
- [MITRE ATT&CK Cloud Matrix -- AWS](https://attack.mitre.org/matrices/enterprise/cloud/aws/)
