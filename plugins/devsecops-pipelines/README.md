# DevSecOps Pipelines Plugin

> Design, implement, and harden security-integrated CI/CD pipelines that catch vulnerabilities before they reach production.

## Overview

The DevSecOps Pipelines plugin provides the knowledge and methodology to embed security controls directly into CI/CD pipelines. The core principle is "shift left" -- finding vulnerabilities as early as possible in the development lifecycle, where fixes are cheapest and fastest. But this plugin goes beyond shift-left into "shift everywhere" -- security gates at commit time, build time, test time, deploy time, and runtime.

A well-designed DevSecOps pipeline is not just a collection of security scanners bolted onto CI. It is an architecture decision about when to scan, what to scan, how to gate, and when to break the build versus when to warn. Too many gates and developers route around security. Too few and vulnerabilities ship. This plugin helps find the balance that actually works.

The plugin covers the three major CI/CD platforms (GitHub Actions, GitLab CI/CD, and Jenkins) with transferable patterns that apply to any pipeline system. All security tooling recommendations prioritize open-source tools to maintain the LibreSecOps philosophy.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| DevSecOps Architect | `agents/devsecops-architect.md` | Designs end-to-end security pipeline architecture. Selects tools, defines stages, configures gates, and balances security rigor with developer velocity. |
| Pipeline Security Integrator | `agents/pipeline-security-integrator.md` | Hands-on implementation specialist. Writes pipeline configurations, integrates security tools, configures thresholds, and troubleshoots scanning failures. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/devsecops-setup` | `commands/devsecops-setup.md` | Configure security scanning in an existing CI/CD pipeline. Detects the pipeline platform and adds appropriate security stages. |
| `/security-gate` | `commands/security-gate.md` | Define or modify quality gates that determine whether a build passes or fails based on security findings. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| CI Security Patterns | `skills/ci-security-patterns/SKILL.md` | Reference patterns for GitHub Actions, GitLab CI, and Jenkins security stages with real workflow syntax and tool configurations. |
| Security Gates | `skills/security-gates/SKILL.md` | Quality gate definitions, threshold configuration, and the decision framework for when to break the build versus warn. |

## Usage

### Bootstrap Security in Existing Pipeline

Run `/devsecops-setup` in any project with a CI/CD configuration (.github/workflows/, .gitlab-ci.yml, Jenkinsfile). The command detects the platform, identifies what security scanning is already present, and adds the missing stages.

### Design from Scratch

Activate the `devsecops-architect` agent when designing a new pipeline or redesigning an existing one. The agent helps select tools, define the stage order, configure parallelism for scan speed, and set up reporting.

### Configure Gates

Use `/security-gate` to define or adjust the thresholds that determine pass/fail. This is where the real tuning happens -- setting gates too strict causes alert fatigue, too loose lets vulnerabilities through.

### Tool Integration

The `pipeline-security-integrator` agent handles the implementation details: writing YAML, configuring tool flags, setting up caching for scan speed, and integrating results into PR comments and dashboards.

## Key Concepts

- **Security stages**: Pre-commit (hooks), commit (SAST, secrets), build (SCA, container scan), test (DAST, API scan), deploy (infrastructure scan, signing), post-deploy (runtime monitoring).
- **Fail-open vs. fail-closed**: Should a scanner error (not a finding, but the tool itself failing) block the pipeline? The answer depends on the stage and the tool.
- **Baseline suppression**: Initial adoption generates hundreds of findings in existing code. Suppress the baseline, enforce zero-new-findings, and burn down the backlog separately.
- **Developer experience**: If security scanning adds 20 minutes to every PR, developers will find ways around it. Speed matters.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `supply-chain-security` | SCA and SBOM generation are pipeline stages. Supply chain plugin provides the methodology, this plugin integrates it. |
| `secrets-management` | Secret scanning is a critical pipeline stage. Secrets plugin covers the detection patterns and vault integration. |
| `container-security` | Container image scanning is a build-time pipeline stage. |
| `vulnerability-scanning` | SAST, DAST, and infrastructure scanning are all pipeline stages. |
| `compliance-frameworks` | Compliance requirements often mandate specific pipeline controls (SOC 2, ISO 27001, PCI DSS). |
