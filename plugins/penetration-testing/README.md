# Penetration Testing Plugin

> Structured penetration testing methodology, scoping, planning, and vulnerability analysis for authorized security assessments.

## Overview

The Penetration Testing plugin provides Claude Code with the methodology, planning frameworks, and vulnerability analysis expertise needed to support authorized penetration testing engagements. It covers the full lifecycle from scoping and rules of engagement through reconnaissance, vulnerability identification, exploitation analysis, and reporting.

This plugin does not execute attacks. It provides the knowledge framework for planning assessments, analyzing discovered vulnerabilities, understanding exploitation paths, and producing professional reports. All content is for **authorized defensive security work** conducted under written permission with defined scope and rules of engagement.

The methodology draws from established frameworks: the Penetration Testing Execution Standard (PTES), the OWASP Testing Guide, NIST SP 800-115 (Technical Guide to Information Security Testing and Assessment), and the CREST penetration testing guide.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Pentest Planner | `agents/pentest-planner.md` | Engagement scoping, methodology selection, test plan creation, rules of engagement definition, and report structure. Ensures assessments are systematic, legal, and comprehensive. |
| Vuln Researcher | `agents/vuln-researcher.md` | Vulnerability analysis specialist. Analyzes discovered vulnerabilities for exploitability, chains findings into attack paths, assesses real-world impact, and produces risk-rated findings. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/pentest-plan` | `commands/pentest-plan.md` | Generate a structured penetration test plan for a defined target, including methodology, test cases, tools, and timeline. |
| `/attack-surface` | `commands/attack-surface.md` | Map the attack surface of a system or application, identifying entry points, trust boundaries, and high-value targets. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Pentest Methodology | `skills/pentest-methodology/SKILL.md` | Deep reference for PTES phases, OWASP Testing Guide structure, and practical testing patterns organized by technology and vulnerability class. |

## Usage

### Planning an Engagement

Run `/pentest-plan` to generate a structured test plan. Provide the target type (web app, API, network, cloud infrastructure, mobile app) and any known scope constraints. The command produces a comprehensive plan with specific test cases.

### Attack Surface Mapping

Use `/attack-surface` early in an engagement to systematically enumerate all entry points, data flows, trust boundaries, and high-value targets. This drives the prioritization of testing effort.

### Vulnerability Analysis

Activate the `vuln-researcher` agent when you have discovered potential vulnerabilities and need to assess their exploitability, chain them together, or understand their real-world impact. The agent provides CVSS scoring, attack narrative construction, and remediation guidance.

### Full Engagement Support

Use the `pentest-planner` agent throughout an engagement for methodology guidance, scope questions, and report structuring. The agent ensures nothing is missed and findings are communicated effectively to both technical and executive audiences.

## Key Concepts

- **Authorization is mandatory**: No testing without written permission defining scope, methods, timing, and escalation procedures. This is both a legal requirement and a professional standard.
- **Scope discipline**: Stay within defined boundaries. If you discover a vulnerability that could affect out-of-scope systems, document it and report it -- do not test it.
- **Evidence preservation**: Document every finding with sufficient evidence to reproduce it. Screenshots, request/response pairs, timestamps, and step-by-step reproduction instructions.
- **Risk-based prioritization**: Not all vulnerabilities matter equally. Prioritize by actual exploitability in the target environment and business impact of successful exploitation.
- **Attack chains matter more than individual findings**: A medium-severity SSRF chained with a high-severity deserialization bug becomes a critical remote code execution. Always look for chains.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `web-application-security` | Web app pentest is the most common engagement type. This plugin provides the web vulnerability expertise. |
| `api-security-testing` | API testing is a core component of most modern pentests. |
| `vulnerability-scanning` | Automated scanning is a phase within pentesting. This plugin provides scanning methodology. |
| `threat-modeling` | Threat models inform where to focus testing effort. |
| `network-security` | Network-layer testing (port scanning, service enumeration, network-level exploits). |
| `cloud-security-aws` / `cloud-security-azure` / `cloud-security-gcp` | Cloud-specific pentest methodology. |

## Engagement Lifecycle

1. **Pre-engagement** -- Scoping, rules of engagement, legal authorization, emergency contacts, communication channels
2. **Reconnaissance** -- Passive and active information gathering within authorized scope
3. **Vulnerability identification** -- Automated scanning combined with manual testing
4. **Exploitation analysis** -- Assessing exploitability and impact of identified vulnerabilities
5. **Post-exploitation analysis** -- Understanding the impact of successful exploitation (lateral movement, data access, persistence)
6. **Reporting** -- Technical findings, executive summary, risk ratings, remediation guidance, and evidence
7. **Remediation verification** -- Re-testing after fixes are applied to confirm effectiveness
