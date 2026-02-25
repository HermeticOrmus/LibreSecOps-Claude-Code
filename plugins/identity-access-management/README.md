# Identity & Access Management

> Cloud-agnostic IAM architecture, access control models (RBAC/ABAC/ReBAC), authentication flow security, and MFA implementation patterns.

---

## Overview

Identity and Access Management is the discipline of ensuring the right individuals access the right resources at the right times for the right reasons. It is the most important security domain because every other control depends on it -- network security, encryption, logging, and application security all assume that identity is established and trustworthy.

IAM failures are the leading cause of cloud breaches. Not because the technology is weak, but because IAM is architecturally complex: it spans authentication (proving who you are), authorization (what you can do), governance (should you still have access), and federation (trusting external identity providers). Each of these layers has its own failure modes.

This plugin covers IAM from first principles -- access control models, authentication protocols, MFA implementation, and audit patterns -- in a cloud-agnostic way. For cloud-specific IAM, see the AWS, GCP, and Azure security plugins. For Kubernetes-specific access control, see the Kubernetes security plugin.

---

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| IAM Architect | `agents/iam-architect.md` | Designs identity architecture, SSO integration, MFA strategy, and access governance |
| Access Control Auditor | `agents/access-control-auditor.md` | Reviews RBAC/ABAC/ReBAC implementations, identifies privilege creep, and evaluates access control effectiveness |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/iam-audit` | `commands/iam-audit.md` | Audit access controls across applications and infrastructure |
| `/auth-flow-review` | `commands/auth-flow-review.md` | Review authentication and authorization flows for security issues |

### Skills (Knowledge Bases)

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Access Control Models | `skills/access-control-models/` | RBAC, ABAC, ReBAC patterns -- when to use which, implementation guidance |
| MFA Implementation | `skills/mfa-implementation/` | MFA methods, integration patterns, and bypass prevention |

---

## Usage

### IAM Architecture

Activate `iam-architect` when designing authentication/authorization systems, evaluating SSO providers, or planning MFA rollouts. It provides architectural guidance independent of specific cloud or platform.

### Access Review

Activate `access-control-auditor` when reviewing existing access controls for privilege creep, evaluating RBAC implementations, or auditing who has access to what.

### Quick Audit

Use `/iam-audit` for a structured review of access controls in a specific system or application.

### Authentication Review

Use `/auth-flow-review` when reviewing login flows, OAuth/OIDC implementations, session management, or token handling.

---

## Key Principles

1. **Least privilege.** Every identity should have the minimum permissions necessary. Excess permissions are attack surface.
2. **Just-in-time access.** Permanent privileges should be rare. Elevated access should be time-bounded and require justification.
3. **Separation of duties.** No single identity should be able to complete a critical transaction alone (e.g., approve and deploy).
4. **Identity lifecycle management.** Onboarding, role changes, and offboarding must be automated. Stale accounts are backdoors.
5. **Strong authentication everywhere.** Passwords alone are insufficient. MFA is mandatory, passwordless is the goal.

---

## Prerequisites

- Understanding of authentication vs authorization concepts
- Familiarity with at least one identity provider (Entra ID, Okta, Google Workspace, Keycloak)
- For auth flow reviews: familiarity with OAuth 2.0, OIDC, SAML, or JWT

---

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `cloud-security-aws` | AWS IAM-specific patterns and policies |
| `cloud-security-gcp` | GCP IAM-specific patterns and Workload Identity |
| `cloud-security-azure` | Entra ID, Conditional Access, PIM |
| `kubernetes-security` | Kubernetes RBAC implementation |
| `zero-trust-architecture` | Zero trust principles built on strong IAM |
| `cryptography-essentials` | Cryptographic foundations of authentication (hashing, signing, TLS) |

---

## References

- [NIST SP 800-63: Digital Identity Guidelines](https://pages.nist.gov/800-63-3/)
- [NIST SP 800-207: Zero Trust Architecture](https://csrc.nist.gov/publications/detail/sp/800-207/final)
- [OAuth 2.0 Security Best Current Practice](https://datatracker.ietf.org/doc/html/draft-ietf-oauth-security-topics)
- [OpenID Connect Core Specification](https://openid.net/specs/openid-connect-core-1_0.html)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [Google BeyondCorp Papers](https://cloud.google.com/beyondcorp)
