# /harden

> Generate a security hardening checklist and configuration guide for a specified target platform.

## Trigger

Use this command when:
- Setting up a new server, container, or cloud environment
- Preparing systems for production deployment
- Responding to a security audit finding about weak configurations
- Post-incident hardening to prevent recurrence
- Periodic security review of system configurations

## Input

Required:
- **Target**: Platform to harden (e.g., `ubuntu-22.04`, `rhel-9`, `docker`, `kubernetes`, `nginx`, `postgresql`, `aws`, `windows-server-2022`)

Optional:
- **Profile**: `level-1` (practical security) or `level-2` (defense-in-depth). Defaults to `level-1`.
- **Role**: System role that may exclude certain controls (e.g., `web-server`, `database`, `ci-runner`, `workstation`)
- **Existing config**: Path to current configuration files for delta analysis

## Process

### Step 1: Platform Identification

1. Confirm the target platform and version
2. Select the applicable CIS Benchmark or vendor hardening guide
3. Determine the appropriate profile level
4. Identify the system's role to filter irrelevant controls

### Step 2: Control Selection

Group controls by category and priority:

**Category 1: Initial Setup**
- Filesystem configuration (partitioning, mount options)
- Software updates and patch management
- Bootloader configuration
- Process hardening (ASLR, DEP, core dumps)

**Category 2: Services**
- Disable unnecessary services
- Configure required services securely
- Remove unnecessary packages

**Category 3: Network Configuration**
- Firewall rules (deny by default, allow by exception)
- Network parameters (IP forwarding, source routing, ICMP redirects)
- TCP wrappers or equivalent access control
- IPv6 configuration (disable if not used)

**Category 4: Logging and Auditing**
- System logging configuration (syslog/journald)
- Audit system configuration (auditd/Windows Audit Policy)
- Log rotation and retention
- Log forwarding to centralized SIEM

**Category 5: Access and Authentication**
- SSH/RDP configuration
- Password policy (PAM/Group Policy)
- Account management (disable unused accounts, set expiry)
- Privilege escalation controls (sudo/UAC)
- File and directory permissions

**Category 6: System Maintenance**
- File integrity monitoring
- Automatic security updates
- Backup configuration
- Time synchronization (NTP/chrony)

### Step 3: Generate Hardening Guide

For each selected control:
1. State what needs to be configured
2. Provide the exact implementation command(s)
3. Provide the verification command
4. Explain what attack the control prevents
5. Note any operational impact
6. Include rollback instructions

### Step 4: Automation

Generate an automation script or playbook (Ansible-style) that applies all recommended controls.

## Output

```
# Security Hardening Guide

**Target**: [platform and version]
**Profile**: CIS Level [1|2]
**Role**: [system role]
**Date**: [generated date]

## Priority Summary
| Priority | Controls | Estimated Time |
|----------|----------|---------------|
| Critical | [n] | [time] |
| Important | [n] | [time] |
| Optional | [n] | [time] |

## Pre-Hardening Checklist
[ ] Backup current configuration
[ ] Document current state
[ ] Schedule maintenance window
[ ] Prepare rollback plan

## Hardening Controls

### [Category]
[Controls with implementation, verification, and rollback]

## Post-Hardening Verification
[Script or checklist to verify all controls]

## Ongoing Maintenance
[How to maintain hardened state: drift detection, automated compliance checks]
```
