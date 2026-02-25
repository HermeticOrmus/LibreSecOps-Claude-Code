# /log-query

> Build a detection or investigation query for a specific threat or scenario, with syntax for Splunk SPL, Elastic KQL, or Microsoft Sentinel KQL.

## Trigger

Use when you need to:
- Write a detection rule for a specific MITRE ATT&CK technique
- Build an investigation query for an active incident
- Convert a Sigma rule to a specific platform syntax
- Create a threat hunting query
- Tune an existing detection rule to reduce false positives

## Input

- **Threat/scenario**: What to detect or investigate. Can be:
  - MITRE ATT&CK technique ID (e.g., "T1059.001 - PowerShell")
  - Specific attack pattern (e.g., "DCSync attack detection")
  - Investigation scenario (e.g., "trace lateral movement from compromised host")
  - IOC search (e.g., "find all connections to this IP across last 30 days")
  - Sigma rule to convert
- **Platform**: Splunk SPL, Elastic KQL/EQL, Microsoft Sentinel KQL, or Sigma (all platforms)
- **Available log sources**: What data is indexed (Sysmon, Windows Security, CloudTrail, etc.)
- **Tuning context** (optional): Known false positive sources to exclude, environment-specific filters

## Process

1. **Requirement analysis** -- Understand what needs to be detected and the available data sources. Map the threat to specific observable events.

2. **Log source identification** -- Determine which log sources contain the events needed for detection:
   - Process creation: Sysmon Event ID 1, Windows 4688, EDR process logs
   - Network connections: Sysmon Event ID 3, firewall logs, proxy logs, Zeek conn.log
   - Authentication: Windows 4624/4625, Okta system logs, Azure AD sign-in logs
   - File operations: Sysmon Event IDs 11/15/23, auditd, EDR file logs
   - Registry: Sysmon Event IDs 12/13/14, Windows Security logs
   - DNS: Sysmon Event ID 22, DNS server query logs, Zeek dns.log
   - Cloud: CloudTrail, Azure Activity, GCP Audit

3. **Query construction** -- Build the query with:
   - Core detection logic (the pattern that identifies the threat)
   - Context enrichment (user, host, process details for triage)
   - False positive filtering (known-good patterns excluded)
   - Performance optimization (indexed fields, efficient operators)

4. **Testing guidance** -- Provide test methodology:
   - Atomic Red Team test ID (if applicable)
   - Manual test procedure
   - Expected results when the detection fires
   - Verification of false positive filters

5. **Multi-platform output** -- If Sigma format requested, provide the Sigma YAML and conversions for all platforms.

## Output

```
## Detection Query: [Name]

### Threat
**ATT&CK**: [T####.### - Name]
**Description**: [What this detects]
**Log source required**: [specific sources]

### Splunk SPL
```spl
index=windows sourcetype=WinEventLog:Security EventCode=4688
| where NewProcessName LIKE "%\\powershell.exe"
  AND CommandLine LIKE "%-enc%"
| stats count by _time, ComputerName, SubjectUserName, NewProcessName, CommandLine, ParentProcessName
| where count > 0
```

### Elastic KQL
```kql
process.name: "powershell.exe" AND process.command_line: *-enc*
```

### Microsoft Sentinel KQL
```kql
SecurityEvent
| where EventID == 4688
| where NewProcessName endswith "\\powershell.exe"
| where CommandLine contains "-enc"
| project TimeGenerated, Computer, Account, NewProcessName, CommandLine, ParentProcessName
```

### Sigma Rule
```yaml
title: [Detection name]
id: [UUID]
status: [test/stable]
level: [critical/high/medium/low]
description: [what it detects]
references:
  - [ATT&CK link]
logsource:
  category: [process_creation/etc]
  product: [windows/linux]
detection:
  selection:
    field: value
  condition: selection
falsepositives:
  - [known FP]
tags:
  - attack.execution
  - attack.t1059.001
```

### False Positives
- [Known benign patterns and how to filter them]

### Tuning
[Environment-specific adjustments]

### Testing
**Atomic Red Team**: [Test ID if applicable]
**Manual test**: [Steps to trigger the detection]
```
