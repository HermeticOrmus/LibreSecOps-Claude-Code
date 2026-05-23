# Threat Modeling

> STRIDE methodology, attack trees, MITRE ATT&CK mapping, abuse-case analysis. The discipline of asking "what could go wrong here?" systematically, not ad-hoc.

## Overview

Threat modeling is the security practice with the highest leverage per hour. A 4-hour threat modeling session on a new feature surfaces issues that would otherwise leak through to production and be discovered by an attacker or auditor. This plugin encodes structured methodologies (STRIDE, PASTA, attack trees, MITRE ATT&CK) so the agent reasons about threats systematically.

## Contents

- **Agent**: `threat-modeler` — senior security architect who builds threat models using STRIDE + attack trees + MITRE ATT&CK
- **Command**: `/threat-model` — produces a structured threat model for a feature/system
- **Skill**: reference patterns + STRIDE category mappings + common threat catalogs

## Key capabilities

- **STRIDE methodology**: Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege per data flow
- **Attack tree construction**: root attacker goal → AND/OR decomposition → leaf attack steps with cost/skill estimates
- **MITRE ATT&CK mapping**: identified threats mapped to TTPs for detection planning
- **Abuse case enumeration**: "what could a malicious user/insider/competitor/state actor do?"
- **Risk scoring**: DREAD or CVSS-derived risk per threat
- **Mitigation design**: pair each threat with concrete controls + verification

## When to use

- New feature design (do this BEFORE coding, not after)
- Pre-launch security review
- Post-incident retrospective ("we missed this; build threat-modeling muscle so we don't miss it next time")
- Architecture changes (auth migration, data store migration)
- Compliance audits (SOC 2 + ISO 27001 expect documented threat models)

## When NOT to use

- Bug fixes (overkill)
- Documentation changes
- Trivial UI work without security impact

## Compatibility

- Any tech stack
- Any cloud provider (cloud-specific threats covered in cloud-security-* plugins)
- Compliance frameworks: maps to SOC 2 CC4 (Risk Assessment), ISO 27001 A.6 (Information Security Policies)
