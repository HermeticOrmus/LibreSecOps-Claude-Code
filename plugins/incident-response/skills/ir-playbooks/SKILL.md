# Incident Response Playbooks

> Playbook templates for common security incident types, providing step-by-step response procedures for each phase of incident handling.

## Knowledge Base

### Playbook Structure

Every playbook follows the same four-phase structure from NIST SP 800-61:

1. **Detection & Validation** -- Confirm the incident is real, classify it
2. **Containment** -- Stop the spread, limit damage
3. **Eradication & Recovery** -- Remove the threat, restore operations
4. **Post-Incident** -- Document, learn, improve

### Playbook 1: Malware Infection

**Indicators**:
- Antivirus/EDR alert on malicious file or behavior
- Unusual process execution (PowerShell encoding, living-off-the-land binaries)
- Unexpected network connections to known bad IPs/domains
- System performance degradation, unexpected file encryption
- User reports of unusual system behavior

**Detection & Validation**:
1. Verify the alert is not a false positive (check file hash against VirusTotal, check process lineage)
2. Identify the malware type: dropper, RAT, ransomware, cryptominer, wiper, worm
3. Determine the infection vector: email attachment, drive-by download, USB, lateral movement
4. Assess scope: single system or multiple systems?
5. Check for lateral movement indicators (SMB connections, RDP sessions, credential dumping artifacts)

**Containment**:
1. **Immediate**: Isolate the infected system from the network (disable network adapter or move to quarantine VLAN). Do NOT power off -- preserve memory evidence.
2. Collect volatile evidence: memory dump, process list, network connections, logged-in sessions
3. Block known IOCs at network perimeter (firewall rules for C2 IPs/domains)
4. Block file hashes in EDR/antivirus across the organization
5. Identify and isolate other potentially infected systems
6. Disable affected user accounts if credential compromise is suspected
7. Block lateral movement: disable admin shares, restrict RDP, enable enhanced authentication logging

**Eradication & Recovery**:
1. Identify and remove all malware artifacts: files, registry keys, scheduled tasks, services, startup items
2. If rootkit suspected, reimage from known-good media rather than attempting cleanup
3. Reset credentials for all accounts that were active on compromised systems
4. Patch the vulnerability that allowed initial infection
5. Restore data from clean backups if needed (verify backup integrity first)
6. Rebuild or reimage affected systems from gold images
7. Monitor recovered systems closely for 30 days

**Post-Incident**:
- Extract and share IOCs with threat intelligence platforms
- Update detection rules based on observed TTPs
- Review email filtering, endpoint protection, and user training effectiveness
- Document the infection vector for awareness training

### Playbook 2: Account Compromise

**Indicators**:
- Impossible travel (logins from geographically distant locations in short time)
- Login from known malicious IP addresses or TOR exit nodes
- Successful login after multiple failures from unusual location
- Account activity at unusual hours
- Password reset or MFA change not initiated by the user
- Phishing email reported by the user followed by credential entry

**Detection & Validation**:
1. Confirm the login is unauthorized (contact the account owner through a verified channel -- phone, not email)
2. Review authentication logs: source IPs, user agents, timestamps, success/failure patterns
3. Determine the compromise method: phishing, credential stuffing, session hijacking, MFA bypass
4. Assess what the attacker accessed: emails, files, admin functions, other user data
5. Check for persistence: password changes, MFA enrollment, OAuth app authorizations, API key generation, mail forwarding rules

**Containment**:
1. **Immediate**: Disable the compromised account or force sign-out of all sessions
2. Reset the account password and revoke all active tokens/sessions
3. Remove any unauthorized MFA devices, OAuth applications, or API keys
4. Remove mail forwarding rules, delegated access, or inbox rules created by the attacker
5. If the compromised account has admin privileges, audit all administrative actions performed
6. Block the attacker's source IP addresses (but note these may be VPNs or compromised hosts)

**Eradication & Recovery**:
1. Assist the user in setting a new, strong password through a verified channel
2. Re-enroll MFA through verified identity process
3. Review and revoke unnecessary OAuth/API access
4. Check for data exfiltration (downloaded files, forwarded emails, API data access)
5. If admin account: audit all changes made during compromise period, revert unauthorized changes
6. Scan the user's device for malware if phishing-based compromise

**Post-Incident**:
- Review why phishing was successful (email filtering, URL scanning, user training)
- Assess password policy adequacy
- Evaluate MFA strength and phishing-resistance
- Update credential stuffing defenses

