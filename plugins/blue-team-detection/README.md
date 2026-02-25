# Blue Team Detection Plugin

> Build, deploy, and maintain detection rules and threat hunting capabilities that catch adversary behavior across the kill chain.

## Overview

The Blue Team Detection plugin covers the two core disciplines of defensive security operations: **detection engineering** (building automated rules that trigger on adversary behavior) and **threat hunting** (proactively searching for threats that automated detections miss). Together, these disciplines form the detection and response backbone of any security operations center (SOC).

Detection engineering has evolved from ad-hoc SIEM correlation rules into a disciplined practice with version-controlled rules, testing pipelines, and detection-as-code workflows. This plugin embraces that evolution. Rules are written in Sigma (the universal detection format), tested against known-good and known-bad data, and deployed through automated pipelines -- the same rigor applied to application code.

Threat hunting complements automated detection by using human intuition and analytical reasoning to find threats that rules miss. Hunts are hypothesis-driven investigations that start with a question ("Is there evidence of LSASS credential dumping in our environment?") and use structured analysis to find the answer.

This plugin directly complements the `red-team-operations` plugin. Every TTP the red team uses should have a corresponding detection. Every detection gap the red team finds becomes a detection engineering priority.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Detection Engineer | `agents/detection-engineer.md` | Writes SIEM detection rules, Sigma rules, YARA rules, and detection-as-code pipelines. Translates ATT&CK techniques into deployable detection logic. |
| Threat Hunter | `agents/threat-hunter.md` | Designs and executes hypothesis-driven threat hunts. Analyzes log data, identifies anomalies, and develops new detections from hunt findings. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/detection-rule` | `commands/detection-rule.md` | Create a detection rule for a specific ATT&CK technique or threat behavior, in Sigma format with SIEM-specific translations. |
| `/hunt-hypothesis` | `commands/hunt-hypothesis.md` | Generate a structured threat hunting hypothesis with data sources, analysis approach, and expected indicators. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Detection Engineering | `skills/detection-engineering/SKILL.md` | Sigma rule syntax, YARA rule writing, detection-as-code workflows, and the methodology of building reliable detections. |
| Threat Hunting Methodology | `skills/threat-hunting-methodology/SKILL.md` | Hypothesis-driven hunting framework, data analysis techniques, and hunt documentation patterns. |

## Usage

### Build a Detection

Run `/detection-rule` with a specific ATT&CK technique ID (e.g., `/detection-rule T1059.001`) to generate a Sigma rule with the detection logic, required data sources, false positive considerations, and SIEM-specific translations (Splunk SPL, Elastic KQL, Microsoft Sentinel KQL).

### Start a Hunt

Run `/hunt-hypothesis` with a focus area (e.g., `/hunt-hypothesis credential-access`) to generate a structured hunting hypothesis with the data sources to query, the analysis approach, and the indicators to look for.

### Detection-as-Code

Activate the `detection-engineer` agent for interactive sessions building detection pipelines, testing rules against sample data, and managing detection rule repositories.

### Proactive Hunting

The `threat-hunter` agent guides structured hunting sessions, helping analyze log data, identify anomalies, and develop new automated detections from successful hunts.

## Key Concepts

- **Sigma**: The universal detection rule format. Write once, translate to any SIEM (Splunk, Elastic, Sentinel, QRadar, etc.). Sigma rules are the unit of detection engineering.
- **YARA**: Pattern matching rules for file and memory scanning. Used for malware detection, threat hunting on disk/memory, and incident response triage.
- **Detection-as-code**: Version-controlled detection rules with CI/CD pipelines that test, validate, and deploy rules automatically.
- **Hypothesis-driven hunting**: Structured hunts that start with a testable hypothesis, use defined data sources, and produce actionable results regardless of whether the hypothesis is confirmed or not.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `red-team-operations` | Red team TTPs are the input for detection engineering. Every technique should have a corresponding detection. |
| `siem-log-management` | SIEM is the platform where detection rules execute. Log management provides the data. |
| `incident-response` | Detections trigger incident response. The quality of detection directly impacts response speed and accuracy. |
| `security-automation` | Automated response (SOAR) is triggered by detections. |
| `forensics-analysis` | Forensic analysis produces indicators that become new detections. |
| `threat-modeling` | Threat models identify what to detect. Detection engineering builds the rules. |
