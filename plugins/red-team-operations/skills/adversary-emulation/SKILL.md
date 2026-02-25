# Adversary Emulation

> Methodology for building adversary emulation plans based on real threat intelligence, including scenario design, phased operations, and atomic testing patterns.

## Knowledge Base

### Adversary Emulation vs. Penetration Testing

These are different disciplines with different goals:

| Aspect | Penetration Testing | Adversary Emulation |
|--------|-------------------|-------------------|
| Goal | Find vulnerabilities | Test detection and response |
| Approach | Find any path to objective | Follow a specific adversary's known TTPs |
| Stealth | Varies (often noisy) | Realistic adversary OPSEC |
| Intelligence input | Scope document | Threat intelligence report |
| Primary consumer | Vulnerability management | Detection engineering, SOC |
| Success metric | Vulnerabilities found | Detections validated |
| Duration | 1-3 weeks typically | 2-6 weeks typically |

### The Adversary Emulation Lifecycle

```
1. Threat Intelligence --> Who targets organizations like ours?
       |
2. TTP Selection --> What specific techniques does this adversary use?
       |
3. Scenario Design --> What is the realistic attack narrative?
       |
4. Rules of Engagement --> What are the boundaries and safety controls?
       |
5. Tool Selection --> What tools replicate the adversary's capabilities?
       |
6. Phased Execution --> Execute in phases with decision gates
       |
7. Detection Assessment --> What did the blue team see? What did they miss?
       |
8. Reporting --> Detection gaps, response gaps, recommendations
       |
9. Remediation --> Blue team builds/improves detections
       |
10. Re-test --> Validate the improvements
```

### Established Methodologies

**TIBER-EU (Threat Intelligence-Based Ethical Red Teaming)**: European Central Bank framework for financial sector red teaming. Requires a dedicated threat intelligence phase, a red team phase, and a blue team assessment phase. The threat intelligence provider and red team provider must be independent.

**CBEST (UK)**: Bank of England's intelligence-led red team testing framework for UK financial institutions. Similar to TIBER-EU but UK-specific.

**MITRE Adversary Emulation Plans**: MITRE publishes detailed emulation plans for specific threat actors (APT3, APT29, FIN6, Sandworm). These include step-by-step procedures mapped to ATT&CK techniques.

**Atomic Red Team (Red Canary)**: Not full emulation plans but individual technique tests. Used for validating specific detections in isolation, often as a complement to full emulation exercises.

### Safety Controls for Authorized Testing

```
MANDATORY CONTROLS:
1. Written authorization from system owner
2. Defined scope with explicit boundaries
3. Rules of engagement signed by all parties
4. Emergency stop procedure (code word + contact)
5. Deconfliction channel (distinguish red team from real attacker)
6. Evidence handling procedures (how accessed data is treated)
7. Time-boxed engagement (clear start and end dates)
8. Legal review (local laws, regulations, contractual obligations)
9. Insurance coverage (professional liability, cyber liability)
10. Secure communication channel for red team operations
```

## Patterns

### Pattern 1: Emulation Plan Structure (Based on MITRE Methodology)

```markdown
# Adversary Emulation Plan: [Threat Actor Name]

## Threat Intelligence Summary
- Actor: [name and aliases]
- Motivation: [espionage / financial / disruption]
- Known campaigns: [list with dates]
- Targeted sectors: [list]
- Key sources: [threat intel reports with URLs]

## Emulation Scope
- Techniques emulated: [list of ATT&CK IDs]
- Techniques NOT emulated: [list with justification -- too destructive, not relevant]
- Environment: [test/lab/production with controls]

## Operation Phases

### Phase 1: Initial Compromise
Objective: Establish initial foothold
Techniques:
  - T1566.001: Spearphishing Attachment
    Procedure: Send email with macro-enabled Word document to target user
    Tool: Custom macro builder (not weaponized -- drops benign indicator file)
    Expected Detection: Email gateway + EDR alert on macro execution
    Atomic Test: T1566.001-1

### Phase 2: Establish Foothold
Objective: Deploy persistent access
Techniques:
  - T1059.001: PowerShell
    Procedure: Macro executes PowerShell to download and execute payload
    Tool: PowerShell script that downloads from controlled C2
    Expected Detection: ScriptBlock logging, process creation anomaly
  - T1547.001: Registry Run Key
    Procedure: Add registry key for persistence
    Expected Detection: Sysmon EventID 13, registry monitoring

### Phase 3: Internal Reconnaissance
Objective: Map the internal environment
Techniques:
  - T1087.002: Domain Account Discovery
    Procedure: net user /domain, Get-ADUser
    Tool: Built-in Windows commands
    Expected Detection: Unusual AD enumeration from workstation
  - T1018: Remote System Discovery
    Procedure: Network scanning of internal subnets
    Expected Detection: Network IDS, anomalous scan patterns

### Phase 4: Lateral Movement
Objective: Access high-value targets
Techniques:
  - T1021.002: SMB/Windows Admin Shares
  - T1003.001: LSASS Memory Dump
  Expected Detection: Admin share access from unexpected source, LSASS access alert

### Phase 5: Objective Completion
Objective: Demonstrate impact capability
Techniques:
  - T1005: Data from Local System
    Procedure: Access and copy (but not exfiltrate) target documents
    Safety: Mark files as accessed, do not actually remove from network
  Expected Detection: DLP alert, unusual file access patterns

## Decision Gates
After each phase:
  [ ] Were detections triggered? (Record which ones)
  [ ] Was response initiated? (Record timeline)
  [ ] Should we continue, adjust, or stop?
  [ ] Is it safe to proceed to the next phase?
```

