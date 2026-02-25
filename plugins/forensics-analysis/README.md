# Forensics Analysis Plugin

> Plan and conduct digital forensic investigations using sound methodology for evidence collection, preservation, analysis, and reporting.

## Overview

The Forensics Analysis plugin provides the methodology, knowledge, and procedural framework for conducting digital forensic investigations during and after security incidents. Digital forensics is the application of scientific investigation techniques to digital evidence -- extracting facts from data in a way that is systematic, reproducible, and defensible.

**IMPORTANT CONTEXT**: This plugin is intended for **educational purposes and authorized incident response**. It teaches forensic methodology so security practitioners can properly handle evidence during legitimate incident response activities. It is not a tool for conducting unauthorized investigations of individuals or systems. Always ensure proper legal authority before collecting or analyzing digital evidence.

The plugin covers two primary domains: **disk and artifact forensics** (analyzing file systems, logs, registry, browser artifacts, and application data) and **memory forensics** (analyzing volatile memory captures for running processes, network connections, injected code, and encryption keys that exist only in RAM).

Forensic methodology emphasizes the chain of custody above all else. Evidence that cannot be proven to be unaltered is evidence that cannot be trusted. Every procedure in this plugin maintains that standard.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Digital Forensics Examiner | `agents/digital-forensics-examiner.md` | Plans and guides forensic investigations with proper evidence handling. Covers disk imaging, artifact analysis, timeline reconstruction, and reporting. |
| Memory Forensics Analyst | `agents/memory-forensics-analyst.md` | Analyzes volatile memory captures for evidence of malicious activity, including process injection, rootkits, hidden network connections, and credential extraction. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/forensic-plan` | `commands/forensic-plan.md` | Create a forensic investigation plan tailored to the incident type, defining evidence sources, collection priorities, and analysis approach. |
| `/evidence-chain` | `commands/evidence-chain.md` | Document a chain of custody record for collected evidence, ensuring admissibility and integrity. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Forensic Methodology | `skills/forensic-methodology/SKILL.md` | Evidence collection, preservation, analysis, and reporting methodology following NIST SP 800-86 and ISO 27037 standards. |
| Memory Forensics | `skills/memory-forensics/SKILL.md` | Volatility framework reference, process analysis, memory artifact types, and RAM analysis patterns. |

## Usage

### Plan an Investigation

Run `/forensic-plan` at the start of any forensic investigation. The command produces a structured investigation plan with evidence source priorities, collection procedures, and analysis approach tailored to the incident type (malware, data theft, insider threat, account compromise).

### Document Evidence

Use `/evidence-chain` every time evidence is collected, transferred, or analyzed. Maintaining chain of custody from the moment evidence is identified through final reporting is non-negotiable for forensic integrity.

### Conduct Analysis

Activate the `digital-forensics-examiner` agent for guided artifact analysis sessions. The agent walks through relevant evidence sources based on the incident type and helps reconstruct the timeline of events.

### Analyze Memory

The `memory-forensics-analyst` agent guides analysis of memory captures, helping identify malicious processes, injected code, network connections, and other volatile artifacts that exist only in RAM.

## Key Concepts

- **Chain of custody**: The documented, unbroken record of who handled evidence, when, and what they did with it. Without chain of custody, evidence is questionable.
- **Write-blocking**: Evidence media must be accessed in read-only mode during acquisition. Write-blockers (hardware or software) prevent any modification to the original evidence.
- **Forensic imaging**: Creating a bit-for-bit copy of evidence media, including unallocated space, slack space, and deleted files. The image is analyzed; the original is preserved.
- **Timeline analysis**: Reconstructing the sequence of events across multiple evidence sources by correlating timestamps from file system metadata, log entries, registry modifications, and network activity.
- **Volatile evidence**: Data that exists only in running memory (RAM) and is lost when the system is powered off. Collection priority: volatile evidence first, non-volatile evidence second.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `incident-response` | Forensics is a component of incident response. IR determines scope; forensics determines facts. |
| `malware-analysis` | Malware found during forensics requires analysis. The malware analysis plugin covers reverse engineering. |
| `blue-team-detection` | Forensic findings produce IOCs and behavioral patterns that become new detections. |
| `security-automation` | Evidence collection workflows can be partially automated through SOAR integration. |
| `siem-log-management` | SIEM logs are a critical forensic data source. Log integrity and retention policies matter for investigations. |
