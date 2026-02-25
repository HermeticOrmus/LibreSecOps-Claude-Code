# Red Team Operations Plugin

> Plan and structure adversary simulations using MITRE ATT&CK framework alignment -- for authorized, educational, and defensive purposes only.

## Overview

The Red Team Operations plugin provides the methodology and framework knowledge for planning adversary simulations that test an organization's detection and response capabilities. Red teaming is not penetration testing -- penetration testing finds vulnerabilities, while red teaming tests whether the blue team can detect and respond to a realistic adversary operating within the environment.

**CRITICAL DISCLAIMER**: All content in this plugin is intended exclusively for **authorized security testing**, **educational purposes**, and **defensive capability development**. Adversary simulation must only be conducted with explicit written authorization from the system owner, within a defined scope, with rules of engagement, and with safety controls in place. Unauthorized access to computer systems is illegal and unethical regardless of intent.

This plugin draws heavily from the MITRE ATT&CK framework (Enterprise, version 15) for technique cataloging, threat intelligence for adversary profile development, and established red team methodologies (TIBER-EU, CBEST, PTES, Atomic Red Team) for operational structure.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Red Team Lead | `agents/red-team-lead.md` | Plans adversary simulations from scoping through reporting. Develops threat scenarios, defines rules of engagement, and structures operations into phases aligned with real adversary tradecraft. |
| TTP Researcher | `agents/ttp-researcher.md` | Maps threat actor behavior to MITRE ATT&CK tactics, techniques, and procedures. Builds adversary profiles from threat intelligence and designs detection validation scenarios. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/red-team-plan` | `commands/red-team-plan.md` | Create a structured adversary simulation plan with threat scenario, scope, rules of engagement, and phased operation design. |
| `/attack-map` | `commands/attack-map.md` | Map specific threat actor TTPs to MITRE ATT&CK and generate a technique-by-technique detection validation checklist. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| MITRE ATT&CK Framework | `skills/mitre-attack-framework/SKILL.md` | Reference knowledge covering ATT&CK tactics, selected techniques with detection guidance, and framework usage for adversary emulation planning. |
| Adversary Emulation | `skills/adversary-emulation/SKILL.md` | Methodology for building adversary emulation plans based on real threat intelligence, including scenario design and atomic testing patterns. |

## Usage

### Plan an Adversary Simulation

Run `/red-team-plan` to create a structured red team engagement plan. The command walks through threat scenario selection, scope definition, rules of engagement, and phased operation design. Output is a document suitable for stakeholder approval before execution.

### Map Threat Actor TTPs

Use `/attack-map` when you have a specific threat actor or attack pattern in mind and need to map it to MITRE ATT&CK for detection validation. The command produces a technique matrix with detection requirements for each TTP.

### Research Mode

Activate the `ttp-researcher` agent for interactive threat intelligence research sessions. The agent helps build adversary profiles from public threat intelligence reports and maps them to actionable detection engineering requirements.

### Engagement Planning

The `red-team-lead` agent handles the operational planning side -- scoping, rules of engagement, phased execution design, and reporting structure.

## Key Concepts

- **Adversary emulation**: Simulating the specific TTPs of a known threat actor, based on threat intelligence. Different from generic penetration testing.
- **Purple teaming**: Collaborative exercises where red and blue teams work together, with the red team executing TTPs while the blue team observes and improves detection in real time.
- **Atomic testing**: Executing individual ATT&CK techniques in isolation to validate specific detection capabilities, without running a full adversary simulation.
- **Rules of engagement**: The legal and operational boundaries that define what the red team can and cannot do. Non-negotiable.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `blue-team-detection` | Red team operations directly inform detection engineering. Every TTP should have a corresponding detection rule. |
| `penetration-testing` | Penetration testing finds vulnerabilities; red teaming tests detection and response. Different objectives, complementary practices. |
| `threat-modeling` | Threat models identify what adversaries might do; red teams validate whether defenses hold. |
| `incident-response` | Red team exercises test incident response procedures under realistic conditions. |
| `security-automation` | Automated response capabilities are validated through red team exercises. |
