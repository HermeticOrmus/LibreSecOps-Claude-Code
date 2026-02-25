# Cloud Security: Azure

> Defensive security patterns, audit workflows, and hardening guidance for Microsoft Azure environments.

---

## Overview

Microsoft Azure's security model is deeply intertwined with its identity platform, Entra ID (formerly Azure Active Directory). Unlike AWS and GCP where identity is one service among many, in Azure, Entra ID is the foundation everything builds on -- every resource access, every service principal, every managed identity flows through it. This makes Azure identity security disproportionately important, and it means that Azure security expertise requires understanding both the cloud resource layer and the enterprise identity layer.

Azure also brings unique capabilities: Conditional Access policies provide context-aware access control that considers device state, location, and risk level. Azure Policy provides declarative compliance enforcement. Microsoft Defender for Cloud offers integrated threat detection with CSPM and CWPP capabilities. This plugin provides agents, commands, and knowledge bases to leverage these capabilities effectively.

---

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Azure Security Architect | `agents/azure-security-architect.md` | Reviews and designs secure Entra ID, NSG, storage, and cross-subscription security configurations |
| Azure Compliance Auditor | `agents/azure-compliance-auditor.md` | Audits Azure environments against CIS Benchmarks, Microsoft Defender for Cloud recommendations, and Azure Policy compliance |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/azure-sec-audit` | `commands/azure-sec-audit.md` | Structured audit of Azure configuration covering Entra ID, NSGs, storage accounts, Activity Logs, and Azure Policy |

### Skills (Knowledge Bases)

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Azure Identity Patterns | `skills/azure-identity-patterns/` | Entra ID security patterns, Conditional Access, Managed Identities, PIM, and service principal security |

---

## Usage

### Quick Audit

Use `/azure-sec-audit` for a structured review of Azure subscription or tenant security. Works with live `az` CLI output, Terraform configurations, ARM/Bicep templates, or Azure Policy compliance exports.

### Architecture Review

Activate `azure-security-architect` when designing or reviewing Azure infrastructure. Particularly strong on identity architecture -- Entra ID configuration, Managed Identities, Conditional Access policies, and the relationship between Azure RBAC and Entra ID roles.

### Compliance Check

The `azure-compliance-auditor` maps configurations against CIS Azure Foundations Benchmark and Microsoft Defender for Cloud recommendations. Useful for understanding compliance posture and prioritizing remediation.

### Learning

The `azure-identity-patterns` skill contains reference material on Entra ID security, which is foundational to all Azure security. Understanding Managed Identities, Conditional Access, PIM, and service principal governance is essential before tackling any Azure security work.

---

## Key Principles

1. **Identity is everything.** Entra ID is not just an authentication service -- it is the control plane for all Azure resource access. Securing Entra ID IS securing Azure.
2. **Conditional Access replaces network perimeters.** Context-aware policies (device compliance, location, risk) provide more granular access control than IP-based restrictions.
3. **Managed Identities eliminate credential management.** Like GCP Workload Identity, Managed Identities provide automatic credential rotation without exposable secrets.
4. **Azure Policy enforces compliance at scale.** Policy definitions, initiatives, and remediation tasks provide declarative compliance enforcement.
5. **Defense in depth is built-in.** NSGs, Application Security Groups, Azure Firewall, DDoS Protection, Key Vault, Defender for Cloud -- the challenge is enabling and configuring them, not building them.

---

## Prerequisites

- Azure CLI (`az`) configured with Reader role at subscription or management group level
- Global Reader in Entra ID for identity auditing
- Familiarity with Azure resource hierarchy (Management Groups > Subscriptions > Resource Groups > Resources) and Entra ID concepts

---

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `cloud-security-aws` | Equivalent patterns for Amazon Web Services |
| `cloud-security-gcp` | Equivalent patterns for Google Cloud Platform |
| `identity-access-management` | Cloud-agnostic IAM architecture, deep RBAC/ABAC patterns |
| `kubernetes-security` | AKS-specific security including Entra ID integration |
| `cryptography-essentials` | Azure Key Vault, encryption, and certificate management |
| `compliance-frameworks` | Regulatory frameworks driving Azure security requirements |

---

## References

- [CIS Microsoft Azure Foundations Benchmark](https://www.cisecurity.org/benchmark/azure)
- [Microsoft Cloud Security Benchmark](https://learn.microsoft.com/en-us/security/benchmark/azure/)
- [Azure Security Best Practices](https://learn.microsoft.com/en-us/azure/security/fundamentals/best-practices-and-patterns)
- [Entra ID Security Operations Guide](https://learn.microsoft.com/en-us/entra/architecture/security-operations-introduction)
- [MITRE ATT&CK Cloud Matrix -- Azure](https://attack.mitre.org/matrices/enterprise/cloud/azure/)
- [ScoutSuite -- Azure Security Auditing](https://github.com/nccgroup/ScoutSuite)
