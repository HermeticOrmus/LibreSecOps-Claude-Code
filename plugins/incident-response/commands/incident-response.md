# /incident-response

> Activate an incident response playbook for a reported security event, guiding through triage, containment, and initial response.

## Trigger

Use this command when:
- A security alert fires from monitoring/SIEM
- Suspicious activity is reported by a user or team member
- A vulnerability is discovered to be actively exploited
- A third party notifies you of a breach involving your systems
- Automated detection systems flag anomalous behavior

## Input

Required:
- **Indicator**: What was observed (alert details, user report, suspicious behavior)

Optional:
- **Affected system(s)**: What systems or services are involved
- **Time of observation**: When the indicator was first noticed
- **Actions already taken**: Any steps already performed
- **Incident type hint**: `malware`, `breach`, `account-compromise`, `ddos`, `ransomware`, `insider`, `supply-chain`, `phishing`

## Process

### Step 1: Triage

1. **Validate the alert**: Is this a real incident or a false positive? Check for known benign causes.
2. **Classify the incident type**: Match indicators to incident categories
3. **Assess scope**: How many systems/users are affected? Is it contained or spreading?
4. **Determine severity**: Using the severity matrix:

| Severity | Criteria |
|----------|----------|
| SEV1 - Critical | Active data exfiltration, ransomware deployment, complete service outage, safety risk |
| SEV2 - High | Confirmed compromise, active attacker presence, significant service degradation |
| SEV3 - Medium | Suspected compromise, potential data exposure, partial service impact |
| SEV4 - Low | Security event, policy violation, no confirmed compromise |

5. **Activate the appropriate playbook**: Select from IR Playbooks skill based on incident type

### Step 2: Initial Response

1. **Assign roles**: Incident Commander, Technical Lead, Communications Lead, Scribe
2. **Open communications channel**: Dedicated Slack channel, war room, or bridge call
3. **Start the timeline**: Document everything with UTC timestamps from this point forward
4. **Notify stakeholders**: Based on severity level:
   - SEV1: CISO, CTO, Legal, PR, all affected team leads
   - SEV2: Security leadership, affected team leads
   - SEV3: Security team lead
   - SEV4: Logged, monitored

### Step 3: Containment

Short-term containment (stop the bleeding):
- Isolate affected systems (network quarantine, disable accounts)
- Block known malicious indicators (IPs, domains, hashes)
- Revoke compromised credentials
- Enable enhanced logging on affected and adjacent systems

Evidence-aware containment:
- Before isolating, collect volatile evidence if time permits (memory dump, process list, network connections)
- Document the state of systems before containment actions
- Hash any evidence collected

Long-term containment (if eradication requires time):
- Move affected systems to isolated VLAN
- Deploy additional monitoring
- Implement temporary access controls
- Prepare clean systems for failover

### Step 4: Eradication

Based on incident type:
- Remove malware and attacker tools
- Close the initial access vector (patch vulnerability, disable compromised account)
- Remove persistence mechanisms (scheduled tasks, registry keys, SSH keys, backdoor accounts)
- Reset all credentials that may have been compromised
- Verify eradication across all affected systems

### Step 5: Recovery

1. Restore from known-good backups or rebuild systems
2. Verify system integrity before returning to production
3. Monitor recovered systems closely for re-compromise
4. Restore services in priority order (most critical first)
5. Confirm with stakeholders before declaring recovery complete

### Step 6: Post-Incident

1. Schedule post-incident review within 48-72 hours
2. Assign action items for systemic improvements
3. Update playbooks based on lessons learned
4. Archive evidence per retention policy
5. File regulatory notifications if required (GDPR: 72 hours, HIPAA: 60 days)

## Output

```
# Incident Response Activation

## Incident: [ID]
## Severity: SEV[1-4]
## Type: [classification]
## Status: [Triage | Containment | Eradication | Recovery | Resolved]

## Situation Summary
[What happened, what we know, what we don't know]

## Immediate Actions
[ ] [Action 1 - Owner - Deadline]
[ ] [Action 2 - Owner - Deadline]
[ ] [Action 3 - Owner - Deadline]

## Containment Plan
[Specific containment steps for this incident type]

## Evidence Collection Priority
[What evidence to collect before containment, in order of volatility]

## Communication Plan
[Who needs to be notified, when, and what to tell them]

## Applicable Playbook
[Reference to specific playbook from IR Playbooks skill]
```
