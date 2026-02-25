# MITRE ATT&CK Framework

> Reference knowledge covering ATT&CK Enterprise tactics, selected key techniques with detection guidance, and framework usage for adversary emulation planning.

## Knowledge Base

### What is MITRE ATT&CK

MITRE ATT&CK (Adversarial Tactics, Techniques, and Common Knowledge) is a globally accessible knowledge base of adversary behavior based on real-world observations. It catalogs the TTPs (Tactics, Techniques, and Procedures) used by threat actors, organized into a matrix that maps the phases of an attack lifecycle.

ATT&CK serves both offense and defense:
- **Red teams** use it to plan realistic adversary emulations.
- **Blue teams** use it to build detections, measure coverage, and prioritize gaps.
- **Threat intelligence** uses it as a common language for describing adversary behavior.

### Enterprise ATT&CK Tactics (v15)

The 14 tactics represent the adversary's tactical objectives -- the "why" behind each action:

| ID | Tactic | Purpose | Example Question |
|----|--------|---------|-----------------|
| TA0043 | Reconnaissance | Gather info for targeting | What is exposed on the internet? |
| TA0042 | Resource Development | Build attack infrastructure | Set up C2, acquire tools, create accounts |
| TA0001 | Initial Access | Get into the network | Phishing, exploiting public-facing apps |
| TA0002 | Execution | Run adversary code | PowerShell, WMI, command line |
| TA0003 | Persistence | Maintain access across restarts | Registry run keys, scheduled tasks, implants |
| TA0004 | Privilege Escalation | Get higher permissions | Exploit vulnerabilities, token manipulation |
| TA0005 | Defense Evasion | Avoid detection | Obfuscation, disabling security tools, timestomping |
| TA0006 | Credential Access | Steal credentials | Keylogging, dumping LSASS, Kerberoasting |
| TA0007 | Discovery | Learn about the environment | Network scanning, account enumeration |
| TA0008 | Lateral Movement | Move through the network | RDP, SMB, WinRM, Pass-the-Hash |
| TA0009 | Collection | Gather target data | Keylogging, screen capture, email collection |
| TA0011 | Command and Control | Communicate with implants | HTTPS C2, DNS tunneling, encrypted channels |
| TA0010 | Exfiltration | Steal data out | Cloud storage upload, encrypted channels |
| TA0040 | Impact | Disrupt, destroy, manipulate | Ransomware encryption, data destruction, defacement |

### Key Techniques with Detection Guidance

**T1566.001 -- Spearphishing Attachment (Initial Access)**

Adversary sends email with malicious attachment (macro-enabled documents, executables disguised as documents, password-protected archives).

- **Procedure**: Macro-enabled .docm or .xlsm files, or .iso/.img files containing .lnk shortcuts.
- **Data sources**: Email gateway logs, Sysmon EventID 1 (Process creation), Sysmon EventID 11 (File creation).
- **Detection**: Office application (WINWORD.EXE, EXCEL.EXE) spawning suspicious child processes (cmd.exe, powershell.exe, wscript.exe, mshta.exe). File writes to %TEMP% or %APPDATA% from Office processes.
- **Atomic test**: Atomic Red Team T1566.001 -- tests do not send real phishing; they simulate the payload execution stage.

**T1059.001 -- PowerShell (Execution)**

Adversary uses PowerShell to execute commands, download payloads, and interact with the system.

- **Procedure**: `powershell -enc [base64]`, `IEX (New-Object Net.WebClient).DownloadString()`, PowerShell constrained language mode bypass.
- **Data sources**: PowerShell ScriptBlock Logging (Event ID 4104), Module Logging (Event ID 4103), Sysmon EventID 1.
- **Detection**: Encoded commands (-enc, -e, -encodedcommand), DownloadString/DownloadFile calls, Invoke-Expression on downloaded content, PowerShell spawned by unusual parent processes.
- **Key event**: Windows Event ID 4104 (ScriptBlock Logging) captures the decoded content of executed scripts.

**T1003.001 -- LSASS Memory (Credential Access)**

Adversary dumps credentials from the Local Security Authority Subsystem Service (LSASS) process memory.

- **Procedure**: Mimikatz `sekurlsa::logonpasswords`, `procdump -ma lsass.exe`, `comsvcs.dll MiniDump`, Task Manager dump, nanodump.
- **Data sources**: Sysmon EventID 10 (Process access to lsass.exe), Sysmon EventID 7 (Image loaded into lsass.exe), Windows Event ID 4688 (Process creation).
- **Detection**: Any process accessing lsass.exe with PROCESS_VM_READ permission. Known tool signatures (mimikatz in memory, comsvcs.dll MiniDump callsite). Credential Guard bypass attempts.
- **Mitigation**: Enable Windows Credential Guard, configure LSASS as Protected Process Light (PPL), monitor for LSASS access via Sysmon.

**T1053.005 -- Scheduled Task (Persistence + Execution)**

Adversary creates or modifies scheduled tasks to execute code at system startup, login, or on a schedule.

- **Procedure**: `schtasks /create /tn "UpdateTask" /tr "powershell -enc ..." /sc onlogon`, COM-based task creation.
- **Data sources**: Windows Event ID 4698 (Task created), Sysmon EventID 1, Task Scheduler operational log.
- **Detection**: Task creation by non-standard users, tasks with encoded commands, tasks pointing to temp directories or writable paths, tasks created via command line rather than GUI.

