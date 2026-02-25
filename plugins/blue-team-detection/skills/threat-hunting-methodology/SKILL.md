# Threat Hunting Methodology

> Hypothesis-driven hunting framework, data analysis techniques, and hunt documentation patterns for proactive threat detection.

## Knowledge Base

### What is Threat Hunting

Threat hunting is the proactive, analyst-driven search for threats that have evaded automated detection. Unlike detection engineering (which builds rules that fire automatically), hunting is a human-led investigation that uses hypotheses, data analysis, and domain expertise to find adversary activity that does not match any existing rule.

Hunting assumes the adversary is already inside. The question is not "are we safe?" but "what evidence would we expect to see if we were compromised?"

### The Hypothesis-Driven Framework

Every hunt starts with a hypothesis. A good hypothesis is:

- **Testable**: Can be confirmed or refuted with available data
- **Specific**: Targets a particular technique, actor, or behavior
- **Scoped**: Has defined time windows and system boundaries
- **Intelligence-driven**: Based on threat intelligence, ATT&CK techniques, or known detection gaps

```
Hypothesis Template:
"If [threat actor / technique / behavior] is present in our environment,
we would expect to see [specific indicators] in [data source]
within [time window]."

Example:
"If an adversary is using DNS tunneling for data exfiltration (T1071.004),
we would expect to see endpoints making unusually high volumes of DNS TXT
queries or queries to domains with high entropy subdomains in our DNS
logs within the last 30 days."
```

### Hunt Categories

**Intelligence-Driven Hunts**: Based on new threat intelligence -- a published APT report, a new CVE, an industry advisory. "Is this threat present in our environment?"

**Technique-Driven Hunts**: Based on ATT&CK techniques, particularly those without automated detections. "Do we have evidence of T1055 (Process Injection)?"

**Anomaly-Driven Hunts**: Based on statistical outliers in telemetry. "What processes are running that have never been seen before?" "What users are authenticating at unusual times?"

**Gap-Driven Hunts**: Based on known detection gaps, often identified during red team exercises. "We have no detection for DLL search order hijacking -- let us look for it manually."

### Required Data Sources for Common Hunts

| Hunt Focus | Primary Data Source | Key Fields |
|-----------|-------------------|------------|
| Process execution | Sysmon EID 1 / Windows 4688 | Image, CommandLine, ParentImage, User |
| Network connections | Sysmon EID 3 / Firewall logs | SourceIP, DestIP, DestPort, Protocol |
| DNS activity | DNS query logs / Sysmon EID 22 | QueryName, QueryType, ResponseCode |
| File creation | Sysmon EID 11 | TargetFilename, Image, CreationTime |
| Registry modification | Sysmon EID 13 | TargetObject, Details, Image |
| Authentication | Windows 4624/4625 | LogonType, TargetUserName, SourceNetworkAddress |
| Service installation | Windows 7045 | ServiceName, ServiceFileName |
| Scheduled tasks | Windows 4698 | TaskName, TaskContent |
| Lateral movement | Windows 5140/5145 | ShareName, SubjectUserName, IpAddress |

## Patterns

### Pattern 1: DNS Tunneling Hunt

