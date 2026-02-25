# Security Automation Plugin

> Design, build, and deploy security orchestration, automation, and response (SOAR) workflows that reduce manual toil and accelerate incident response.

## Overview

The Security Automation plugin addresses the operational reality that security teams face: too many alerts, too few analysts, and too many repetitive manual tasks. Security Orchestration, Automation, and Response (SOAR) bridges this gap by automating the predictable parts of security operations -- enrichment, triage, containment, and notification -- so that human analysts can focus on the complex decisions that require judgment.

This plugin covers the full automation spectrum, from simple alert enrichment scripts to complex multi-step orchestration playbooks that coordinate actions across dozens of security tools. The philosophy is progressive automation: start by automating the most repetitive, lowest-risk tasks, build confidence, then gradually automate higher-impact actions.

Automation is not a replacement for human analysts. It is a force multiplier. A well-designed playbook handles the first 80% of an investigation automatically (enrich IOCs, check reputation, gather context, assess severity) and presents the analyst with a decision-ready package for the remaining 20% that requires human judgment.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| SOAR Architect | `agents/soar-architect.md` | Designs security orchestration architectures, selects platforms, and creates automation strategies that integrate with existing security tooling. |
| Automation Builder | `agents/automation-builder.md` | Builds automated response playbooks, writes integration code, and implements the specific automation workflows that the architect designs. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/security-automate` | `commands/security-automate.md` | Automate a specific security workflow by analyzing the manual process and designing an automated equivalent. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| SOAR Patterns | `skills/soar-patterns/SKILL.md` | Playbook design patterns, orchestration architecture, and integration strategies for security automation platforms. |
| Automated Response | `skills/automated-response/SKILL.md` | Automated remediation patterns, containment actions, and the decision framework for when to automate versus when to require human approval. |

## Usage

### Automate a Workflow

Run `/security-automate` with a description of the manual security process you want to automate. The command analyzes the workflow, identifies automation candidates, and produces a playbook design with implementation guidance.

### Design Automation Architecture

Activate the `soar-architect` agent for strategic automation planning. The agent helps evaluate SOAR platforms, design integration architectures, and create an automation roadmap prioritized by time savings and risk reduction.

### Build Playbooks

The `automation-builder` agent handles implementation -- writing playbook definitions, integration scripts, and testing procedures for specific automated workflows.

## Key Concepts

- **Playbook**: A defined sequence of automated and manual steps that handle a specific security scenario (e.g., phishing email response, malware alert triage, user account compromise).
- **Orchestration**: Coordinating actions across multiple security tools through a central automation platform.
- **Enrichment**: Automatically gathering context about an alert (IP reputation, domain WHOIS, user activity history, asset criticality) before an analyst reviews it.
- **Containment**: Automated actions that limit the blast radius of a confirmed threat (isolate endpoint, disable account, block IP, quarantine email).
- **Human-in-the-loop**: Decision points in automated workflows where human approval is required before high-impact actions (blocking a production IP, disabling an executive's account).

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `blue-team-detection` | Detections trigger automated response. The quality of automation depends on detection fidelity. |
| `incident-response` | Automated playbooks execute incident response procedures. SOAR is the automation layer of IR. |
| `siem-log-management` | SIEM provides the alerts that trigger SOAR playbooks. |
| `threat-modeling` | Threat models identify the scenarios that need automated response playbooks. |
| `secrets-management` | Automation workflows need credentials to interact with security tools. Vault integration is essential. |