**T1021.002 -- SMB/Windows Admin Shares (Lateral Movement)**

Adversary uses Windows administrative shares (C$, ADMIN$, IPC$) to move laterally.

- **Procedure**: `net use \\target\C$ /user:domain\admin password`, PsExec, WMI via DCOM.
- **Data sources**: Windows Event ID 5140 (Network share accessed), Event ID 5145 (Detailed file share auditing), Sysmon EventID 3 (Network connection).
- **Detection**: Access to admin shares (C$, ADMIN$) from non-admin workstations, lateral movement tools (PsExec service creation Event ID 7045), authentication from unusual sources.

**T1486 -- Data Encrypted for Impact (Impact)**

Adversary encrypts data on target systems to extort payment (ransomware).

- **Procedure**: Mass file encryption with ransom note drop, volume shadow copy deletion (`vssadmin delete shadows`), disabling recovery options.
- **Data sources**: File modification events (mass rename with new extension), Sysmon EventID 11 (File creation -- ransom notes), process creation (vssadmin.exe, wbadmin.exe, bcdedit.exe).
- **Detection**: High-frequency file rename/modification events, known ransomware file extensions, shadow copy deletion commands, bulk file entropy increase.

## Patterns

### Pattern 1: Building an Adversary Emulation Plan

```
Step 1: Select threat actor based on organizational threat model
  - Industry: Financial services --> APT38 (Lazarus Group), FIN7, Scattered Spider
  - Industry: Healthcare --> APT41, FIN12 (ransomware)
  - Industry: Government --> APT29 (Cozy Bear), APT28 (Fancy Bear)

Step 2: Gather TTPs from public intelligence
  - MITRE ATT&CK Groups: https://attack.mitre.org/groups/
  - Filter techniques by confidence (observed > assessed > inferred)

Step 3: Build the technique chain
  - Select one technique per tactic phase (minimum viable chain)
  - Ensure the chain is logically coherent (each phase enables the next)

Step 4: Map each technique to:
  - Detection data source
  - Expected detection rule
  - Atomic Red Team test (if available)
  - CALDERA ability (if using automated emulation)

Step 5: Document as a phased operation plan
```

### Pattern 2: ATT&CK Navigator Layer Format

```json
{
  "name": "APT29 - Emulation Plan",
  "versions": {
    "attack": "15",
    "navigator": "5.0",
    "layer": "4.5"
  },
  "domain": "enterprise-attack",
  "description": "APT29 TTPs for adversary emulation",
  "techniques": [
    {
      "techniqueID": "T1566.001",
      "tactic": "initial-access",
      "color": "#ff6666",
      "comment": "Spearphishing with macro-enabled documents",
      "score": 100
    },
    {
      "techniqueID": "T1059.001",
      "tactic": "execution",
      "color": "#ff6666",
      "comment": "PowerShell for payload execution and C2",
      "score": 100
    },
    {
      "techniqueID": "T1003.001",
      "tactic": "credential-access",
      "color": "#ff6666",
      "comment": "LSASS memory dump via custom tool",
      "score": 100
    }
  ],
  "gradient": {
    "colors": ["#ffffff", "#ff6666"],
    "minValue": 0,
    "maxValue": 100
  }
}
```

### Pattern 3: Atomic Red Team Test Execution

```bash
# Install Atomic Red Team (PowerShell, authorized test environment only)
IEX (IWR 'https://raw.githubusercontent.com/redcanaryco/invoke-atomicredteam/master/install-atomicredteam.ps1' -UseBasicParsing)
Install-AtomicRedTeam -getAtomics

# List tests for a specific technique
Invoke-AtomicTest T1059.001 -ShowDetailsBrief

# Execute a specific test (AUTHORIZED ENVIRONMENT ONLY)
Invoke-AtomicTest T1059.001 -TestNumbers 1

# Clean up after test
Invoke-AtomicTest T1059.001 -TestNumbers 1 -Cleanup
```

## Anti-Patterns

- **Using ATT&CK as a checklist**: ATT&CK is not a compliance checklist. Having a detection for every technique is not realistic or necessary. Prioritize based on threat intelligence relevant to your organization.
- **Focusing on technique count over detection quality**: One high-fidelity detection for T1003.001 is worth more than ten noisy, false-positive-prone detections for less critical techniques.
- **Ignoring sub-techniques**: T1059 (Command and Scripting Interpreter) has nine sub-techniques. The detection for T1059.001 (PowerShell) is completely different from T1059.004 (Unix Shell). Sub-techniques matter.
- **Red teaming without blue team integration**: A red team exercise that does not result in improved detections is an expensive penetration test. Ensure findings flow to detection engineering.
- **Attributing TTPs to actors without evidence**: Saying "this looks like APT29" requires evidence. Stick to technique identification without attribution unless intelligence supports it.

## References

- MITRE ATT&CK Enterprise Matrix: https://attack.mitre.org/matrices/enterprise/
- MITRE ATT&CK Groups: https://attack.mitre.org/groups/
- MITRE ATT&CK Navigator: https://mitre-attack.github.io/attack-navigator/
- Atomic Red Team: https://github.com/redcanaryco/atomic-red-team
- MITRE CALDERA: https://caldera.mitre.org/
- MITRE CTI Repository (STIX): https://github.com/mitre/cti
- ATT&CK Data Sources: https://attack.mitre.org/datasources/
