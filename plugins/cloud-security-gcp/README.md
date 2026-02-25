# Cloud Security: GCP

> Defensive security patterns, audit workflows, and hardening guidance for Google Cloud Platform environments.

---

## Overview

Google Cloud Platform takes a distinct approach to cloud security compared to AWS and Azure. Its resource hierarchy (Organization > Folder > Project > Resource) is deeply integrated with IAM, and Organization Policies provide declarative guardrails that operate differently from AWS SCPs. GCP's IAM model uses roles with predefined permission bundles, and its VPC networking is global by default -- both design choices with significant security implications.

This plugin provides Claude Code agents, commands, and knowledge bases for securing GCP environments. The focus is on understanding GCP's security primitives on their own terms, not as analogs to AWS concepts. While there are similarities, GCP's IAM condition support, VPC Service Controls, and Binary Authorization represent genuinely different approaches to cloud security.

---

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| GCP Security Architect | `agents/gcp-security-architect.md` | Reviews and designs secure GCP IAM configurations, VPC architectures, GCS buckets, and cross-project security |
| GCP Org Policy Auditor | `agents/gcp-org-policy-auditor.md` | Audits Organization Policy constraints, resource hierarchy, and compliance with CIS GCP Benchmark |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/gcp-sec-audit` | `commands/gcp-sec-audit.md` | Structured audit of GCP configuration covering IAM, GCS, VPC, Cloud Audit Logs, and Organization Policies |

### Skills (Knowledge Bases)

| Skill | Directory | Purpose |
|-------|-----------|---------|
| GCP IAM Patterns | `skills/gcp-iam-patterns/` | Secure GCP IAM patterns, custom role design, IAM conditions, and Workload Identity Federation |

---

## Usage

### Quick Audit

Use `/gcp-sec-audit` for a structured review of GCP project or organization security. Works with live `gcloud` output, Terraform configurations, or Deployment Manager templates.

### Architecture Review

Activate `gcp-security-architect` when designing or reviewing GCP infrastructure. It focuses on IAM bindings, VPC design, GCS access control, and cross-project resource sharing.

### Organization Compliance

The `gcp-org-policy-auditor` evaluates Organization Policy constraints against CIS GCP Foundations Benchmark and Google's security best practices. Particularly valuable for multi-project environments with complex folder hierarchies.

### Learning

The `gcp-iam-patterns` skill contains reference material on GCP's IAM model, including the critical difference between basic roles, predefined roles, and custom roles, along with IAM conditions and Workload Identity Federation patterns.

---

## Key Principles

1. **The resource hierarchy IS your security architecture.** Organization > Folders > Projects creates inheritable boundaries. Design the hierarchy before setting policies.
2. **Predefined roles over basic roles.** Basic roles (Owner, Editor, Viewer) are overly broad. Predefined roles provide least-privilege bundles per service.
3. **VPC Service Controls are the cloud perimeter.** They prevent data exfiltration even with valid credentials -- a capability unique to GCP.
4. **Organization Policies are declarative guardrails.** They define what CAN happen in your organization, regardless of IAM permissions.
5. **Cloud Audit Logs are always on.** Admin Activity logs are enabled by default and cannot be disabled. Data Access logs require explicit enablement.

---

## Prerequisites

- `gcloud` CLI configured with appropriate read-only permissions
- Organization-level access for Organization Policy auditing
- Familiarity with GCP resource hierarchy, IAM, and VPC concepts

---

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `cloud-security-aws` | Equivalent patterns for Amazon Web Services |
| `cloud-security-azure` | Equivalent patterns for Microsoft Azure |
| `identity-access-management` | Cloud-agnostic IAM architecture and access control models |
| `kubernetes-security` | GKE-specific security including Workload Identity |
| `container-security` | Container security for Cloud Run and GKE workloads |
| `cryptography-essentials` | Deeper coverage of encryption, Cloud KMS, and key management |

---

## References

- [CIS Google Cloud Platform Foundations Benchmark](https://www.cisecurity.org/benchmark/google_cloud_computing_platform)
- [Google Cloud Security Best Practices](https://cloud.google.com/docs/enterprise/best-practices-for-enterprise-organizations)
- [Google Cloud Security Foundations Guide](https://cloud.google.com/architecture/security-foundations)
- [MITRE ATT&CK Cloud Matrix -- GCP](https://attack.mitre.org/matrices/enterprise/cloud/gcp/)
- [ScoutSuite -- GCP Security Auditing](https://github.com/nccgroup/ScoutSuite)
