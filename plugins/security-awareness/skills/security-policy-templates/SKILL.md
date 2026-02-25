# Security Policy Templates

> Reference templates and frameworks for common security policies with guidance on customization, enforcement, and regulatory alignment.

## Knowledge Base

### Policy Hierarchy

Security documentation follows a hierarchy from abstract to specific:

```
Policies (WHAT must be done - approved by leadership)
  └─ Standards (HOW to comply - specific requirements)
       └─ Procedures (STEP-BY-STEP - operational instructions)
            └─ Guidelines (RECOMMENDATIONS - best practices, optional)
```

**Policies** are mandatory, approved by senior management, and change infrequently. They state requirements without prescribing specific technologies.

**Standards** define specific technical requirements that implement policies. They reference specific technologies, configurations, and metrics.

**Procedures** provide step-by-step operational instructions for carrying out standards. They are the most frequently updated documents.

**Guidelines** are recommendations and best practices. They are not mandatory but represent organizational wisdom.

### Essential Policy Set

Every organization needs these core policies as a minimum:

| Policy | Purpose | Key Content |
|--------|---------|-------------|
| Acceptable Use | Defines acceptable use of organizational IT resources | Permitted/prohibited activities, personal use limits, monitoring notice |
| Information Classification | Defines data sensitivity levels and handling requirements | Classification levels, labeling, handling, sharing, disposal by level |
| Access Control | Governs who gets access to what and how | Least privilege, need-to-know, account lifecycle, privileged access |
| Incident Reporting | Defines how to report security events | What to report, how to report, when to report, who to contact |
| Password/Authentication | Defines credential requirements | Length, complexity, MFA requirements, storage, sharing prohibition |
| Data Retention & Disposal | Defines how long data is kept and how it is destroyed | Retention schedules by data type, secure disposal methods |
| Remote Work | Governs security for remote/hybrid workers | VPN, device security, physical workspace, network requirements |

### Acceptable Use Policy Template

**Core sections**:

1. **General use and ownership**: Company owns the systems, may monitor usage, users have no expectation of privacy on company systems
2. **Acceptable use**: Business purposes, incidental personal use if permitted, professional conduct standards
3. **Prohibited use**: Illegal activity, unauthorized access attempts, circumventing security controls, installing unauthorized software, sharing credentials, accessing inappropriate content, cryptocurrency mining, unauthorized data exfiltration
4. **Email and communications**: No forwarding company data to personal accounts, caution with attachments, phishing awareness, reporting suspicious emails
5. **Internet use**: Web filtering acknowledgment, no proxy/VPN to bypass filters, download restrictions, social media guidelines
6. **Mobile devices**: BYOD vs company-issued, MDM requirements, remote wipe consent, approved app stores
7. **Enforcement**: Monitoring disclosure, violation consequences, reporting obligations

### Incident Reporting Policy Template

**Core sections**:

1. **What to report** (concrete examples):
   - Suspected phishing emails or calls
   - Unusual system behavior or pop-ups
   - Lost or stolen devices containing company data
   - Unauthorized access to systems or data
   - Discovery of sensitive data in unauthorized locations
   - Suspected malware infection
   - Physical security breaches (tailgating, unauthorized visitors)

2. **How to report**:
   - Primary channel (security hotline, email, ticketing system)
   - After-hours/emergency channel
   - What information to include (when, what, who, impact estimate)

3. **When to report**:
   - Immediately upon discovery or suspicion
   - Do not investigate independently
   - Do not attempt to "fix" the issue before reporting
   - When in doubt, report (better to over-report than under-report)

4. **Protection for reporters**:
   - No retaliation for good-faith reports
   - Reports handled confidentially
   - No penalties for reporting personal mistakes (clicking phishing link)

### Information Classification Template

**Standard classification levels**:

