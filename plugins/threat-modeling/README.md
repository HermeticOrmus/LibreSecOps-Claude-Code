# Threat Modeling Plugin

> Systematic threat identification and analysis using STRIDE, PASTA, and attack tree methodologies to design security into systems before vulnerabilities are introduced.

## Overview

The Threat Modeling plugin equips Claude Code with structured methodologies for identifying, categorizing, and prioritizing threats to software systems. Threat modeling is the practice of thinking about what could go wrong before building or deploying a system -- it is the most cost-effective security activity because it catches design-level flaws that are orders of magnitude cheaper to fix before code is written than after.

This plugin supports multiple threat modeling frameworks. STRIDE (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege) is the primary methodology, with PASTA (Process for Attack Simulation and Threat Analysis) available for risk-centric analysis and attack trees for detailed attack path decomposition.

Threat models are living documents. They should be created during design, updated during development, and reviewed after deployment. This plugin supports all three phases.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Threat Modeler | `agents/threat-modeler.md` | STRIDE/PASTA methodology specialist. Analyzes system architectures, identifies threats, and produces structured threat models with mitigations. |
| Attack Tree Builder | `agents/attack-tree-builder.md` | Attack path analysis specialist. Constructs attack trees showing all paths to a given security objective, with cost/skill/detection annotations. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/threat-model` | `commands/threat-model.md` | Generate a complete threat model for a described or implemented system, using STRIDE methodology with prioritized threats and mitigations. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| STRIDE Methodology | `skills/stride-methodology/SKILL.md` | Detailed STRIDE analysis patterns with threat catalogs for common architectural components (web apps, APIs, databases, message queues, cloud services). |
| Attack Trees | `skills/attack-trees/SKILL.md` | Attack tree construction methodology, notation, common patterns, and analysis techniques for decomposing complex threats into actionable attack paths. |

## Usage

### Quick Threat Model

Run `/threat-model` and describe the system you're building or reviewing. Provide the architecture (components, data flows, trust boundaries) and the command produces a structured STRIDE-based threat model with prioritized threats and recommended mitigations.

### Detailed Attack Path Analysis

Use the `attack-tree-builder` agent when you need to understand all possible paths to a specific security outcome (e.g., "How could an attacker steal customer payment data?" or "What are all the paths to admin access?"). The agent produces annotated attack trees with cost, skill, and detection assessments for each path.

### Design Phase Modeling

Activate the `threat-modeler` agent during system design sessions. Describe your planned architecture and the agent will identify threats at each component and data flow, helping you build security controls into the design rather than bolting them on afterward.

## Key Concepts

- **Threat modeling is a design activity, not a testing activity**: It identifies what COULD go wrong, not what IS wrong. Testing validates that mitigations work. Threat modeling decides what mitigations are needed.
- **Data Flow Diagrams (DFDs) are the foundation**: A threat model is built on top of a DFD showing processes, data stores, data flows, external entities, and trust boundaries. No DFD, no effective threat model.
- **Not all threats need mitigations**: Some threats have low likelihood, low impact, or are accepted risks. The output of threat modeling is a prioritized list, not a mandate to fix everything.
- **Threats change as systems change**: Adding a new feature, changing a data flow, or integrating a new service introduces new threats. Threat models must be maintained.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `penetration-testing` | Threat models identify where to focus penetration testing effort. |
| `web-application-security` | Web-specific threats are detailed in this plugin's OWASP knowledge base. |
| `api-security-testing` | API-specific threats and mitigations. |
| `security-hardening` | Mitigations identified in threat models are implemented through hardening. |
| `incident-response` | Threat models inform incident response planning -- what scenarios to prepare for. |
| `compliance-frameworks` | Some compliance frameworks (e.g., PCI DSS, NIST CSF) require threat modeling. |

## When to Threat Model

| Trigger | Type of Model |
|---------|--------------|
| New system or service | Full STRIDE analysis |
| New feature with data flow changes | Incremental STRIDE on affected components |
| Architecture change | Review existing model, update DFD, re-analyze |
| Pre-penetration test | Attack tree for specific objectives |
| Incident post-mortem | Retrospective model -- what threats were missed? |
| Compliance requirement | Full model to framework requirements |
