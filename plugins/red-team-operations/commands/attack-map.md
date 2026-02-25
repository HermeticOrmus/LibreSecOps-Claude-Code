# /attack-map

> Map threat actor TTPs to MITRE ATT&CK techniques and generate a detection validation checklist.

## Trigger

Use when you need to:

- Map a known threat actor's behavior to ATT&CK for detection engineering
- Analyze a threat intelligence report and extract actionable TTPs
- Build a detection validation matrix for a specific adversary profile
- Prepare atomic testing scenarios for blue team capability validation
- Create an ATT&CK Navigator layer for a specific threat

**NOTE**: This command is for educational and defensive purposes -- building detections that catch these techniques.

## Input

- **Required**: One of the following:
  - A threat actor name or designation (e.g., "APT29", "FIN7", "Scattered Spider")
  - A threat intelligence report or advisory to analyze
  - A specific attack pattern or kill chain to map
- **Optional flag**: `--detection` -- include detection rule stubs (Sigma format) for each technique
- **Optional flag**: `--atomic` -- include Atomic Red Team test IDs for validation
- **Optional flag**: `--navigator` -- output ATT&CK Navigator JSON layer

## Process

1. **Threat Intelligence Gathering**: Collect publicly available intelligence on the specified threat actor or attack pattern from MITRE CTI, vendor reports, and CISA advisories.

2. **TTP Extraction**: Identify each tactic, technique, and procedure used by the adversary. Be specific -- extract sub-techniques (T1059.001 PowerShell, not just T1059 Command and Scripting Interpreter).

3. **ATT&CK Mapping**: Map each TTP to the MITRE ATT&CK Enterprise matrix with:
   - Technique ID and name
   - The specific procedure (how the adversary uses this technique)
   - The tactic phase (where in the kill chain this occurs)
   - Confidence level (observed / assessed / inferred)

4. **Detection Requirements**: For each technique, identify:
   - Required data sources (Sysmon events, Windows Event Log IDs, network flow data, cloud audit logs)
   - Detection logic (what pattern indicates this technique)
   - False positive considerations
   - Detection difficulty rating

5. **Atomic Test Mapping** (with `--atomic`): Map each technique to the corresponding Atomic Red Team test for safe validation.

6. **Detection Rule Generation** (with `--detection`): Generate Sigma rule stubs for each technique that can be deployed to SIEM platforms.

7. **Navigator Layer** (with `--navigator`): Generate a JSON layer file for the ATT&CK Navigator visualization tool.

## Output

```
# ATT&CK Mapping: [Threat Actor / Attack Pattern]

## Intelligence Sources
- [Source 1: Title, Date, URL]
- [Source 2: Title, Date, URL]

## TTP Matrix

### Initial Access
| ID | Technique | Procedure | Confidence | Data Source | Detection |
|----|-----------|-----------|------------|-------------|-----------|
| T1566.001 | Spearphishing Attachment | Sends macro-enabled .docm files themed as invoices | Observed | Email logs, Sysmon EID 1 | Office process spawning cmd/powershell |
| T1078.004 | Cloud Accounts | Compromised OAuth tokens from phishing | Observed | Azure AD sign-in logs | Impossible travel, new device sign-in |

### Execution
[Same table format]

### Persistence
[Same table format]

[...all applicable tactics...]

## Detection Coverage Assessment
| Status | Count | Techniques |
|--------|-------|------------|
| Detected (rule exists) | X | T1566.001, T1059.001, ... |
| Partially detected | X | T1078.004, ... |
| Not detected | X | T1055.001, ... |

## Priority Detection Gaps
1. [Technique with no detection + high usage frequency]
2. [Technique with partial detection + high impact]
3. [...]

## Atomic Red Team Validation (--atomic)
| Technique | Test ID | Command | Expected Detection |
|-----------|---------|---------|-------------------|
| T1059.001 | T1059.001-1 | `powershell -enc [base64]` | Sysmon EID 1 + ScriptBlock 4104 |

## Sigma Rule Stubs (--detection)
[Sigma YAML for each detection gap]

## ATT&CK Navigator Layer (--navigator)
[JSON output for import into ATT&CK Navigator]
```
