# SIEM Query Languages

> Reference for Splunk SPL, Elastic KQL/EQL, and Microsoft Sentinel KQL with security-focused query patterns and platform comparison.

## Knowledge Base

### Language Overview

| Feature | Splunk SPL | Elastic KQL | Sentinel KQL (Kusto) |
|---------|-----------|------------|---------------------|
| Paradigm | Pipe-based search | Filter expressions | Pipe-based tabular |
| Strengths | Flexible, powerful stats | Simple filtering, EQL sequences | Rich analytics, joins, time-series |
| Learning curve | Medium | Low | Medium-High |
| Sequence detection | Transaction command | EQL sequences | Custom via joins/mv-expand |
| Machine learning | MLTK addon | ML jobs | Built-in KQL functions |
| Subsearch/subquery | Subsearch, join | N/A (use EQL) | let statements, join |

### Splunk SPL Reference

**Core search syntax**:
```spl
index=<index> sourcetype=<sourcetype> <keyword>
| where <condition>
| eval <new_field> = <expression>
| stats <function> by <field>
| table <fields>
| sort <field>
```

**Essential SPL commands for security**:

```spl
# Count events by field
| stats count by src_ip, dest_ip, dest_port

# Time-based aggregation
| timechart span=1h count by action

# Field extraction (regex)
| rex field=_raw "user=(?<username>\w+)"

# Lookup enrichment
| lookup asset_inventory ip AS src_ip OUTPUT hostname, owner, criticality

# Transaction (session grouping)
| transaction src_ip maxspan=5m maxpause=30s

# Subsearch
[search index=threat_intel | fields ioc_ip | rename ioc_ip AS dest_ip]

# Statistical outlier detection
| eventstats avg(bytes) AS avg_bytes, stdev(bytes) AS stdev_bytes by src_ip
| where bytes > (avg_bytes + 3*stdev_bytes)

# Accelerated datamodel search
| tstats count FROM datamodel=Authentication WHERE Authentication.action=failure BY Authentication.src, Authentication.user
```

**Security query examples**:

```spl
# Failed logins followed by success (brute force)
index=windows sourcetype=WinEventLog:Security EventCode IN (4625, 4624)
| stats values(EventCode) AS events, count(eval(EventCode=4625)) AS failures, count(eval(EventCode=4624)) AS successes, earliest(_time) AS first_seen, latest(_time) AS last_seen BY TargetUserName, IpAddress
| where failures >= 5 AND successes >= 1

# PowerShell encoded command execution
index=sysmon EventCode=1 Image="*\\powershell.exe"
| where match(CommandLine, "(?i)-e(nc|ncodedcommand)\s+[A-Za-z0-9+/=]{20,}")
| table _time, ComputerName, User, CommandLine, ParentImage

# Rare outbound connections (hunting)
index=proxy
| stats count BY dest_domain
| where count < 5
| sort count

# Data exfiltration (large transfers)
index=firewall action=allowed direction=outbound
| stats sum(bytes_out) AS total_bytes BY src_ip
| where total_bytes > 1073741824
| eval GB=round(total_bytes/1073741824, 2)
| sort -total_bytes
```

### Elastic KQL/EQL Reference

**KQL (Kibana Query Language)** -- Used for filtering in Kibana:
```kql
# Simple field matching
process.name: "powershell.exe"

# Wildcards
process.command_line: *-encodedcommand*

# Boolean operators
event.action: "logon-failed" AND source.ip: "10.0.0.0/8"

# Range queries
event.severity: >= 3

# Negation
NOT process.name: "svchost.exe"

# Grouping
(process.name: "cmd.exe" OR process.name: "powershell.exe") AND user.name: "admin"
```

**EQL (Event Query Language)** -- Used for sequence detection:
```eql
# Single event
process where process.name == "mimikatz.exe"

# Sequence detection (ordered events with time constraint)
sequence by host.name with maxspan=5m
  [authentication where event.outcome == "failure"] with runs=5
  [authentication where event.outcome == "success"]

# Process tree analysis
sequence by host.name with maxspan=1m
  [process where process.name == "outlook.exe"] by process.entity_id
  [process where true] by process.parent.entity_id

# Lateral movement pattern
sequence by source.ip with maxspan=30m
  [authentication where event.outcome == "success" and source.ip != "127.0.0.1"]
  [process where process.name in ("cmd.exe", "powershell.exe")]
```

**Elastic detection rule types**:
- **Custom query**: KQL or EQL filter matching
- **Threshold**: Alert when count exceeds value within time window
- **Event correlation**: EQL sequence matching
- **Machine learning**: Anomaly detection jobs
- **Indicator match**: Compare events against threat intel feeds
- **New terms**: Alert on first occurrence of a value

### Microsoft Sentinel KQL (Kusto) Reference

**Core syntax**:
```kql
TableName
| where TimeGenerated > ago(24h)
| where FieldName == "value"
| extend NewField = expression
| summarize count() by FieldName
| project Field1, Field2, Field3
| sort by TimeGenerated desc
| take 100
```

**Essential KQL operators for security**:

```kql
// String operations
| where ProcessName has "powershell"           // Contains (case-insensitive)
| where ProcessName has_any ("cmd", "powershell")  // Contains any
| where ProcessName startswith "C:\\Windows"
| where ProcessName matches regex @"(?i)mimikatz"
| where CommandLine contains "-enc"

// Time operations
| where TimeGenerated > ago(1h)
| where TimeGenerated between (datetime(2024-01-15) .. datetime(2024-01-16))
| extend HourOfDay = hourofday(TimeGenerated)
| extend DayOfWeek = dayofweek(TimeGenerated)

// Aggregation
| summarize count(), dcount(Computer), make_set(Computer) by Account
| summarize EventCount=count() by bin(TimeGenerated, 1h), Account

// Joins
let suspicious_ips = SigninLogs | where ResultType != 0 | distinct IPAddress;
SecurityEvent
| where EventID == 4624
| where IpAddress in (suspicious_ips)

// Let statements (variables/functions)
let threshold = 5;
let timewindow = 1h;
SecurityEvent
| where TimeGenerated > ago(timewindow)
| summarize FailCount=count() by TargetAccount
| where FailCount > threshold

// mv-expand (explode multi-value)
| mv-expand parsed_field
```

**Security query examples**:

```kql
// Impossible travel detection
let timeWindow = 60min;
SigninLogs
| where ResultType == 0
| project TimeGenerated, UserPrincipalName, Location, IPAddress
| sort by UserPrincipalName asc, TimeGenerated asc
| serialize
| extend PrevUser = prev(UserPrincipalName), PrevLocation = prev(Location), PrevTime = prev(TimeGenerated)
| where UserPrincipalName == PrevUser and Location != PrevLocation
| extend TimeDiff = datetime_diff('minute', TimeGenerated, PrevTime)
| where TimeDiff < 60

// Suspicious process creation
SecurityEvent
| where EventID == 4688
| where ParentProcessName endswith "\\winword.exe" or ParentProcessName endswith "\\excel.exe"
| where NewProcessName has_any ("cmd.exe", "powershell.exe", "wscript.exe", "cscript.exe", "mshta.exe")
| project TimeGenerated, Computer, Account, ParentProcessName, NewProcessName, CommandLine

// Cloud resource modification outside business hours
AzureActivity
| where TimeGenerated > ago(24h)
| extend Hour = hourofday(TimeGenerated)
| where Hour < 6 or Hour > 22
| where OperationNameValue has_any ("write", "delete", "action")
| project TimeGenerated, Caller, OperationNameValue, ResourceGroup, _ResourceId

// Threat intelligence matching
ThreatIntelligenceIndicator
| where ExpirationDateTime > now()
| where isnotempty(NetworkIP)
| join kind=inner (
    CommonSecurityLog
    | where TimeGenerated > ago(1d)
    | extend DestIP = DestinationIP
) on $left.NetworkIP == $right.DestIP
| project TimeGenerated, IndicatorId, ThreatType, DestIP, SourceIP, DeviceProduct
```

### Platform Conversion Cheat Sheet

| Concept | Splunk SPL | Elastic KQL | Sentinel KQL |
|---------|-----------|------------|-------------|
| Filter | `where field="value"` | `field: "value"` | `where field == "value"` |
| Contains | `field="*value*"` | `field: *value*` | `where field has "value"` |
| Regex | `\| regex field="pattern"` | N/A (use EQL) | `where field matches regex "pattern"` |
| Count by | `\| stats count by field` | Aggregation | `\| summarize count() by field` |
| Time filter | `earliest=-1h` | Time picker | `\| where TimeGenerated > ago(1h)` |
| Top N | `\| top 10 field` | Terms aggregation | `\| top 10 by field` |
| Rename | `\| rename old AS new` | Runtime field | `\| project-rename new=old` |
| New field | `\| eval new=expr` | Runtime field | `\| extend new=expr` |
| Lookup | `\| lookup table field` | Enrichment | `\| join` or `externaldata` |
| Dedup | `\| dedup field` | Collapse | `\| summarize arg_max(TimeGenerated, *) by field` |

## Patterns

### Pattern: Write Once in Sigma, Deploy Everywhere
Write detection logic as Sigma rules (YAML), then use sigma-cli or uncoder.io to convert to each target platform. This ensures consistency and portability.

### Pattern: Query Performance Optimization
- Use indexed fields in filters (Splunk: `index`, `sourcetype`, `source`; Elastic: mapped fields; Sentinel: TimeGenerated)
- Filter early, aggregate late
- Avoid leading wildcards (`*value` is slow; `value*` is fast)
- Use data models / accelerated searches for frequently-run queries

### Pattern: Investigation Query Chain
Build investigation queries as a sequence: (1) Scope (what hosts/users are involved), (2) Timeline (what happened when), (3) Lateral (what other systems were touched), (4) Impact (what data was accessed).

## Anti-Patterns

- **SELECT * equivalent**: Returning all fields when only a few are needed. Always project/table the specific fields needed for analysis
- **Unbounded time ranges**: Searching "all time" when the investigation covers a specific window. Always scope time ranges
- **Nested subsearches**: Deep subsearch nesting in SPL causes performance issues. Refactor to use stats, join, or lookup instead
- **Alerting on raw queries without context**: A detection alert that says "suspicious event" without user, host, process, and timestamp forces the analyst to re-run the query to investigate

## References

- Splunk SPL Reference -- https://docs.splunk.com/Documentation/Splunk/latest/SearchReference
- Elastic KQL Documentation -- https://www.elastic.co/guide/en/kibana/current/kusto-query-language.html
- Elastic EQL Reference -- https://www.elastic.co/guide/en/elasticsearch/reference/current/eql.html
- Microsoft KQL Reference -- https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/
- Sigma Specification -- https://sigmahq.io/
- Sigma Rules Repository -- https://github.com/SigmaHQ/sigma
- sigma-cli converter -- https://github.com/SigmaHQ/sigma-cli
- Uncoder.IO (Sigma conversion) -- https://uncoder.io/
