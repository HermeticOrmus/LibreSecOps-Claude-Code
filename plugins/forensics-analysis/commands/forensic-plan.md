# /forensic-plan

> Create a forensic investigation plan tailored to the incident type, defining evidence sources, collection priorities, and analysis approach.

## Trigger

Use at the start of any forensic investigation to establish a structured plan before collecting evidence. Appropriate for:

- Active incident response requiring forensic analysis
- Post-incident investigation
- Insider threat investigation (with HR and legal authorization)
- Data breach assessment
- Malware impact analysis
- Compliance-driven forensic review

## Input

- **Required**: Incident type or description (e.g., "ransomware on file server", "suspected data exfiltration", "compromised web server", "insider threat investigation")
- **Required**: Authorization status (who authorized the investigation)
- **Optional**: Known affected systems
- **Optional**: Incident timeline (when was it detected, suspected start time)
- **Optional flag**: `--live` -- the system is still running (affects collection order)
- **Optional flag**: `--legal` -- investigation may lead to legal proceedings (stricter evidence handling)

## Process

1. **Scope Definition**: Based on the incident type, define:
   - What questions does this investigation need to answer?
   - What systems are in scope?
   - What time period is relevant?
   - What legal or regulatory requirements apply?

2. **Evidence Source Identification**: Map all potential evidence sources:
   - **Volatile** (collect first): RAM, running processes, network connections, logged-in users, clipboard contents, mounted file systems
   - **Semi-volatile**: Temporary files, swap/page file, system logs on disk
   - **Non-volatile**: Disk images, backup tapes, removable media, cloud storage
   - **External**: SIEM logs, network flow data, authentication logs (Active Directory, IdP), cloud audit logs, email gateway logs

3. **Collection Priority**: Order evidence collection by:
   - Volatility (most volatile first)
   - Relevance to the investigation questions
   - Risk of loss (evidence that may be overwritten or destroyed)
   - Legal requirements (some jurisdictions require specific collection orders)

4. **Collection Procedures**: Define the specific procedure for each evidence source:
   - Tool to use
   - Command syntax
   - Output format and destination
   - Hash verification method
   - Chain of custody documentation

5. **Analysis Approach**: Based on the incident type, define the analysis workflow:
   - **Malware incident**: Memory analysis (process injection, C2) --> Timeline analysis (execution, persistence) --> File system analysis (malware artifacts, data staging)
   - **Data exfiltration**: Network forensics (data flows, volumes) --> User activity (file access, USB usage) --> Email/cloud analysis (exfiltration channels)
   - **Account compromise**: Authentication log analysis --> Lateral movement tracing --> Privilege escalation review --> Data access audit
   - **Ransomware**: Encryption timeline --> Initial access vector --> Lateral movement --> Data exfiltration (double extortion) --> Recovery options

6. **Reporting Requirements**: Define the expected deliverables and audience.

## Output

```
# Forensic Investigation Plan
Case ID: [identifier]
Date: [plan creation date]
Examiner: [name]

## Authorization
- Authorized by: [name, title]
- Authorization document: [reference]
- Scope limitations: [any restrictions]
- Legal counsel: [if applicable]

## Investigation Questions
1. [Primary question -- e.g., "How did the attacker gain initial access?"]
2. [Secondary question -- e.g., "What data was accessed or exfiltrated?"]
3. [Tertiary question -- e.g., "Are there any persistence mechanisms?"]

## Evidence Sources (Priority Order)

### Phase 1: Volatile Evidence (Collect Immediately)
| Priority | Source | System | Tool | Procedure |
|----------|--------|--------|------|-----------|
| 1 | RAM capture | Server01 | WinPMem | [specific command] |
| 2 | Network connections | Server01 | netstat / netscan | [specific command] |
| 3 | Running processes | Server01 | tasklist / pslist | [specific command] |

### Phase 2: Live System Evidence
| Priority | Source | System | Tool | Procedure |
|----------|--------|--------|------|-----------|
| 4 | Event logs | Server01 | KAPE | [specific command] |
| 5 | Registry hives | Server01 | KAPE | [specific command] |
| 6 | Prefetch/Amcache | Server01 | KAPE | [specific command] |

### Phase 3: Disk Image
| Priority | Source | System | Tool | Procedure |
|----------|--------|--------|------|-----------|
| 7 | Full disk image | Server01 | dc3dd / FTK Imager | [specific command] |

### Phase 4: External Evidence
| Priority | Source | Location | Tool | Procedure |
|----------|--------|----------|------|-----------|
| 8 | SIEM logs | [SIEM platform] | Export | [specific query] |
| 9 | Network flows | [network tool] | Export | [specific query] |

## Analysis Workflow
[Ordered analysis steps specific to the incident type]

## Reporting
- Audience: [who receives the report]
- Format: [report template]
- Deadline: [if applicable]
- Classification: [confidentiality level]
```
