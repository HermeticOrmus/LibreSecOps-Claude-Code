# /detection-rule

> Create a detection rule for a specific ATT&CK technique or threat behavior, in Sigma format with SIEM-specific translations.

## Trigger

Use when you need to:

- Build a detection rule for a specific ATT&CK technique
- Detect a specific adversary behavior observed in threat intelligence
- Create a rule for a finding from a red team exercise or penetration test
- Add detection for a specific CVE exploitation pattern
- Convert a hunting query into an automated detection

## Input

- **Required**: One of the following:
  - ATT&CK technique ID (e.g., `T1059.001`, `T1003.001`)
  - Description of the behavior to detect (e.g., "detect PowerShell download cradle execution")
  - Log sample showing the malicious activity
- **Optional flag**: `--siem [splunk|elastic|sentinel|qradar]` -- include SIEM-specific translation
- **Optional flag**: `--yara` -- generate a YARA rule instead of (or in addition to) Sigma
- **Optional flag**: `--test` -- include Atomic Red Team test command for validation

## Process

1. **Technique Analysis**: Understand the ATT&CK technique -- what the adversary does, what telemetry it generates, and what the detection surface looks like.

2. **Data Source Identification**: Determine the required data sources:
   - Windows Event IDs (Security, Sysmon, PowerShell, etc.)
   - Linux log sources (auditd, syslog, journald)
   - Network data (DNS, HTTP, NetFlow)
   - Cloud audit logs (CloudTrail, Cloud Audit Logs, Azure Activity Log)

3. **Detection Logic Design**: Build the detection logic:
   - **Selection criteria**: What fields and values identify the malicious behavior?
   - **Filter conditions**: What legitimate activity looks similar and should be excluded?
   - **Aggregation**: Does the detection need counting, grouping, or time windows?
   - **Correlation**: Does the detection need multiple events correlated together?

4. **False Positive Assessment**: Identify known benign activities that will trigger the rule:
   - Administrative tools that produce similar telemetry
   - Legitimate automation that matches the pattern
   - System processes that mimic adversary behavior

5. **Rule Writing**: Write the Sigma rule with proper taxonomy, references, and metadata.

6. **SIEM Translation**: Convert to the target SIEM query language if specified.

7. **Test Plan**: Define how to validate the rule with Atomic Red Team or manual testing.

## Output

```yaml
title: Detect [Technique Name]
id: [generated UUID]
status: experimental
description: |
    Detects [what it detects] which may indicate [ATT&CK technique].
    [Additional context about why this matters.]
references:
    - https://attack.mitre.org/techniques/TXXXX/
    - [additional references]
author: LibreSecOps
date: [today]
tags:
    - attack.[tactic]
    - attack.tXXXX
logsource:
    category: [category]
    product: [product]
    service: [service]
detection:
    selection:
        [detection fields]
    filter_[name]:
        [exclusion fields]
    condition: selection and not filter_[name]
falsepositives:
    - [Known benign scenario 1]
    - [Known benign scenario 2]
level: [severity]

---
# Data Source Requirements
[What telemetry must be enabled]

# SIEM Translation (if --siem specified)
## Splunk SPL
[query]

# Test Validation
## Atomic Red Team
[test command]

## Expected Alert
[what the analyst should see]

# Tuning Guide
[How to adjust for your environment]
```
