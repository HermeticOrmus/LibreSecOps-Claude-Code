# /social-eng-assess

> Assess an organization's vulnerability to social engineering attacks, identifying risk factors, current defense gaps, and prioritized recommendations.

## Trigger

Use when evaluating an organization's resilience to social engineering. Appropriate for:
- Baseline assessment before launching an awareness program
- Post-incident assessment after a social engineering attack
- Regulatory compliance assessment (security controls evaluation)
- Annual security program review
- Pre-acquisition due diligence (target company security culture)

## Input

- **Organization profile**: Industry, size, geographic distribution, remote vs in-office
- **Communication patterns**: Email systems, collaboration tools, phone systems, external-facing staff
- **Current defenses**: Email security (SPF/DKIM/DMARC), MFA status, awareness training history, phishing simulation results
- **Incident history**: Past social engineering incidents (phishing, BEC, vishing, physical)
- **Public exposure**: Website, social media presence, employee information publicly available
- **Regulatory environment**: Applicable compliance requirements
- **Specific concerns**: Any known areas of weakness or recent threats

## Process

1. **Threat landscape assessment** -- Identify the most likely social engineering threats based on industry and organization profile:
   - Financial sector: BEC, wire fraud, account takeover
   - Healthcare: Patient data phishing, ransomware via phishing, credential theft
   - Technology: Supply chain phishing, developer targeting, source code theft
   - Government: Espionage-motivated spear phishing, insider recruitment
   - Retail: Payment fraud, POS compromise via phishing, customer data theft

2. **Attack surface analysis** -- Map the human attack surface:
   - Email exposure (how many addresses are publicly discoverable)
   - Phone exposure (direct dial numbers, receptionist information)
   - Physical exposure (public lobbies, delivery areas, parking)
   - Social media exposure (LinkedIn profiles, company information)
   - OSINT availability (organizational structure, technology stack, vendor relationships)

3. **Technical control assessment** -- Evaluate technical defenses:
   - Email authentication (SPF, DKIM, DMARC in enforce mode)
   - Email filtering (anti-phishing, anti-malware, URL rewriting, sandbox detonation)
   - MFA deployment (coverage, authentication factors, phishing-resistant methods)
   - URL filtering/proxy (blocking known malicious domains)
   - Endpoint detection (ability to catch phishing payloads)
   - Phone security (caller ID spoofing protection, call recording)

4. **Human control assessment** -- Evaluate human defenses:
   - Awareness training history and effectiveness
   - Phishing simulation results (click rate, report rate trends)
   - Reporting mechanisms (ease of reporting, response time)
   - Verification procedures (callback verification for financial requests, identity verification)
   - Physical security procedures (badge enforcement, visitor management)

5. **Risk scoring** -- Assess overall risk considering:
   - Threat likelihood (based on industry and exposure)
   - Defense effectiveness (technical and human controls)
   - Impact potential (what a successful attack could achieve)
   - Organizational factors (security culture maturity, executive engagement)

## Output

```
## Social Engineering Risk Assessment

### Organization Profile
- **Organization**: [name/type]
- **Industry**: [industry]
- **Size**: [employees]
- **Assessment date**: [date]

### Threat Landscape
| Threat | Likelihood | Impact | Risk Level |
|--------|-----------|--------|-----------|
| Mass phishing | [H/M/L] | [H/M/L] | [score] |
| Spear phishing | [H/M/L] | [H/M/L] | [score] |
| BEC/wire fraud | [H/M/L] | [H/M/L] | [score] |
| Vishing | [H/M/L] | [H/M/L] | [score] |
| Physical SE | [H/M/L] | [H/M/L] | [score] |

### Attack Surface
**Email exposure**: [assessment]
**Phone exposure**: [assessment]
**Physical exposure**: [assessment]
**OSINT exposure**: [assessment]

### Technical Controls
| Control | Status | Effectiveness | Gap |
|---------|--------|--------------|-----|
| Email authentication (DMARC) | [deployed/partial/none] | [H/M/L] | [gap] |
| Email filtering | [deployed/partial/none] | [H/M/L] | [gap] |
| MFA | [deployed/partial/none] | [H/M/L] | [gap] |
| URL filtering | [deployed/partial/none] | [H/M/L] | [gap] |

### Human Controls
| Control | Status | Effectiveness | Gap |
|---------|--------|--------------|-----|
| Awareness training | [active/outdated/none] | [H/M/L] | [gap] |
| Phishing simulations | [regular/occasional/none] | [H/M/L] | [gap] |
| Reporting mechanism | [easy/exists/none] | [H/M/L] | [gap] |
| Verification procedures | [enforced/documented/none] | [H/M/L] | [gap] |

### Overall Risk Rating: [Critical/High/Medium/Low]
**Rationale**: [summary of key risk factors]

### Recommendations (Prioritized)
1. **[CRITICAL]**: [most impactful defense improvement]
2. **[HIGH]**: [second priority]
3. **[MEDIUM]**: [third priority]
...

### Quick Wins (implement within 30 days)
- [actionable item 1]
- [actionable item 2]
- [actionable item 3]
```
