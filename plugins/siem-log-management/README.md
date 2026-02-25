# SIEM & Log Management Plugin

> SIEM architecture design, log source onboarding, detection rule development, and query expertise across Splunk SPL, Elastic KQL, and Azure/Microsoft Sentinel KQL.

## Overview

The SIEM & Log Management plugin provides expertise in designing, implementing, and operating security information and event management systems. It covers the complete lifecycle from log architecture design and source onboarding through detection engineering, alert tuning, and incident investigation using SIEM data.

Effective SIEM operation requires three distinct skill sets: infrastructure (getting the right data in), detection engineering (writing rules that find real threats without drowning in noise), and analysis (using the data to investigate incidents). This plugin addresses all three.

The plugin provides real query syntax for the three dominant SIEM platforms: Splunk (SPL), Elastic Security (KQL/EQL), and Microsoft Sentinel (KQL). It maps detections to the MITRE ATT&CK framework and follows the Sigma rule standard for platform-agnostic detection logic.

SIEM is fundamentally a defensive capability. The detections and queries in this plugin are designed for authorized security monitoring within environments where the analyst has legitimate access and responsibility.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| SIEM Architect | `agents/siem-architect.md` | Log architecture design, source prioritization, retention planning, correlation rule strategy, and capacity planning for SIEM deployments. |
| Log Analyst | `agents/log-analyst.md` | Log analysis, pattern recognition, detection query development, alert triage, and incident investigation using SIEM platforms. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/siem-setup` | `commands/siem-setup.md` | Design a SIEM architecture including log source prioritization, parsing strategy, retention policies, and initial detection rules. |
| `/log-query` | `commands/log-query.md` | Build a detection or investigation query for a specific threat or scenario, with syntax for Splunk SPL, Elastic KQL, or Sentinel KQL. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Log Correlation Patterns | `skills/log-correlation-patterns/SKILL.md` | Patterns for correlating events across log sources to detect multi-stage attacks, lateral movement, and data exfiltration. |
| SIEM Query Languages | `skills/siem-query-languages/SKILL.md` | Reference for Splunk SPL, Elastic KQL/EQL, and Microsoft Sentinel KQL with security-focused query patterns. |

## Usage

### Architecture Design

Run `/siem-setup` when standing up a new SIEM or redesigning an existing deployment. Provide the environment details (cloud/on-prem/hybrid, operating systems, key applications) and the command will produce a prioritized log source list, parsing strategy, and initial detection rules.

### Detection Engineering

Use `/log-query` to build detection rules for specific threats. Specify the threat (MITRE ATT&CK technique, specific attack pattern, or investigation scenario) and your SIEM platform. The command produces tested query syntax with explanation.

### Interactive Analysis

Activate the `log-analyst` agent for investigation sessions. Provide log data, alert details, or investigation hypotheses, and the agent will guide the analysis with appropriate queries and correlation logic.

### Architecture Review

Activate the `siem-architect` agent for ongoing architecture discussions, capacity planning, log source evaluation, and detection strategy development.

## Key Concepts

- **Signal-to-noise ratio**: A SIEM that generates 10,000 alerts per day is not more secure than one generating 100 if the analysts can only investigate 50. Detection quality matters more than quantity.
- **Log source prioritization**: Not all logs are equally valuable. Authentication logs, DNS logs, and endpoint detection logs provide the highest detection value per byte stored.
- **Detection-as-code**: Detection rules should be versioned, tested, reviewed, and deployed through CI/CD pipelines, not manually edited in a SIEM UI.
- **Sigma rules**: Platform-agnostic detection logic that can be converted to Splunk SPL, Elastic KQL, Sentinel KQL, and other formats. Write once, deploy everywhere.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `blue-team-detection` | Detection engineering methodology feeds directly into SIEM rule development. |
| `incident-response` | SIEM is the primary tool for incident detection and investigation. |
| `malware-analysis` | IOCs from malware analysis become SIEM detection rules. |
| `forensics-analysis` | Forensic findings guide SIEM log review and vice versa. |
| `cloud-security-aws/azure/gcp` | Cloud-specific log sources (CloudTrail, Azure Activity Log, GCP Audit Log) are critical SIEM inputs. |

## Methodology

SIEM operations follow a continuous cycle:

1. **Collect** -- Onboard log sources with proper parsing and normalization
2. **Detect** -- Write, test, and deploy detection rules mapped to ATT&CK
3. **Triage** -- Investigate alerts, determine true/false positives, escalate incidents
4. **Tune** -- Reduce false positives, improve detection fidelity, add context enrichment
5. **Hunt** -- Proactively search for threats not covered by existing detections
6. **Report** -- Measure detection coverage, mean time to detect/respond, and rule effectiveness