```
HYPOTHESIS: "If an adversary is using DNS tunneling for C2 or exfiltration,
we would see DNS queries with unusually long subdomain labels, high
query volume to single domains, or TXT/NULL record requests from
endpoints that normally only make A/AAAA queries."

SCOPE: All internal endpoints, last 30 days, DNS query logs

ANALYSIS:

Step 1: Baseline DNS query patterns
-- Splunk SPL
index=dns sourcetype=dns
| stats count by src_ip query_type
| sort - count
-- What is normal? How many queries per endpoint per day?

Step 2: Identify long subdomain queries (potential tunneling)
-- Splunk SPL
index=dns sourcetype=dns
| eval subdomain_length=len(mvindex(split(query,"."),0))
| where subdomain_length > 30
| stats count values(query) as queries by src_ip
| sort - count
-- Normal DNS labels are rarely > 15 characters. Labels > 30 are suspicious.

Step 3: High-entropy domain analysis
-- Splunk SPL
index=dns sourcetype=dns
| eval domain=mvindex(split(query,"."),-2)+"."+mvindex(split(query,"."),-1)
| stats count dc(query) as unique_queries by src_ip domain
| where unique_queries > 100
| sort - unique_queries
-- High unique query count to a single domain suggests encoded data in subdomains.

Step 4: Unusual record types
-- Splunk SPL
index=dns sourcetype=dns query_type IN ("TXT","NULL","MX","CNAME")
| stats count by src_ip query_type query
| where count > 50
| sort - count
-- TXT and NULL records are commonly abused for tunneling.

Step 5: Investigate findings
For each suspicious IP:
- What process is generating the DNS queries? (correlate with Sysmon EID 22)
- Is the destination domain registered recently?
- Does the domain have WHOIS privacy?
- What does the subdomain decode to (base32/base64)?

DECISION:
- Confirmed tunneling --> Incident response, contain endpoint, block domain
- Benign --> Document (CDN, anti-virus, legitimate cloud service)
- Inconclusive --> Extend time window, add packet capture
```

### Pattern 2: Lateral Movement Hunt

```
HYPOTHESIS: "If an adversary is moving laterally using administrative shares
(T1021.002), we would see SMB connections to C$ or ADMIN$ shares from
workstations that do not normally access other workstations' admin shares."

SCOPE: All Windows endpoints, last 14 days, Windows Event 5140/5145

ANALYSIS:

Step 1: Baseline admin share access
-- Splunk SPL
index=windows EventCode=5140 ShareName IN ("\\\\*\\C$","\\\\*\\ADMIN$","\\\\*\\IPC$")
| stats count by SubjectUserName IpAddress ShareName
| sort - count
-- Who normally accesses admin shares? (Expected: IT admins, deployment tools)

Step 2: First-time-seen analysis
-- Splunk SPL
index=windows EventCode=5140 ShareName IN ("\\\\*\\C$","\\\\*\\ADMIN$")
| stats earliest(_time) as first_seen count by SubjectUserName IpAddress
| where first_seen > relative_time(now(), "-7d")
| sort - first_seen
-- New source IP + user combinations accessing admin shares in last 7 days.

Step 3: Workstation-to-workstation lateral
-- Splunk SPL
index=windows EventCode=5140 ShareName IN ("\\\\*\\C$","\\\\*\\ADMIN$")
| lookup asset_inventory ip as IpAddress OUTPUT asset_type as src_type
| lookup asset_inventory ip as ComputerName OUTPUT asset_type as dest_type
| where src_type="workstation" AND dest_type="workstation"
| stats count by SubjectUserName IpAddress ComputerName
-- Workstations accessing other workstations' admin shares is almost always
   lateral movement. Legitimate admin work goes from jump box to server.

Step 4: Correlate with process creation
-- Splunk SPL
index=windows (EventCode=4688 OR EventCode=1)
| where match(CommandLine, "\\\\\\\\.*\\\\(C|ADMIN|IPC)\\$")
| stats count by Computer User CommandLine
-- What process is performing the share access?

INDICATORS:
True Positive: Non-IT user accessing C$ from workstation, correlated with
PsExec/WMI/PowerShell remote execution on the target.
False Positive: IT admin using remote management tool, SCCM deployment,
backup software scanning shares.
```

### Pattern 3: Persistence Mechanism Hunt

