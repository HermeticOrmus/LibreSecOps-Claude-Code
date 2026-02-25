# Log Correlation Patterns

> Patterns for correlating events across multiple log sources to detect multi-stage attacks, lateral movement, credential abuse, and data exfiltration.

## Knowledge Base

### Why Correlation Matters

Single-event detections catch simple attacks. Advanced threats operate across multiple stages, systems, and time windows. Correlation combines events from different sources to detect attack patterns that no single log source reveals on its own.

Example: A brute-force attack (authentication log) followed by successful login (authentication log) followed by new scheduled task (Sysmon) followed by outbound connection to rare domain (DNS log) tells a complete attack story that individual alerts would only partially reveal.

### Correlation Techniques

**Time-based correlation**: Events from different sources within a time window
```
Event A (authentication failure x5 in 60 seconds)
  -> Event B (successful authentication within 120 seconds)
  -> Event C (privilege escalation within 300 seconds)
```

**Entity-based correlation**: Events linked by a common entity (user, host, IP)
```
Same user account:
  - Authenticated from Location A at T1
  - Authenticated from Location B at T1+30min (impossible travel)
```

**Sequence-based correlation**: Events that must occur in a specific order
```
Step 1: Process creates file in temp directory
Step 2: Same process modifies registry run key pointing to that file
Step 3: Outbound network connection from that process
```

**Statistical correlation**: Deviations from baseline behavior
```
User normally accesses 5 file shares -> Suddenly accesses 50
Host normally sends 100MB outbound -> Sends 10GB in one hour
```

### Common Correlation Patterns

**Pattern 1: Brute Force to Compromise**

Correlate authentication failures with subsequent success from the same source.

```
Sigma-like logic:
  Source: Authentication logs
  Step 1: count(failed_login) > 5 WHERE source_ip = X AND timewindow = 5m
  Step 2: successful_login WHERE source_ip = X AND timewindow = 10m after Step 1
  Severity: High
```

Splunk SPL:
```spl
index=windows EventCode IN (4625, 4624)
| sort _time
| transaction TargetUserName maxspan=15m
| where eventcount > 5 AND mvindex(EventCode, -1)=4624
| eval bruteforce_attempts=mvcount(mvfilter(EventCode=4625))
| where bruteforce_attempts >= 5
```

Sentinel KQL:
```kql
let failures = SecurityEvent
| where EventID == 4625
| summarize FailCount=count(), FirstFail=min(TimeGenerated), LastFail=max(TimeGenerated) by TargetAccount, IpAddress
| where FailCount >= 5;
let successes = SecurityEvent
| where EventID == 4624
| project SuccessTime=TimeGenerated, TargetAccount, IpAddress;
failures
| join kind=inner successes on TargetAccount, IpAddress
| where SuccessTime between (LastFail .. (LastFail + 10m))
```

**Pattern 2: Lateral Movement Chain**

Correlate authentication on Host A with process creation on Host B using the same credentials.

```
Step 1: Logon Type 3 (network) on Host B from Host A
Step 2: Service installation or process creation on Host B
Step 3: Outbound connection from Host B to new external destination
```

Splunk SPL:
```spl
index=windows EventCode=4624 LogonType=3
| rename ComputerName AS dest_host, IpAddress AS src_ip
| join src_ip [search index=windows EventCode=4624 LogonType=10
  | rename ComputerName AS src_host, IpAddress AS src_ip]
| table _time, src_host, dest_host, TargetUserName
| sort _time
```

**Pattern 3: Data Staging and Exfiltration**

Correlate file access patterns with network transfer anomalies.

```
Step 1: Unusual volume of file reads from sensitive shares (file server logs)
Step 2: Large archive file created in temp directory (Sysmon Event ID 11)
Step 3: Outbound transfer to cloud storage or external host (proxy/DNS logs)
```

**Pattern 4: Credential Harvesting**

Correlate known credential theft tool execution with subsequent authentication from new locations.

```
Step 1: Mimikatz/procdump execution targeting LSASS (Sysmon Event ID 10 - process access to lsass.exe)
Step 2: Authentication using accounts found in memory (new logon events for privileged accounts)
Step 3: Authenticated actions from unexpected hosts or service accounts
```