### Pattern 2: Purple Team Exercise Structure

```markdown
# Purple Team Exercise: [Focus Area]

## Format
- Duration: [4 hours / full day / multi-day]
- Participants:
  - Red: [team members]
  - Blue: [SOC analysts, detection engineers]
  - Facilitator: [neutral coordinator]

## Round Structure

### Round 1: T1059.001 -- PowerShell Execution (30 min)
- Red: Execute PowerShell download cradle (Atomic Test T1059.001-1)
- Blue: Observe -- did SIEM alert? Which rule? How long?
- Discussion: Review detection, identify gaps, suggest improvements
- Action item: [specific detection improvement]

### Round 2: T1003.001 -- LSASS Memory Access (30 min)
- Red: Attempt LSASS dump using procdump (Atomic Test T1003.001-1)
- Blue: Observe -- did EDR block? Did Sysmon capture EventID 10?
- Discussion: Review protection and detection layers
- Action item: [specific improvement]

### Round 3: T1021.002 -- Lateral Movement via SMB (30 min)
- Red: Use captured credentials to access admin share
- Blue: Observe -- did network monitoring detect? Correlation rules?
- Discussion: Review lateral movement detection capability
- Action item: [specific improvement]

[...additional rounds...]

## Scorecard
| Technique | Detected | Blocked | Response Time | Improvement Needed |
|-----------|----------|---------|---------------|-------------------|
| T1059.001 | Yes | No | 8 min | Add block rule |
| T1003.001 | Yes | Yes (EDR) | Immediate | None (working) |
| T1021.002 | No | No | N/A | New correlation rule needed |
```

### Pattern 3: Atomic Testing Schedule

For continuous detection validation without full red team engagements:

```yaml
# Monthly atomic testing schedule
schedule:
  week_1:
    focus: "Initial Access & Execution"
    tests:
      - technique: T1566.001
        test_id: T1566.001-1
        validation: "Email gateway alert + EDR process creation alert"
      - technique: T1059.001
        test_id: T1059.001-1
        validation: "ScriptBlock logging Event 4104"
      - technique: T1204.002
        test_id: T1204.002-1
        validation: "User execution detection"

  week_2:
    focus: "Persistence & Privilege Escalation"
    tests:
      - technique: T1547.001
        test_id: T1547.001-1
        validation: "Sysmon EventID 13 registry modification"
      - technique: T1053.005
        test_id: T1053.005-1
        validation: "Event ID 4698 task creation"

  week_3:
    focus: "Credential Access & Lateral Movement"
    tests:
      - technique: T1003.001
        test_id: T1003.001-1
        validation: "Sysmon EventID 10 LSASS access"
      - technique: T1021.002
        test_id: T1021.002-1
        validation: "Event ID 5140 admin share access"

  week_4:
    focus: "Defense Evasion & Collection"
    tests:
      - technique: T1070.001
        test_id: T1070.001-1
        validation: "Event log clearing detection"
      - technique: T1560.001
        test_id: T1560.001-1
        validation: "Archive creation detection"
```

## Anti-Patterns

- **Emulating a threat actor without intelligence**: Picking random ATT&CK techniques is not adversary emulation. It is generic testing. Emulation requires specific threat intelligence about the actor's known TTPs.
- **All-offense, no-defense output**: A red team report that says "we compromised the domain" without mapping each step to detection gaps and remediation recommendations is incomplete.
- **Skipping the rules of engagement**: "We have verbal approval" is not authorization. Written ROE protects both the organization and the red team legally and operationally.
- **Using live malware for emulation**: Adversary emulation should use benign indicators (file drops, process creation, registry changes) that trigger detections without creating actual risk. Tools like CALDERA and Atomic Red Team provide safe test payloads.
- **Testing only during business hours**: Real adversaries operate 24/7. If detection depends on a human watching a dashboard during business hours, test after hours to validate automated detection and alerting.
- **One-and-done testing**: Adversary emulation should be continuous. Threats evolve, defenses degrade, and new systems are deployed. Schedule regular emulation exercises, not annual engagements.

## References

- MITRE Adversary Emulation Plans: https://attack.mitre.org/resources/adversary-emulation-plans/
- TIBER-EU Framework: https://www.ecb.europa.eu/paym/cyber-resilience/tiber-eu/html/index.en.html
- Red Canary Atomic Red Team: https://github.com/redcanaryco/atomic-red-team
- MITRE CALDERA: https://caldera.mitre.org/
- PTES (Penetration Testing Execution Standard): http://www.pentest-standard.org/
- Lockheed Martin Cyber Kill Chain: https://www.lockheedmartin.com/en-us/capabilities/cyber/cyber-kill-chain.html
- CISA Red Team Assessments: https://www.cisa.gov/red-team-assessments
