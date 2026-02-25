# Security Hardening Plugin

> Systematic security hardening for operating systems, networks, applications, and cloud infrastructure, aligned with CIS Benchmarks and industry best practices.

## Overview

The Security Hardening plugin provides Claude Code with expertise in reducing attack surface through secure configuration of operating systems, network devices, applications, databases, and cloud services. Hardening is the practice of configuring systems to be secure by default -- disabling unnecessary features, removing default credentials, restricting permissions, and enabling security controls.

Security hardening is one of the most impactful defensive activities because it eliminates entire categories of attacks before they can be attempted. A properly hardened system with up-to-date patches eliminates the majority of commodity threats. This plugin uses CIS (Center for Internet Security) Benchmarks as the primary reference framework, supplemented by vendor-specific hardening guides and field-tested security practices.

Hardening is not a one-time activity. It must be automated, audited continuously, and updated as new threats emerge and configurations drift. This plugin supports both initial hardening and ongoing compliance monitoring.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Hardening Specialist | `agents/hardening-specialist.md` | OS, network, and application hardening expert. Produces specific configuration recommendations for the target platform with implementation commands and verification steps. |
| Benchmark Auditor | `agents/benchmark-auditor.md` | CIS Benchmark compliance specialist. Assesses current configuration against benchmark requirements, identifies gaps, and provides remediation guidance with pass/fail status. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/harden` | `commands/harden.md` | Generate a security hardening checklist and configuration guide for a specified target platform. |
| `/benchmark` | `commands/benchmark.md` | Assess configuration against CIS Benchmark requirements and produce a compliance report. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| CIS Benchmarks | `skills/cis-benchmarks/SKILL.md` | Reference knowledge base for CIS Benchmark controls across common platforms: Linux, Windows, Docker, Kubernetes, AWS, Azure, GCP, PostgreSQL, MySQL, Nginx, Apache. |

## Usage

### Hardening a System

Run `/harden` and specify the target platform (e.g., `ubuntu-22.04`, `docker`, `nginx`, `kubernetes`, `aws`). The command produces a prioritized hardening checklist with specific configuration changes, implementation commands, and verification steps.

### Compliance Assessment

Run `/benchmark` with a target platform to assess current configuration against CIS Benchmark requirements. The command audits configuration files and settings against benchmark controls and produces a pass/fail compliance report.

### Interactive Hardening

Activate the `hardening-specialist` agent for guided hardening sessions where you can ask about specific configurations, get explanations for why each setting matters, and handle edge cases where the default recommendation doesn't fit your environment.

### Benchmark Compliance

Use the `benchmark-auditor` agent for detailed CIS Benchmark compliance work, including understanding which controls apply to your profile level (Level 1 vs Level 2), which controls can be automated, and which require manual verification.

## Key Concepts

- **Attack surface reduction**: Every unnecessary service, port, permission, and feature is a potential entry point. Hardening removes what you don't need.
- **Defense in depth**: Hardening at every layer (OS, network, application, database, cloud) creates overlapping defenses. Compromise of one layer doesn't immediately compromise all layers.
- **CIS Benchmark profiles**: Level 1 controls are practical security measures with minimal operational impact. Level 2 controls provide deeper defense but may affect functionality. Start with Level 1.
- **Configuration as code**: Hardening should be automated through configuration management (Ansible, Chef, Puppet, Terraform) and verified through automated compliance checks. Manual hardening drifts.
- **Compensating controls**: When a benchmark recommendation can't be implemented (compatibility, performance, operational reasons), document the exception and implement a compensating control.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `compliance-frameworks` | CIS Benchmarks map to compliance framework controls. Hardening helps satisfy compliance requirements. |
| `container-security` | Container and Kubernetes hardening is a critical specialty. |
| `cloud-security-aws` / `azure` / `gcp` | Cloud-specific hardening guides. |
| `network-security` | Network device and architecture hardening. |
| `devsecops-pipelines` | Automated hardening verification in CI/CD. |
| `incident-response` | Post-incident hardening prevents recurrence. |

## Hardening Domains

| Domain | Key Areas |
|--------|-----------|
| Linux OS | Filesystem permissions, service minimization, kernel parameters, PAM configuration, audit logging, firewall rules |
| Windows OS | Group Policy, Windows Firewall, service hardening, registry security, audit policy, credential guard |
| Docker | Daemon configuration, image security, runtime restrictions, network segmentation, resource limits |
| Kubernetes | Pod security, RBAC, network policies, secrets management, admission controllers, etcd encryption |
| Web Servers | TLS configuration, security headers, access control, logging, module minimization |
| Databases | Authentication, network binding, encryption, audit logging, backup security, privilege minimization |
| Cloud (AWS/Azure/GCP) | IAM, network security groups, encryption, logging, public access prevention, resource policies |