### Playbook 3: Data Breach

**Indicators**:
- Detection of unauthorized data access or exfiltration
- Large data transfers to unexpected destinations
- Database queries with unusual scope or volume
- Notification from external party of data exposure
- Data found on dark web or paste sites

**Detection & Validation**:
1. Determine what data was accessed or exfiltrated (PII, financial, health, credentials, IP)
2. Determine the scope: how many records, which data fields, which time period
3. Identify the exfiltration method: network transfer, email, removable media, API abuse
4. Determine if exfiltration is ongoing or historical
5. Identify the data classification level to determine regulatory obligations

**Containment**:
1. **Immediate**: Block the exfiltration channel (network rules, disable compromised account, revoke API keys)
2. Preserve evidence: network captures, database query logs, access logs, file access logs
3. Identify all affected data stores and secure them (change credentials, restrict access)
4. Engage legal counsel immediately (attorney-client privilege, regulatory obligations)
5. Begin regulatory notification timeline clock (GDPR: 72 hours from awareness)
6. Do NOT publicly disclose until legal counsel has been consulted

**Eradication & Recovery**:
1. Close the access vector that enabled the breach
2. Rotate all credentials for affected data stores
3. Implement additional access controls and monitoring
4. If exposed data includes credentials, force password resets for affected users
5. If exposed data includes payment cards, notify payment processor
6. Prepare breach notification communications (legal review required)

**Post-Incident**:
- File regulatory notifications within required timelines
- Prepare customer notification with clear information about what happened, what was exposed, and what they should do
- Review data access controls, monitoring, and classification
- Consider credit monitoring services for affected individuals if PII was exposed

### Playbook 4: Ransomware

**Indicators**:
- Files encrypted with unusual extensions
- Ransom notes appearing on systems
- Mass file modification events in short time period
- Shadow copy deletion (vssadmin delete shadows)
- EDR alerts for ransomware behavior patterns

**Detection & Validation**:
1. Identify the ransomware variant (ransom note format, file extension, behavioral patterns)
2. Determine scope: how many systems are affected, is encryption still spreading?
3. Check for data exfiltration BEFORE encryption (double extortion)
4. Identify patient zero: which system was first infected?
5. Determine initial access vector: phishing, RDP exposure, vulnerability exploitation

**Containment**:
1. **CRITICAL**: Disconnect all affected systems from the network IMMEDIATELY. Speed is essential -- ransomware spreads laterally within minutes.
2. Disconnect shared storage (NAS, SAN, network drives) from the network
3. Disable remote access (VPN, RDP) until scope is understood
4. Preserve at least one encrypted system for forensics (do not reimage all systems)
5. Check backup integrity: are backups accessible? Are they encrypted too? Are they offline/air-gapped?
6. Engage legal counsel regarding ransom payment decisions (this is a business and legal decision, not a security decision)

**Eradication & Recovery**:
1. Identify and close the initial access vector
2. Check for backdoors and persistence mechanisms left by the attacker
3. Assess backup availability and integrity for all affected systems
4. Restore from backups in priority order (most critical services first)
5. Rebuild systems that cannot be restored from backups
6. Scan all systems for dormant ransomware components before reconnecting to the network
7. Reset all domain credentials (attackers often have domain admin before deploying ransomware)

**Post-Incident**:
- Assess whether ransom payment is warranted (law enforcement discourages it; decryption tools may be available for known variants)
- Review backup strategy: are backups offline/air-gapped? Tested regularly?
- Review network segmentation: could lateral movement have been prevented?
- Review endpoint detection: could encryption behavior have been detected earlier?

### Playbook 5: DDoS Attack

**Indicators**:
- Service degradation or unavailability
- Massive spike in inbound traffic or connection attempts
- Resource exhaustion (CPU, memory, bandwidth, connection pools)
- Traffic from unusual geographic regions or known botnet IPs

**Detection & Validation**:
1. Confirm it's an attack, not a legitimate traffic spike (marketing event, viral content)
2. Classify the attack type: volumetric (bandwidth), protocol (SYN flood, UDP flood), application-layer (HTTP flood, Slowloris)
3. Identify attack sources: single source (DoS) or distributed (DDoS)
4. Determine if the DDoS is a smokescreen for another attack (check for concurrent unusual activity)

