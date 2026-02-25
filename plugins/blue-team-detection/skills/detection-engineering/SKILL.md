# Detection Engineering

> Sigma rule syntax, YARA rule writing, detection-as-code workflows, and the methodology of building reliable, maintainable detection rules.

## Knowledge Base

### The Detection Engineering Lifecycle

```
Threat Intelligence --> Technique Analysis --> Rule Writing --> Testing
         |                                                        |
         v                                                        v
    ATT&CK Mapping --> Data Source Validation --> Deployment --> Tuning
                                                                  |
                                                                  v
                                                  Monitoring --> Retirement
```

Detection rules are not write-once artifacts. They require ongoing tuning, testing, and retirement as adversary behavior evolves and environments change.

### Detection Quality Metrics

| Metric | Definition | Target |
|--------|-----------|--------|
| True Positive Rate | Alerts that are actual threats | > 80% for high-fidelity rules |
| False Positive Rate | Alerts that are benign | < 20% (ideally < 5%) |
| Mean Time to Detect (MTTD) | Time from adversary action to alert | < 15 minutes |
| Detection Coverage | % of ATT&CK techniques with detections | Context-dependent |
| Rule Stability | Rules that do not require monthly tuning | > 90% |

## Patterns

### Pattern 1: Sigma Rule Syntax Reference

```yaml
# Complete Sigma rule example: Detecting LSASS Memory Access
title: LSASS Memory Access by Non-System Process
id: 0d894093-71bc-43c3-8985-a9f63f0c7a76
status: stable
description: |
    Detects process access to LSASS memory which is typically used by
    credential dumping tools like Mimikatz. This rule monitors Sysmon
    EventID 10 (ProcessAccess) targeting lsass.exe.
references:
    - https://attack.mitre.org/techniques/T1003/001/
    - https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T1003.001/T1003.001.md
author: LibreSecOps Detection Engineering
date: 2024/01/15
modified: 2024/06/20
tags:
    - attack.credential_access
    - attack.t1003.001
logsource:
    category: process_access
    product: windows
detection:
    selection:
        TargetImage|endswith: '\lsass.exe'
        GrantedAccess|contains:
            - '0x1010'    # PROCESS_VM_READ | PROCESS_QUERY_INFORMATION
            - '0x1410'    # PROCESS_VM_READ | PROCESS_QUERY_LIMITED_INFORMATION
            - '0x1038'    # PROCESS_VM_READ | PROCESS_VM_WRITE | PROCESS_VM_OPERATION
            - '0x40'      # PROCESS_DUP_HANDLE
            - '0x1fffff'  # PROCESS_ALL_ACCESS
    filter_system:
        SourceImage|startswith:
            - 'C:\Windows\System32\'
            - 'C:\Windows\SysWOW64\'
    filter_av:
        SourceImage|contains:
            - '\MsMpEng.exe'         # Windows Defender
            - '\csfalconservice.exe' # CrowdStrike
            - '\cb.exe'              # Carbon Black
    filter_lsass_self:
        SourceImage|endswith: '\lsass.exe'
    condition: selection and not (filter_system or filter_av or filter_lsass_self)
falsepositives:
    - Legitimate security tools performing credential management
    - Windows Credential Manager operations
    - Some backup solutions that access LSASS
level: high
```

### Pattern 2: Sigma Rule Modifiers Reference

```yaml
# Field modifiers available in Sigma
detection:
    # String matching
    field|contains: 'substring'         # Case-insensitive substring
    field|startswith: 'prefix'          # Starts with
    field|endswith: 'suffix'            # Ends with
    field|contains|all:                 # All substrings must be present
        - 'str1'
        - 'str2'
    field|re: 'regex_pattern'           # Regular expression

    # Base64 detection (matches string in any base64 encoding)
    field|base64offset|contains: 'plaintext_string'

    # Numeric
    field|gt: 100                       # Greater than
    field|gte: 100                      # Greater than or equal
    field|lt: 50                        # Less than
    field|lte: 50                       # Less than or equal

    # List matching
    field:
        - 'value1'                      # OR (any match)
        - 'value2'
    field|all:                          # AND (all must match)
        - 'value1'
        - 'value2'

    # Negation (in condition, not modifier)
    condition: selection and not filter

    # Aggregation
    condition: selection | count(SourceIP) by TargetHost > 100
    # Timeframe (requires aggregation)
    timeframe: 5m
```

