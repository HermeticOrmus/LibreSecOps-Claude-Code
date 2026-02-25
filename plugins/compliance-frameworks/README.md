# Compliance Frameworks Plugin

> Multi-framework compliance assessment, gap analysis, evidence collection, and audit preparation for SOC 2, GDPR, PCI DSS, HIPAA, ISO 27001, and NIST frameworks.

## Overview

The Compliance Frameworks plugin provides Claude Code with expertise in security compliance -- understanding what each framework requires, assessing how well a system meets those requirements, identifying gaps, and preparing evidence for audits. Compliance is not security, but compliance frameworks encode hard-won security wisdom into structured requirements that, when properly implemented, establish a strong baseline security posture.

This plugin treats compliance as a byproduct of good security practices rather than a checkbox exercise. The approach is: build secure systems using sound engineering principles, then demonstrate compliance through evidence of those practices. When compliance requirements diverge from practical security, this plugin flags the gap and recommends addressing both the letter and spirit of the requirement.

The plugin covers the most common compliance frameworks encountered by technology organizations: SOC 2 Type II, GDPR, PCI DSS, HIPAA, ISO 27001, and NIST 800-53/CSF. It provides control mapping between frameworks so that organizations subject to multiple frameworks can satisfy overlapping requirements efficiently.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Compliance Auditor | `agents/compliance-auditor.md` | Multi-framework assessment specialist. Maps system controls to framework requirements, identifies gaps, and produces audit-ready compliance reports. |
| Evidence Collector | `agents/evidence-collector.md` | Audit evidence automation specialist. Identifies what evidence is needed for each control, where to find it, and how to collect it systematically. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/compliance-check` | `commands/compliance-check.md` | Assess a system against a specified compliance framework and produce a gap analysis report. |
| `/compliance-gap` | `commands/compliance-gap.md` | Identify specific compliance gaps between current state and framework requirements, with remediation roadmap. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| SOC 2 Controls | `skills/soc2-controls/SKILL.md` | SOC 2 Type II Trust Service Criteria reference covering Security, Availability, Processing Integrity, Confidentiality, and Privacy with common controls and evidence requirements. |
| GDPR Requirements | `skills/gdpr-requirements/SKILL.md` | GDPR compliance patterns for technology organizations covering data processing principles, data subject rights, technical and organizational measures, and breach notification. |

## Usage

### Framework Assessment

Run `/compliance-check` with a target framework (e.g., `soc2`, `gdpr`, `pci-dss`, `hipaa`, `iso27001`, `nist-csf`) to assess your system against framework requirements. The command walks through applicable controls and produces a gap analysis.

### Gap Identification

Use `/compliance-gap` when you have a specific framework target and need a detailed remediation roadmap. The command identifies each gap, estimates remediation effort, and prioritizes by audit risk.

### Audit Preparation

Activate the `evidence-collector` agent when preparing for an audit. The agent identifies what evidence is needed for each control, where to find it (logs, configurations, policies, records), and how to package it for auditors.

### Multi-Framework Mapping

Use the `compliance-auditor` agent when subject to multiple frameworks. The agent maps controls across frameworks to identify overlapping requirements, allowing you to satisfy multiple frameworks with shared controls and evidence.

## Key Concepts

- **Compliance is not security**: Compliant systems can be insecure, and secure systems can be non-compliant. The goal is to be both.
- **Controls vs evidence**: A control is what you do (e.g., "require MFA for all users"). Evidence is proof that you do it (e.g., IAM policy configuration, MFA enrollment records, access review logs).
- **Design effectiveness vs operating effectiveness**: SOC 2 Type I tests whether controls are designed correctly (point-in-time). Type II tests whether they operated effectively over a period (typically 12 months).
- **Shared responsibility**: In cloud environments, the cloud provider handles some controls (physical security, hardware) while the customer handles others (access management, data protection). Understand the split for your provider.
- **Continuous compliance**: Point-in-time assessments decay immediately. Continuous monitoring, automated evidence collection, and regular self-assessment maintain compliance between audits.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `security-hardening` | CIS Benchmarks satisfy many compliance control requirements. |
| `incident-response` | Most frameworks require incident response plans and breach notification procedures. |
| `vulnerability-scanning` | Regular vulnerability scanning is required by PCI DSS, SOC 2, and others. |
| `threat-modeling` | Some frameworks require formal risk assessment and threat analysis. |
| `identity-access-management` | Access control is the most common compliance requirement across all frameworks. |
| `security-automation` | Automated compliance monitoring and evidence collection. |

## Framework Summary

| Framework | Scope | Key Focus | Audit Type |
|-----------|-------|-----------|------------|
| SOC 2 Type II | Service organizations | Trust Service Criteria | Third-party audit |
| GDPR | EU personal data | Data protection rights | Self-assessment + DPA |
| PCI DSS v4.0 | Payment card data | Cardholder data security | QSA audit or SAQ |
| HIPAA | Health information | PHI protection | Self-assessment + HHS |
| ISO 27001 | Information security | ISMS management | Certification audit |
| NIST 800-53 | Federal systems | Security and privacy controls | Assessment |
| NIST CSF 2.0 | Any organization | Risk-based framework | Self-assessment |
| SOX | Financial reporting | Internal controls | External audit |