```
HYPOTHESIS: "If an adversary has established persistence via scheduled tasks
(T1053.005), we would see task creation events from unexpected users
or processes, tasks pointing to unusual file paths, or tasks with
encoded/obfuscated commands."

SCOPE: All Windows servers and workstations, last 30 days, Event ID 4698

ANALYSIS:

Step 1: All scheduled task creations
-- Splunk SPL
index=windows EventCode=4698
| spath input=TaskContent output=Command path="Task.Actions.Exec.Command"
| spath input=TaskContent output=Arguments path="Task.Actions.Exec.Arguments"
| stats count by SubjectUserName TaskName Command Arguments Computer
| sort - count

Step 2: Tasks created by non-standard processes
-- Sysmon-based (EventID 1 process creation of schtasks.exe)
index=sysmon EventCode=1 Image="*\\schtasks.exe"
| stats count by ParentImage CommandLine User Computer
| where NOT match(ParentImage, "(explorer|services|svchost|taskeng)")

Step 3: Tasks with suspicious characteristics
-- Splunk SPL
index=windows EventCode=4698
| spath input=TaskContent output=Command path="Task.Actions.Exec.Command"
| where match(Command, "(powershell|cmd|wscript|cscript|mshta|rundll32)")
  OR match(Command, "(Temp|AppData|ProgramData|Users\\\\Public)")
  OR match(Command, "(-enc|-e\s|-encodedcommand)")
| table _time SubjectUserName Computer TaskName Command

Step 4: Recently created tasks not in baseline
-- Compare against known-good task list
index=windows EventCode=4698
| stats earliest(_time) as created by TaskName Computer
| where created > relative_time(now(), "-7d")
| lookup known_tasks TaskName OUTPUT expected
| where isnull(expected)
```

### Pattern 4: Hunt Documentation Template

```markdown
# Hunt Report: [Hunt Title]

## Metadata
| Field | Value |
|-------|-------|
| Hunt ID | HUNT-[YYYY]-[NNN] |
| Hypothesis | [one-line hypothesis] |
| ATT&CK Technique | [T-ID] |
| Category | Intelligence / Technique / Anomaly / Gap |
| Date | [start date] - [end date] |
| Hunter | [name] |
| Hours | [time spent] |
| Data sources | [list] |
| SIEM | [platform] |

## Hypothesis
[Full hypothesis statement]

## Methodology
[Step-by-step analysis performed with queries]

## Findings

### Finding 1: [Title]
**Severity**: [Critical / High / Medium / Low / Informational]
**Status**: [True Positive / False Positive / Inconclusive]
**Evidence**: [specific log entries, timestamps, affected systems]
**Assessment**: [analysis and conclusion]
**Action taken**: [escalated / documented / no action]

### Finding 2: [Title]
[Same structure]

## Hunt Outcome
- **Hypothesis**: CONFIRMED / REFUTED / INCONCLUSIVE
- **True positives found**: [count]
- **Incidents escalated**: [count and IR ticket IDs]
- **False positives documented**: [count]
- **New detections created**: [count and rule IDs]

## Telemetry Gaps
[Data sources needed but not available]

## Recommendations
1. [Specific actionable recommendation]
2. [Specific actionable recommendation]

## Follow-Up Hunts
[Related hypotheses to investigate next]
```

## Anti-Patterns

- **Hunting without a hypothesis**: Random searching through logs is not hunting. Without a hypothesis, you cannot measure success, scope the effort, or reproduce the work.
- **Hunting only for known IOCs**: IOC matching is detection, not hunting. True hunting looks for behaviors and anomalies, not signatures.
- **No documentation of null results**: A hunt that finds nothing is still valuable -- it proves the absence of a specific threat and identifies telemetry gaps. Document every hunt.
- **Hunting in a silo**: Hunt findings that do not feed back into detection engineering are wasted effort. Every successful hunt should produce at least one new automated detection.
- **Same hunts every time**: If you are running the same hunt every quarter without updating the hypothesis, you are not adapting to the threat landscape. Rotate hunts based on current intelligence.
- **Ignoring false positives**: False positives found during hunts are valuable -- they reveal what benign activity looks like, which helps tune detection rules. Document them.

## References

- SANS Threat Hunting Summit: https://www.sans.org/cyber-security-summit/threat-hunting/
- Sqrrl Threat Hunting Reference Model: https://www.threathunting.net/sqrrl-archive
- MITRE ATT&CK for Threat Hunting: https://attack.mitre.org/resources/getting-started/
- TaHiTI (Targeted Hunting integrating Threat Intelligence): https://www.betaalvereniging.nl/en/safety/tahiti/
- Splunk Boss of the SOC: https://www.splunk.com/en_us/blog/security/boss-of-the-soc.html
- Elastic SIEM Detection Rules: https://github.com/elastic/detection-rules