### Pattern 3: YARA Rule Writing

```yara
rule Mimikatz_Memory_Indicators
{
    meta:
        description = "Detects Mimikatz credential dumping tool in memory"
        author = "LibreSecOps"
        reference = "https://attack.mitre.org/techniques/T1003/001/"
        date = "2024-01-15"
        severity = "critical"
        tlp = "white"

    strings:
        // Known Mimikatz strings
        $s1 = "mimikatz" ascii wide nocase
        $s2 = "gentilkiwi" ascii wide
        $s3 = "sekurlsa" ascii wide

        // Mimikatz module names
        $m1 = "sekurlsa::logonpasswords" ascii wide
        $m2 = "sekurlsa::wdigest" ascii wide
        $m3 = "lsadump::sam" ascii wide
        $m4 = "kerberos::golden" ascii wide

        // Internal function patterns
        $f1 = { 48 8B 05 ?? ?? ?? ?? 48 85 C0 74 ?? 48 8D 0D }
        $f2 = "Primary" wide
        $f3 = "Credman" wide
        $f4 = "Wdigest" wide

    condition:
        uint16(0) == 0x5A4D and  // MZ header (PE file)
        (
            any of ($s*) or
            2 of ($m*) or
            (any of ($f*) and filesize < 5MB)
        )
}

rule Suspicious_PowerShell_Download_Cradle
{
    meta:
        description = "Detects PowerShell download cradle patterns in scripts"
        author = "LibreSecOps"
        reference = "https://attack.mitre.org/techniques/T1059/001/"
        date = "2024-01-15"

    strings:
        $d1 = "DownloadString" ascii wide nocase
        $d2 = "DownloadFile" ascii wide nocase
        $d3 = "DownloadData" ascii wide nocase
        $d4 = "Net.WebClient" ascii wide nocase
        $d5 = "Invoke-WebRequest" ascii wide nocase
        $d6 = "wget" ascii wide nocase
        $d7 = "curl" ascii wide nocase
        $d8 = "Start-BitsTransfer" ascii wide nocase

        $e1 = "Invoke-Expression" ascii wide nocase
        $e2 = "IEX" ascii wide
        $e3 = "-enc" ascii wide nocase
        $e4 = "-encodedcommand" ascii wide nocase

    condition:
        any of ($d*) and any of ($e*)
}
```

### Pattern 4: Detection-as-Code CI/CD Pipeline

```yaml
# .github/workflows/detection-pipeline.yml
name: Detection Rule Pipeline
on:
  pull_request:
    paths:
      - 'detections/**/*.yml'
      - 'detections/**/*.yar'
  push:
    branches: [main]
    paths:
      - 'detections/**/*.yml'
      - 'detections/**/*.yar'

jobs:
  validate-sigma:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install sigma-cli
        run: pip install sigma-cli pySigma-backend-splunk pySigma-backend-elasticsearch

      - name: Validate Sigma rules
        run: |
          for rule in detections/sigma/*.yml; do
            echo "Validating: $rule"
            sigma check "$rule" || exit 1
          done

      - name: Convert to Splunk SPL
        run: |
          for rule in detections/sigma/*.yml; do
            sigma convert -t splunk -p sysmon "$rule" > \
              "detections/compiled/splunk/$(basename $rule .yml).spl"
          done

      - name: Convert to Elastic KQL
        run: |
          for rule in detections/sigma/*.yml; do
            sigma convert -t elasticsearch "$rule" > \
              "detections/compiled/elastic/$(basename $rule .yml).json"
          done

  validate-yara:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install YARA
        run: sudo apt-get install -y yara
      - name: Compile YARA rules
        run: |
          for rule in detections/yara/*.yar; do
            echo "Compiling: $rule"
            yara -w "$rule" /dev/null || exit 1
          done

  test-detections:
    needs: [validate-sigma, validate-yara]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run detection tests
        run: |
          # Test rules against known-good and known-bad log samples
          python tests/test_detections.py \
            --rules detections/sigma/ \
            --true-positives tests/samples/malicious/ \
            --true-negatives tests/samples/benign/

  deploy:
    needs: [test-detections]
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to SIEM
        run: |
          # Deploy compiled rules to SIEM via API
          python scripts/deploy-rules.py \
            --target splunk \
            --rules detections/compiled/splunk/
```

