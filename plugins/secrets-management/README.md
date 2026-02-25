# Secrets Management Plugin

> Detect, protect, rotate, and manage secrets across the software development lifecycle -- from code to production infrastructure.

## Overview

The Secrets Management plugin addresses one of the most persistent and damaging security problems in software development: the exposure of credentials, API keys, tokens, and other sensitive material. According to GitGuardian's annual reports, millions of secrets are leaked in public repositories every year, and the problem is worse in private repositories where teams assume exposure is limited.

This plugin covers two complementary domains. First, **secret detection** -- finding secrets that have already leaked into code, configuration, logs, or artifacts. Second, **secret architecture** -- designing systems where secrets are stored in vaults, rotated automatically, accessed through secure channels, and never touch code or configuration files in plaintext.

The guiding principle is defense in depth: assume secrets will leak (because they do), and build systems that limit the blast radius when they do. Short-lived credentials, automatic rotation, least-privilege access, and comprehensive audit logging are the foundations.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Secrets Architect | `agents/secrets-architect.md` | Designs vault infrastructure, rotation strategies, and secret distribution patterns. Covers HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, Azure Key Vault, and open-source alternatives. |
| Secret Scanner | `agents/secret-scanner.md` | Detects leaked secrets in code, configuration, CI/CD, container images, and logs. Configures gitleaks, trufflehog, and custom detection patterns. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/secrets-audit` | `commands/secrets-audit.md` | Scan a project for hardcoded secrets, exposed credentials, and secret management anti-patterns. |
| `/secrets-rotate` | `commands/secrets-rotate.md` | Plan and document a secret rotation procedure for identified credentials. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Vault Patterns | `skills/vault-patterns/SKILL.md` | Reference knowledge for HashiCorp Vault, AWS Secrets Manager, GCP Secret Manager, and secret storage architecture patterns. |
| Secret Detection | `skills/secret-detection/SKILL.md` | Detection patterns, tool configuration, regex patterns for common secret types, and false positive management. |

## Usage

### Scan for Leaked Secrets

Run `/secrets-audit` in any project to scan for hardcoded secrets. The command checks source code, configuration files, environment templates, CI/CD configurations, Docker files, and documentation for exposed credentials.

### Design Secret Infrastructure

Activate the `secrets-architect` agent when designing or improving secret management infrastructure. The agent helps select the right vault solution, design access patterns, configure rotation, and integrate with application code.

### Investigate a Leak

When a secret is confirmed leaked, use `/secrets-rotate` to plan the rotation. The command generates a step-by-step rotation procedure specific to the credential type, including revocation, regeneration, distribution, and verification.

### Continuous Detection

The `secret-scanner` agent helps configure detection tools (gitleaks, trufflehog) in CI/CD pipelines and pre-commit hooks for ongoing protection.

## Key Concepts

- **Secrets are not passwords alone**: API keys, database connection strings, TLS private keys, OAuth tokens, SSH keys, webhook signing secrets, JWT signing keys, and encryption keys are all secrets.
- **Rotation is not optional**: A secret that never rotates is a secret with infinite exposure window. Automate rotation where possible, and define manual rotation procedures where automation is not yet feasible.
- **Vault access is also a secret**: The token used to access the vault is itself a credential. Use identity-based authentication (IAM roles, Kubernetes service accounts, OIDC) instead of static vault tokens wherever possible.
- **Entropy is not enough**: Secret scanners that rely solely on entropy detection produce excessive false positives. Pattern-based detection (known secret formats) combined with entropy provides the best accuracy.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `devsecops-pipelines` | Secret scanning is a critical CI/CD pipeline stage. This plugin provides detection patterns, the pipeline plugin provides integration. |
| `supply-chain-security` | Leaked secrets in dependencies are a supply chain risk vector. |
| `cloud-security-aws` | AWS-specific secret management (Secrets Manager, Parameter Store, IAM roles). |
| `cloud-security-gcp` | GCP-specific secret management (Secret Manager, Workload Identity). |
| `identity-access-management` | Secret access control is a subset of IAM. Vault policies are access control policies. |
| `incident-response` | Secret leaks are security incidents that require response procedures. |
