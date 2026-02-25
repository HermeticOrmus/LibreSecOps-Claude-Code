# Defense Strategies

> Technical and human defense controls for preventing, detecting, and responding to social engineering attacks across all channels.

## Knowledge Base

### Defense-in-Depth Model for Social Engineering

Social engineering defense requires layered controls because no single control stops all attacks. The layers work together:

```
Layer 1: Perimeter (prevent delivery)
  Email filtering, URL filtering, phone call screening

Layer 2: Technical enforcement (prevent exploitation)
  MFA, conditional access, email authentication (DMARC)

Layer 3: Human detection (recognize attacks)
  Awareness training, verification procedures, reporting culture

Layer 4: Process controls (prevent impact)
  Dual authorization for financial transfers, callback verification

Layer 5: Response (minimize damage)
  Incident response, account lockout, forensic analysis
```

### Technical Controls

**Email Authentication (prevent domain spoofing)**

| Control | Purpose | Implementation |
|---------|---------|---------------|
| SPF | Authorize sending servers | DNS TXT record listing authorized IPs |
| DKIM | Cryptographic email signing | Public key in DNS, signing by mail server |
| DMARC | Policy enforcement for SPF/DKIM failures | DNS TXT record with policy (none/quarantine/reject) |

DMARC progression:
1. `p=none` -- Monitor mode, collect reports
2. `p=quarantine` -- Send failures to spam
3. `p=reject` -- Block failures entirely

```
# Strong DMARC record
_dmarc.example.com. TXT "v=DMARC1; p=reject; rua=mailto:dmarc-reports@example.com; ruf=mailto:dmarc-forensics@example.com; pct=100"
```

DMARC limitations: Does not prevent display name spoofing, lookalike domains, or compromised legitimate accounts.

**Email filtering and security**:
- Anti-phishing engines (ML-based content analysis, URL reputation, sender reputation)
- URL rewriting and time-of-click analysis (URLs scanned when clicked, not just on delivery)
- Attachment sandboxing (detonation in isolated environment before delivery)
- Impersonation protection (flagging emails that spoof internal display names)
- External email tagging (`[EXTERNAL]` banner on emails from outside the organization)
- QR code scanning in attachments (defense against quishing)

**Multi-Factor Authentication**:

| MFA Type | Phishing Resistant? | Notes |
|----------|-------------------|-------|
| SMS OTP | No | Vulnerable to SIM swapping, SS7 interception, AiTM |
| TOTP (authenticator app) | No | Vulnerable to AiTM real-time proxy |
| Push notification | Partially | Vulnerable to MFA fatigue attacks (spam pushing) |
| Push with number matching | Partially | Better than basic push, still vulnerable to AiTM |
| FIDO2/WebAuthn (hardware key) | Yes | Cryptographically bound to origin, prevents AiTM |
| Passkeys | Yes | Device-bound, phishing resistant |

For high-risk roles (executives, finance, IT admins), deploy FIDO2 hardware keys or passkeys.

**Conditional Access Policies** (Azure AD / Entra ID, Okta):
- Require MFA for all sign-ins (minimum)
- Block legacy authentication protocols (they bypass MFA)
- Require compliant/managed devices for access to sensitive resources
- Location-based policies (flag or block sign-ins from unusual locations)
- Risk-based policies (Microsoft Entra Identity Protection, Okta ThreatInsight)
- Session lifetime limits (reduce the value of stolen session tokens)

**URL and Web Filtering**:
- Block known malicious domains (threat intel feeds)
- Block newly registered domains (< 30 days old, commonly used for phishing)
- Block categorized threats (malware, phishing, command and control)
- SSL inspection for encrypted traffic analysis (with privacy considerations)
- Browser isolation for risky or uncategorized sites

**Phone Security**:
- Caller ID authentication (STIR/SHAKEN framework)
- Call screening for incoming calls to high-risk lines (reception, finance)
- Recording and monitoring for customer-facing lines
- Callback verification procedures (do not trust inbound caller identity)

### Human Controls

**Verification Procedures**:

| Request Type | Verification Method | Threshold |
|-------------|-------------------|-----------|
| Wire transfer / payment change | Callback to known number + dual authorization | All transfers |
| Password reset | Identity verification via separate channel | All resets |
| Access request | Manager approval via ticketing system | All requests |
| Vendor change (bank details) | Callback to vendor on existing known number | All changes |
| Executive request (urgent) | Callback to executive on known number | All requests |