### Pattern 5: Essential Windows Detection Rules

The most impactful detections for Windows environments:

```yaml
# 1. Suspicious process creation chain
title: Office Application Spawning Shell
logsource:
    category: process_creation
    product: windows
detection:
    selection:
        ParentImage|endswith:
            - '\WINWORD.EXE'
            - '\EXCEL.EXE'
            - '\POWERPNT.EXE'
            - '\OUTLOOK.EXE'
        Image|endswith:
            - '\cmd.exe'
            - '\powershell.exe'
            - '\wscript.exe'
            - '\cscript.exe'
            - '\mshta.exe'
    condition: selection
level: high
tags:
    - attack.execution
    - attack.t1059

---
# 2. Service installation (potential persistence/lateral movement)
title: Suspicious Service Installation
logsource:
    product: windows
    service: system
detection:
    selection:
        EventID: 7045  # New service installed
    filter_normal:
        ServiceFileName|contains:
            - 'C:\Windows\'
            - 'C:\Program Files\'
    filter_names:
        ServiceName:
            - 'WinDefend'
            - 'BITS'
    condition: selection and not (filter_normal or filter_names)
level: medium
tags:
    - attack.persistence
    - attack.t1543.003

---
# 3. Encoded PowerShell execution
title: Encoded PowerShell Command Execution
logsource:
    category: process_creation
    product: windows
detection:
    selection:
        Image|endswith: '\powershell.exe'
        CommandLine|contains:
            - '-enc '
            - '-encodedcommand '
            - '-e '
            - '-ec '
    filter_short:
        CommandLine|re: '-e(nc|c|ncodedcommand)?\s+[A-Za-z0-9+/=]{1,50}$'
        # Short encoded strings are less suspicious
    condition: selection and not filter_short
level: high
tags:
    - attack.execution
    - attack.t1059.001
```

## Anti-Patterns

- **Detecting on tool names, not behaviors**: Looking for "mimikatz.exe" catches only the laziest adversaries. Detect the behavior (LSASS access) not the tool name. Adversaries rename their tools.
- **No false positive documentation**: A rule without documented false positives is untested. Every rule should list known benign triggers and how analysts should distinguish them.
- **Monolithic detection rules**: A single rule that tries to detect an entire attack chain is fragile and hard to maintain. Write atomic rules that detect individual techniques, then correlate.
- **Rules without ATT&CK mapping**: Rules must be mapped to ATT&CK techniques. Without mapping, you cannot measure coverage, identify gaps, or communicate detection capability.
- **No testing before deployment**: Rules deployed without testing against known-good and known-bad data will either miss threats or flood the SOC with false positives.
- **Never retiring rules**: Rules for techniques that are no longer relevant, or that generate only false positives, should be retired. Dead rules add noise and processing overhead.

## References

- Sigma Specification: https://github.com/SigmaHQ/sigma-specification
- Sigma Rule Repository: https://github.com/SigmaHQ/sigma
- YARA Documentation: https://yara.readthedocs.io/
- Sysmon Configuration (SwiftOnSecurity): https://github.com/SwiftOnSecurity/sysmon-config
- ATT&CK Data Sources: https://attack.mitre.org/datasources/
- Detection Engineering Weekly: https://www.detectionengineering.net/
- Sigma-cli: https://github.com/SigmaHQ/sigma-cli