**Containment**:
1. Activate DDoS mitigation service (Cloudflare, AWS Shield, Akamai) if available
2. Implement rate limiting at load balancer/CDN level
3. Block attack traffic by source IP, geographic region, or traffic pattern if identifiable
4. Scale infrastructure if cloud-hosted (add capacity to absorb the attack)
5. If application-layer: implement CAPTCHA, JavaScript challenges, or behavioral analysis
6. Communicate service status to users (status page update)

**Eradication & Recovery**:
1. DDoS attacks typically stop when the attacker stops. Maintain mitigation until attack subsides.
2. Analyze attack patterns for future prevention rules
3. Review and optimize DDoS mitigation configuration
4. Restore full service access once attack is confirmed stopped
5. Monitor for attack resumption

**Post-Incident**:
- Review DDoS protection architecture and capacity
- Implement or improve rate limiting and traffic filtering
- Establish relationships with ISP and DDoS mitigation providers before the next attack
- Create a DDoS response runbook with pre-authorized mitigation steps

### Playbook 6: Insider Threat

**Indicators**:
- Unusual data access patterns (accessing files outside normal role)
- Large data downloads or transfers to external storage
- Access to systems outside working hours
- Attempts to circumvent security controls
- Use of unauthorized tools or services
- Resignation or termination combined with unusual system activity

**Detection & Validation**:
1. Validate the activity is unauthorized (confirm with management, check against approved access)
2. Determine if the activity is malicious or negligent
3. Engage HR and legal counsel before confronting the individual
4. Document all evidence with timestamps and chain of custody (may be needed for legal/HR proceedings)
5. Do NOT alert the subject that they are being investigated

**Containment**:
1. Do NOT revoke access immediately if investigation is ongoing (may alert the subject)
2. Increase monitoring on the subject's accounts and devices
3. If immediate risk: coordinate with HR for simultaneous account disable and physical access revocation
4. Preserve email, file access logs, and system activity for the investigation period
5. Restrict access to sensitive systems if possible without alerting (role change justification)

**Eradication & Recovery**:
1. Upon HR/legal authorization: disable all accounts simultaneously
2. Revoke physical access (badges, keys)
3. Collect company-owned devices
4. Change shared credentials the individual had access to
5. Review and revoke the individual's access to third-party services
6. Audit all actions performed by the individual during the relevant period

## Patterns

### Universal Response Actions (All Incident Types)

1. Document everything with UTC timestamps
2. Preserve evidence before taking destructive containment actions
3. Communicate early and often with defined stakeholders
4. Coordinate with legal counsel for incidents involving data exposure, regulatory obligations, or law enforcement
5. Never communicate attribution publicly until confirmed by forensic analysis
6. Track all actions with owners and completion status

### Escalation Criteria

Escalate to next severity level when:
- The incident affects more systems/users than initially assessed
- Data exposure is confirmed
- The attacker demonstrates persistence or advanced capabilities
- Business impact exceeds initial assessment
- Regulatory notification thresholds are met
- Media attention is likely or occurring

## Anti-Patterns

- **Panic-driven response**: Rebooting systems, reformatting drives, or disabling accounts without preserving evidence first
- **Solo response**: One person handling an incident alone. Incidents require multiple roles: commander, technical, communications, scribe.
- **Delayed communication**: Waiting until "we know more" to notify stakeholders. Communicate what you know, when you know it.
- **Blame-first culture**: Looking for someone to blame during the incident. This causes people to hide information. Conduct blameless postmortems.
- **Paying ransom without preparation**: Paying ransomware demands without involving legal counsel, law enforcement, or verifying decryption capability
- **Declaring victory too early**: Closing the incident before confirming eradication. Attackers frequently maintain backup access.
- **Not following up**: Identifying action items in the postmortem but never completing them. Track action items to completion.

## References

- [NIST SP 800-61 r2 - Computer Security Incident Handling Guide](https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final)
- [SANS Incident Handler's Handbook](https://www.sans.org/white-papers/33901/)
- [FIRST (Forum of Incident Response and Security Teams)](https://www.first.org/)
- [CISA Incident Response Playbooks](https://www.cisa.gov/sites/default/files/publications/Federal_Government_Cybersecurity_Incident_and_Vulnerability_Response_Playbooks_508C.pdf)
- [RFC 3227 - Guidelines for Evidence Collection and Archiving](https://datatracker.ietf.org/doc/html/rfc3227)
- [MITRE ATT&CK - Threat Intelligence for IR](https://attack.mitre.org/)
