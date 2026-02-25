# Privacy Engineering Plugin

> Privacy-by-design implementation, data protection impact assessments, data flow mapping, and technical privacy controls for regulatory compliance and ethical data handling.

## Overview

The Privacy Engineering plugin brings privacy expertise into the development lifecycle. Privacy is not a legal checkbox -- it is an engineering discipline that requires specific technical patterns, architectural decisions, and design principles applied from the earliest stages of system design.

This plugin covers the practical implementation side of privacy: how to minimize data collection, how to implement anonymization and pseudonymization correctly, how to map and control personal data flows, and how to design systems that respect user autonomy by default. It is grounded in the seven foundational principles of Privacy by Design (Ann Cavoukian), GDPR technical requirements, and the NIST Privacy Framework.

The plugin operates on a core principle: privacy and functionality are not in conflict. Systems that respect privacy are better engineered -- they have cleaner data flows, more intentional data handling, and more predictable behavior. Privacy constraints force better architecture.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Privacy Engineer | `agents/privacy-engineer.md` | Privacy-by-design specialist who reviews architectures and code for privacy implications, recommends data minimization strategies, and implements technical privacy controls. |
| DPIA Analyst | `agents/dpia-analyst.md` | Data Protection Impact Assessment specialist who guides organizations through structured privacy risk assessment for high-risk processing activities. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/privacy-review` | `commands/privacy-review.md` | Review a system, feature, or architecture for privacy concerns, producing a structured assessment with findings and recommendations. |
| `/data-flow-map` | `commands/data-flow-map.md` | Map personal data flows through a system, identifying collection points, processing activities, storage locations, sharing partners, and retention periods. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Privacy by Design | `skills/privacy-by-design/SKILL.md` | The seven foundational principles of Privacy by Design with practical implementation patterns for each. |
| Data Protection Patterns | `skills/data-protection-patterns/SKILL.md` | Technical patterns for anonymization, pseudonymization, encryption, data minimization, and consent management. |

## Usage

### Privacy Review

Run `/privacy-review` on any system design, feature specification, or code to get a structured privacy assessment. The command identifies personal data processing, evaluates privacy risks, and recommends specific technical controls.

### Data Flow Mapping

Use `/data-flow-map` to create a comprehensive map of how personal data moves through a system. This is essential for GDPR Article 30 Records of Processing Activities and for identifying privacy risks.

### Architecture Guidance

Activate the `privacy-engineer` agent for interactive privacy-by-design sessions during architecture and feature design. The agent asks probing questions about data collection, purpose, retention, and sharing to identify privacy issues before code is written.

### DPIA Guidance

Use the `dpia-analyst` agent when a Data Protection Impact Assessment is required (GDPR Article 35). The agent guides through the complete DPIA process, from threshold assessment through risk identification to mitigation planning.

## Key Concepts

- **Data minimization**: Collect only what is necessary for the stated purpose. If you do not need it, do not collect it. If you no longer need it, delete it.
- **Purpose limitation**: Personal data collected for one purpose must not be used for an incompatible purpose without additional consent or legal basis.
- **Privacy by default**: The most privacy-protective settings should be the defaults. Users should not need to opt out of data collection; they should opt in.
- **Anonymization vs pseudonymization**: Anonymization is irreversible and removes data from GDPR scope. Pseudonymization is reversible (by the data controller) and data remains in scope but with reduced risk.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `compliance-frameworks` | Privacy engineering implements the technical requirements of privacy regulations covered in compliance. |
| `secure-coding-practices` | Secure coding and privacy engineering overlap in data handling, encryption, and access control. |
| `cryptography-essentials` | Encryption, hashing, and anonymization techniques require solid cryptographic foundations. |
| `threat-modeling` | Privacy threat modeling (LINDDUN methodology) extends security threat modeling. |
| `identity-access-management` | IAM controls enforce the access restrictions privacy engineering requires. |

## Methodology

Privacy engineering follows the Privacy by Design lifecycle:

1. **Assessment** -- Identify personal data processing activities and their purposes
2. **Design** -- Apply privacy-by-design principles to system architecture
3. **Implementation** -- Build technical controls (encryption, anonymization, access control, consent management)
4. **Verification** -- Test privacy controls, conduct DPIAs, verify data flows match documentation
5. **Operation** -- Monitor data processing, handle data subject requests, manage retention
6. **Review** -- Regularly reassess privacy posture as systems and regulations evolve