Splunk SPL (LSASS access detection):
```spl
index=sysmon EventCode=10 TargetImage="*\\lsass.exe"
| where NOT match(SourceImage, "(?i)(csrss|services|svchost|wininit|wmiprvse|MsMpEng)\.exe$")
| stats count by _time, ComputerName, SourceImage, SourceUser
```

**Pattern 5: Impossible Travel**

Detect authentication from geographically distant locations in an impossibly short timeframe.

Sentinel KQL:
```kql
SigninLogs
| where ResultType == 0
| project TimeGenerated, UserPrincipalName, Location, IPAddress
| sort by UserPrincipalName, TimeGenerated asc
| extend PrevLocation = prev(Location), PrevTime = prev(TimeGenerated), PrevUser = prev(UserPrincipalName)
| where UserPrincipalName == PrevUser
| extend TimeDiffMinutes = datetime_diff('minute', TimeGenerated, PrevTime)
| where Location != PrevLocation AND TimeDiffMinutes < 60
```

**Pattern 6: DNS Tunneling Detection**

Detect data exfiltration through DNS queries by analyzing query patterns.

```
Indicators:
- High volume of DNS queries to a single domain
- Unusually long subdomain labels (data encoded in subdomain)
- High entropy in subdomain strings
- TXT record queries (common for DNS tunnel responses)
```

Splunk SPL:
```spl
index=dns
| rex field=query "(?<subdomain>[^.]+)\.(?<domain>[^.]+\.[^.]+)$"
| eval subdomain_len=len(subdomain)
| stats count, avg(subdomain_len) as avg_len, max(subdomain_len) as max_len by domain
| where count > 100 AND avg_len > 20
| sort -count
```

### Enrichment for Better Correlation

**Asset inventory**: Map IP addresses to hostnames, owners, and criticality levels. Without this, correlation results are IP addresses that require manual lookup.

**Identity mapping**: Link Windows SAMAccountName to email address, department, manager. Enable "this account is unusual for this role" context.

**Threat intelligence**: Enrich IP/domain/hash observations with threat intel feeds. Flag when correlated events involve known-bad indicators.

**GeoIP**: Map IP addresses to locations for impossible travel and geographic anomaly detection.

## Patterns

### Pattern: Alert-on-Alert Correlation
Trigger a high-severity composite alert when multiple lower-severity alerts fire for the same entity within a time window. Example: same host triggers "suspicious PowerShell" + "new scheduled task" + "unusual outbound DNS" within 1 hour.

### Pattern: Threshold-Based Anomaly
Establish baselines for entity behavior (normal login count, normal data volume, normal process count) and alert when current values exceed N standard deviations from the baseline.

### Pattern: Kill Chain Correlation
Map detected events to cyber kill chain stages. When events appear in 3+ stages for the same entity within a campaign window, escalate to incident.

## Anti-Patterns

- **Over-correlation**: Correlating too many events produces composite alerts that are hard to understand and investigate. Keep correlation rules to 2-3 events maximum
- **Time windows too wide**: A 24-hour correlation window captures too much noise. Most attack sequences complete within minutes to hours. Start with tight windows and expand as needed
- **Ignoring enrichment**: Correlating raw IP addresses without asset context means every alert requires manual enrichment. Build enrichment into the pipeline
- **One-size-fits-all thresholds**: A brute force threshold of 5 failures may be appropriate for VPN but generate constant noise for Active Directory. Tune thresholds per source
- **Not testing correlations**: Write test cases for correlation rules. Simulate the attack sequence and verify the correlation fires correctly with all context fields populated

## References

- MITRE ATT&CK -- https://attack.mitre.org/
- Sigma Rules Repository -- https://github.com/SigmaHQ/sigma
- Atomic Red Team -- https://github.com/redcanaryco/atomic-red-team
- MITRE ATT&CK Navigator -- https://mitre-attack.github.io/attack-navigator/
- Splunk Security Essentials -- https://splunkbase.splunk.com/app/3435
- Elastic Detection Rules -- https://github.com/elastic/detection-rules
- Microsoft Sentinel Analytics Rules -- https://github.com/Azure/Azure-Sentinel