**Reporting Infrastructure**:
- One-click phishing report button in email client (KnowBe4, Proofpoint, Microsoft)
- Security hotline for phone-based reports
- Slack/Teams channel for real-time security questions
- Anonymous reporting option for sensitive concerns
- Automated triage of reported phishing (SOC integration)
- Feedback loop: Tell reporters what happened with their report

**Security Champion Program**:
- 1 champion per 50-100 employees
- Monthly training for champions (deeper than general awareness)
- Champions serve as first point of contact for security questions
- Champions participate in incident response communication
- Champions provide feedback to security team on program effectiveness

### Response Procedures

**Phishing Incident Response**:
1. **Contain**: Disable compromised account, revoke sessions, block malicious URLs/IPs
2. **Assess**: Determine what the user did (clicked link, entered credentials, downloaded attachment)
3. **Remediate**: Reset credentials, scan endpoint, verify MFA not compromised
4. **Investigate**: Search for other recipients, check for lateral movement from compromised account
5. **Communicate**: Alert other users if the phishing affects many recipients
6. **Learn**: Add indicators to detection systems, update awareness training

**BEC Incident Response**:
1. **Immediate**: Contact bank to attempt wire recall (time-critical, success rate drops after 24 hours)
2. **Legal**: File FBI IC3 report, notify law enforcement, engage legal counsel
3. **Technical**: Analyze compromised email account, check email rules for forwarding/deletion
4. **Process**: Review and strengthen payment verification procedures
5. **Communication**: Notify affected parties as required by regulation

**Compromised Credentials Response**:
1. Force password reset on all accounts using the compromised credential
2. Revoke all active sessions (OAuth tokens, browser sessions, API keys)
3. Review account activity for unauthorized actions during compromise window
4. Check for persistence (mail rules, OAuth app grants, MFA changes)
5. Monitor for credential reuse across other services

## Patterns

### Pattern: Layered Email Defense
Layer 1: DMARC reject (blocks domain spoofing)
Layer 2: External email banner (flags non-internal emails)
Layer 3: AI-based content analysis (detects social engineering language)
Layer 4: URL rewriting + time-of-click scanning (catches evolving threats)
Layer 5: User reporting + SOC triage (catches what technology misses)

### Pattern: Financial Transaction Verification
For all financial transactions above a threshold:
1. Request received via any channel (email, phone, in-person)
2. Dual authorization required (two people must approve)
3. Callback verification to the requester on a known-good number
4. Cool-down period for first-time or changed payment details
5. Audit trail for all steps

### Pattern: Assume Compromise
Design processes assuming that some credentials will be phished:
- MFA on everything (minimum: push with number matching)
- Conditional access requiring managed devices
- Short session lifetimes for sensitive applications
- Anomaly detection for account usage patterns
- Network segmentation limiting blast radius

## Anti-Patterns

- **DMARC p=none forever**: Monitor mode provides visibility but zero protection. Progress to p=reject within 3-6 months
- **MFA = done**: SMS MFA provides minimal protection against modern phishing. Upgrade to phishing-resistant factors for high-risk accounts
- **Training without testing**: Awareness training without phishing simulations is theory without practice. Simulations are the practical component
- **Blaming users for clicking**: This destroys reporting culture. If 5% of employees click a phishing link, that is a filter/training/process problem, not 5% bad employees
- **No process for the report button**: Deploying a phishing report button without SOC triage means reports go into a void. Users stop reporting when nothing happens
- **One-time awareness**: Annual training satisfies compliance but does not maintain awareness. Monthly micro-training and quarterly simulations maintain behavioral change
- **Over-reliance on technology**: The best email filter in the world cannot stop a phone call. Multi-channel defense requires both technical and human controls

## References

- NIST SP 800-177 Rev. 1: Trustworthy Email -- https://csrc.nist.gov/publications/detail/sp/800-177/rev-1/final (SPF, DKIM, DMARC guidance)
- CISA: Phishing Guidance: Stopping the Attack Cycle at Phase One -- https://www.cisa.gov/sites/default/files/2023-10/Phishing-Guidance-Stopping-the-Attack-Cycle-at-Phase-One.pdf
- Microsoft: Protect against phishing attacks -- https://learn.microsoft.com/en-us/microsoft-365/security/office-365-security/anti-phishing-protection
- FIDO Alliance: Phishing-Resistant Authentication -- https://fidoalliance.org/
- STIR/SHAKEN (caller ID authentication) -- https://www.fcc.gov/call-authentication
- SANS Security Awareness Deployment Guide -- https://www.sans.org/security-awareness-training/
- Verizon DBIR -- annual report on social engineering trends
- FBI IC3 BEC Guidance -- https://www.ic3.gov/