| Level | Definition | Examples | Handling |
|-------|-----------|----------|---------|
| Public | Approved for external distribution | Marketing materials, published research | No restrictions |
| Internal | For organizational use only | Org charts, internal memos, policies | Do not share externally |
| Confidential | Restricted to authorized personnel | Financial data, customer PII, HR records | Encrypted storage/transit, access logging |
| Restricted | Highest sensitivity | Trade secrets, M&A data, incident reports | Need-to-know, encrypted, audit trail, DLP |

**Handling requirements by level**:

| Action | Internal | Confidential | Restricted |
|--------|----------|-------------|------------|
| Storage | Company systems | Encrypted at rest | Encrypted, access-controlled |
| Transmission | Company email | Encrypted email/portal | Encrypted with recipient verification |
| Printing | Collect promptly | Collect immediately, shred when done | Do not print unless essential |
| Disposal | Recycle bin | Secure shredding | Cross-cut shredding, certified destruction |
| Sharing | Internal only | Authorized personnel, NDA if external | Named individuals, approval required |

### Regulatory Mapping

**Policy requirements by regulation**:

| Policy Area | GDPR | HIPAA | PCI-DSS | SOC 2 |
|-------------|------|-------|---------|-------|
| Access control | Art. 25, 32 | 164.312(a) | Req. 7, 8 | CC6.1, CC6.3 |
| Incident reporting | Art. 33, 34 | 164.308(a)(6) | Req. 12.10 | CC7.3, CC7.4 |
| Data classification | Art. 9, 30 | 164.312(e) | Req. 9.6 | CC6.7 |
| Authentication | Art. 32 | 164.312(d) | Req. 8 | CC6.1 |
| Encryption | Art. 32 | 164.312(a)(2)(iv) | Req. 3, 4 | CC6.7 |
| Awareness training | Art. 39 | 164.308(a)(5) | Req. 12.6 | CC1.4 |
| Data retention | Art. 5(1)(e), 17 | 164.530(j) | Req. 3.1 | CC6.5 |

## Patterns

### Pattern: Policy Review Cycle
Set annual reviews for all policies. Trigger out-of-cycle reviews when: a security incident reveals a policy gap, regulations change, organizational structure changes significantly, or technology changes make a policy outdated.

### Pattern: Progressive Enforcement
First violation: Awareness and education (assume ignorance, not malice). Second violation: Formal warning with mandatory training. Third violation: Escalation to management. Severity exceptions: Deliberate or malicious violations skip to appropriate level regardless of count.

### Pattern: Exception Management
Every policy needs an exception process: (1) Request documenting business justification, (2) Risk assessment of the exception, (3) Compensating controls to mitigate the risk, (4) Time-limited approval with expiration date, (5) Regular review of active exceptions.

## Anti-Patterns

- **Copy-paste from templates without customization**: Generic policies that do not reflect the organization's actual environment are ignored because they contain irrelevant requirements
- **Writing for auditors instead of employees**: Policy language should be clear enough for the target audience. Save the regulatory language for the mapping appendix
- **No exception process**: Policies without exception mechanisms are routinely violated by necessity, training employees that policies are suggestions
- **Too many policies**: Policy fatigue is real. Consolidate related topics. An employee should not need to read 50 policies to understand their obligations
- **No enforcement**: Policies without monitoring and consequences are aspirational documents, not governance instruments
- **No update mechanism**: Stale policies with outdated technology references or expired regulatory versions erode confidence in the policy program

## References

- SANS Information Security Policy Templates -- https://www.sans.org/information-security-policy/
- NIST Cybersecurity Framework -- https://www.nist.gov/cyberframework
- ISO/IEC 27001:2022 -- Information security management systems
- ISO/IEC 27002:2022 -- Information security controls
- CIS Controls v8 -- https://www.cisecurity.org/controls
- NIST SP 800-53 Rev. 5 -- https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
- GDPR Full Text -- https://gdpr-info.eu/
- HIPAA Security Rule -- https://www.hhs.gov/hipaa/for-professionals/security/
- PCI DSS v4.0 -- https://www.pcisecuritystandards.org/
