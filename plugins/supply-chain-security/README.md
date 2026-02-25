# Supply Chain Security Plugin

> Analyze, audit, and harden software supply chains -- from dependency trees to build pipelines to artifact integrity.

## Overview

The Supply Chain Security plugin equips Claude Code with the knowledge and methodology to identify risks across the entire software supply chain. Software supply chain attacks have become one of the most impactful threat vectors in modern computing, from the SolarWinds Orion compromise (2020) to the xz-utils backdoor (2024). This plugin addresses the full lifecycle: dependency selection, vulnerability tracking, integrity verification, SBOM generation, and risk-based prioritization.

The focus is **proactive defense** -- identifying risks before they become incidents. This means understanding not just known CVEs in dependencies, but also evaluating maintainer trust signals, detecting typosquatting attempts, verifying package provenance, and maintaining a continuous inventory of what your software actually contains.

This plugin operates within the framework of NIST SP 800-161r1 (Cybersecurity Supply Chain Risk Management) and the SLSA (Supply-chain Levels for Software Artifacts) framework for build integrity.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Dependency Auditor | `agents/dependency-auditor.md` | Software Composition Analysis (SCA) specialist. Audits dependency trees for known vulnerabilities, license risks, and supply chain integrity. Generates SBOMs in SPDX and CycloneDX formats. |
| Package Integrity Analyst | `agents/package-integrity-analyst.md` | Detects typosquatting, dependency confusion, malicious packages, and compromised maintainer accounts. Evaluates package provenance and trust signals. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/supply-chain-audit` | `commands/supply-chain-audit.md` | Full supply chain audit of a project's dependencies, producing a risk-rated report covering CVEs, license issues, maintainer health, and integrity verification. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| SBOM Generation | `skills/sbom-generation/SKILL.md` | Reference knowledge for generating Software Bills of Materials in SPDX 2.3 and CycloneDX 1.5 formats, including tooling, automation, and compliance requirements. |
| Dependency Risk Assessment | `skills/dependency-risk-assessment/SKILL.md` | Methodology for scoring dependency risk across multiple dimensions: vulnerability history, maintainer activity, dependency depth, license compatibility, and provenance. |

## Usage

### Quick Audit

Run `/supply-chain-audit` in any project with a package manager lockfile (package-lock.json, Cargo.lock, go.sum, requirements.txt, Gemfile.lock, etc.). The command identifies the ecosystem, parses the dependency tree, and produces a prioritized risk report.

### Deep Analysis

Activate the `dependency-auditor` agent for interactive SCA sessions. The agent walks through the dependency tree methodically, cross-references against vulnerability databases (NVD, OSV, GitHub Advisory Database), and helps generate SBOMs for compliance or procurement requirements.

### Threat-Focused Review

Use the `package-integrity-analyst` agent when you suspect a compromised dependency, need to evaluate a new package before adoption, or want to assess your exposure to supply chain attack patterns like dependency confusion or typosquatting.

## Key Concepts

- **SBOM (Software Bill of Materials)**: A machine-readable inventory of every component in your software. Required by Executive Order 14028 for US federal procurement and increasingly expected in enterprise environments.
- **SLSA (Supply-chain Levels for Software Artifacts)**: A framework for evaluating build integrity, from Level 1 (documented build process) to Level 4 (hermetic, reproducible builds with two-party review).
- **Dependency confusion**: An attack where a private package name is registered on a public registry, causing build systems to pull the malicious public version instead of the intended private one.
- **Provenance**: Cryptographic evidence of where, when, and how a software artifact was built. Sigstore and in-toto are the primary frameworks.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `devsecops-pipelines` | Supply chain controls integrate directly into CI/CD pipelines as build-time gates. |
| `secrets-management` | Leaked credentials in dependencies are a supply chain risk. Secret scanning covers the detection side. |
| `container-security` | Container images have their own supply chains -- base images, layers, and embedded dependencies. |
| `vulnerability-scanning` | Vulnerability scanning is the detection layer; supply chain security is the broader strategy. |
| `compliance-frameworks` | SBOM requirements originate from compliance mandates (EO 14028, NIS2, FDA cybersecurity guidance). |
