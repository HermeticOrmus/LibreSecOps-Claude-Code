# Incident Response Plugin

> Structured incident response coordination, forensic analysis guidance, playbook execution, and post-incident review for security incidents.

## Overview

The Incident Response plugin provides Claude Code with the methodology, playbooks, and analytical frameworks needed to support security incident handling from detection through resolution and post-incident review. It covers the NIST SP 800-61 incident response lifecycle: Preparation, Detection & Analysis, Containment/Eradication/Recovery, and Post-Incident Activity.

Security incidents are high-pressure, time-critical situations where clear thinking and structured process prevent mistakes that make things worse. This plugin provides the calm, systematic framework that keeps responders focused on the right priorities: protect life and safety, contain the damage, preserve evidence, eradicate the threat, recover operations, and learn from the experience.

This plugin does not replace a formal incident response plan. It augments human responders with structured guidance, playbook templates, evidence collection checklists, and post-incident review frameworks. All actual containment actions, legal decisions, and external communications must be made by authorized human personnel.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Incident Commander | `agents/incident-commander.md` | IR coordination specialist. Manages the incident lifecycle, assigns roles, tracks actions, coordinates communications, and ensures nothing falls through the cracks. |
| Forensic Analyst | `agents/forensic-analyst.md` | Digital forensics and evidence specialist. Guides evidence collection, preservation, and analysis following forensically sound practices that maintain chain of custody. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/incident-response` | `commands/incident-response.md` | Activate an incident response playbook for a reported security event. Guides through triage, containment, and initial response steps. |
| `/incident-postmortem` | `commands/incident-postmortem.md` | Generate a structured post-incident review (blameless postmortem) from incident timeline and actions taken. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| IR Playbooks | `skills/ir-playbooks/SKILL.md` | Incident response playbook templates for common incident types: malware, data breach, account compromise, DDoS, ransomware, insider threat, and supply chain compromise. |

## Usage

### Active Incident

When a security incident is detected or reported, run `/incident-response` to activate the appropriate playbook. Describe the indicators (what was observed, when, where) and the command will guide you through triage, severity classification, containment options, and initial response steps.

### Ongoing Incident Support

Activate the `incident-commander` agent for sustained incident management. The agent helps track actions, coordinate roles, manage communications, and ensure the response follows a structured process even under time pressure.

### Evidence Collection

Use the `forensic-analyst` agent when collecting and analyzing evidence. The agent provides guidance on forensically sound evidence collection, chain of custody documentation, and analysis techniques for logs, memory, disk images, and network captures.

### Post-Incident Review

After the incident is resolved, run `/incident-postmortem` to generate a structured blameless postmortem. Provide the timeline, actions taken, and outcomes, and the command produces a review document with root cause analysis, lessons learned, and action items.

## Key Concepts

- **The first priority is containment, not investigation**: Stop the bleeding before analyzing the wound. Contain the incident to prevent further damage, then investigate.
- **Evidence preservation requires planning**: Once you start containment (shutting down services, resetting credentials, blocking IPs), some evidence may be lost. Plan evidence collection before taking containment actions when possible.
- **Chain of custody matters**: If the incident may result in legal proceedings, evidence handling must follow forensic standards. Document who collected what, when, how, and where it was stored.
- **Blameless postmortems**: The goal of post-incident review is to improve systems and processes, not to assign blame. People make mistakes; the question is why the system allowed the mistake to cause an incident.
- **Runbooks are starting points**: No playbook covers every scenario perfectly. Adapt the playbook to the situation, but don't abandon structure entirely.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `threat-modeling` | Threat models predict incident scenarios. Use them to build playbooks before incidents occur. |
| `forensics-analysis` | Deep forensic analysis capabilities for complex investigations. |
| `security-hardening` | Post-incident hardening prevents recurrence. |
| `siem-log-management` | Log analysis is fundamental to incident detection and investigation. |
| `blue-team-detection` | Detection capabilities that trigger incident response. |
| `compliance-frameworks` | Many frameworks require incident response plans and breach notification. |

## NIST SP 800-61 Lifecycle

1. **Preparation** -- IR plan, team, tools, communication channels, playbooks, training
2. **Detection & Analysis** -- Identify indicators, triage, classify severity, determine scope
3. **Containment, Eradication, Recovery** -- Stop the spread, remove the threat, restore operations
4. **Post-Incident Activity** -- Lessons learned, process improvements, evidence retention
