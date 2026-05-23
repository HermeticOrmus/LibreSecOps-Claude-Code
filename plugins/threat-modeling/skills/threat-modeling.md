# Threat modeling pattern library

## STRIDE quick reference

| Letter | Threat | Common mitigations |
|---|---|---|
| **S**poofing | Impersonation | Authentication (MFA), mutual TLS, signed tokens |
| **T**ampering | Unauthorized modification | Integrity checks (HMAC), signed data, immutable audit logs |
| **R**epudiation | Action denial | Audit logs with non-repudiation (signed entries), trusted timestamps |
| **I**nformation Disclosure | Data leak | Encryption at rest + in transit, least-privilege access, data minimization |
| **D**enial of Service | Availability loss | Rate limiting, auto-scaling, circuit breakers, DDoS protection |
| **E**levation of Privilege | Gaining unauthorized capability | RBAC + ABAC, privilege separation, mandatory access control |

## Trust boundary checklist

Common trust boundaries to enumerate:

- User → CDN/edge
- Edge → application
- Application → datastore
- Application → external API (per integration)
- Application → message queue
- Internal service A → internal service B
- Build pipeline → production
- Operator → infrastructure

Each crossing is a potential threat surface.

## DREAD scoring guide

For each dimension, 1 = minimal, 10 = maximum:

**Damage**: nothing → bankruptcy
**Reproducibility**: requires precise conditions → trivially repeatable
**Exploitability**: requires nation-state resources → script-kiddie
**Affected users**: single user → everyone
**Discoverability**: never found → publicly documented

Use 1-10 scale; average to a final score. > 7 critical, 5-7 high, 3-5 medium, < 3 accept-and-monitor.

## Common STRIDE × component pairs

### Web app frontend
- **S**: phishing replicas, OAuth flow tampering
- **T**: XSS modifying displayed data
- **I**: secrets in JS bundle, session token in URL
- **D**: client-side resource exhaustion
- **E**: privilege escalation via client-side bypass

### REST API
- **S**: token theft + replay
- **T**: request tampering, parameter pollution
- **R**: missing audit logs
- **I**: BOLA (Broken Object Level Authorization), excessive data exposure
- **D**: unbounded query, ReDoS
- **E**: BFLA (Broken Function Level Authorization), mass assignment

### Database
- **S**: connection string compromise
- **T**: direct row modification bypassing app
- **R**: no audit trail
- **I**: full table dump
- **D**: query of doom, lock escalation
- **E**: privilege escalation via SQL injection

### Cloud IAM
- **S**: assumed-role abuse, key compromise
- **T**: policy modification
- **R**: CloudTrail gaps
- **I**: over-permissive policies, public S3 buckets
- **D**: budget exhaustion via excessive provisioning
- **E**: privilege escalation chains (PassRole abuse)

## MITRE ATT&CK common TTPs

For threat models, the most commonly relevant tactics + techniques:

| Tactic | Technique |
|---|---|
| Initial Access | T1190 Exploit Public-Facing App, T1566 Phishing |
| Execution | T1059 Command Line, T1203 Exploitation for Client Execution |
| Persistence | T1098 Account Manipulation, T1078 Valid Accounts |
| Privilege Escalation | T1068 Exploitation for Privilege Escalation, T1548 Abuse Elevation Control |
| Defense Evasion | T1027 Obfuscated Files, T1562 Impair Defenses |
| Credential Access | T1110 Brute Force, T1555 Credentials from Password Stores |
| Discovery | T1018 Remote System Discovery, T1083 File and Directory Discovery |
| Lateral Movement | T1021 Remote Services, T1570 Lateral Tool Transfer |
| Collection | T1005 Data from Local System, T1213 Data from Information Repositories |
| Exfiltration | T1041 Exfiltration Over C2, T1567 Exfiltration to Cloud Storage |
| Impact | T1486 Data Encrypted for Impact (ransomware), T1499 Endpoint DoS |

For each threat in your model, identify the corresponding TTP. Then look up detection signatures (Sigma, Splunk, ELK) for that TTP.

## Attack tree examples

### Goal: Steal another tenant's data

```
Steal tenant data
├── (OR) Exploit application-layer flaw
│   ├── (OR) BOLA on orders endpoint → AND: auth, guess IDs
│   ├── (OR) SQL injection in search → AND: find vector, bypass WAF
│   └── (OR) Mass assignment → AND: find writeable field, identify tenant_id field
├── (OR) Compromise infrastructure
│   ├── (OR) Cloud account takeover → AND: phish admin, bypass MFA
│   ├── (OR) Direct DB access → AND: obtain credentials, reach network
│   └── (OR) Backup theft → AND: identify backup location, exfiltrate
└── (OR) Insider threat
    ├── (OR) Disgruntled employee → AND: access prod, evade audit
    └── (OR) Bribed/coerced admin → AND: access, evade detection
```

### Goal: Account takeover

```
Take over account
├── (OR) Password compromise
│   ├── Phishing
│   ├── Credential stuffing (reused password)
│   └── Brute force (weak password)
├── (OR) Session hijack
│   ├── XSS-based theft
│   ├── Network interception (no HTTPS)
│   └── CSRF (with weak protection)
├── (OR) MFA bypass
│   ├── SIM swap
│   ├── MFA fatigue
│   └── Push notification approval social-engineering
└── (OR) Account recovery flaw
    ├── Weak security questions
    └── Email/phone takeover prerequisites
```

## Common mistakes catalog

### "We have a threat model" (and it's never read)

Threat model becomes shelf-ware. Fix: integrate into PR review for security-sensitive changes. Threat model is part of design doc, not separate.

### "STRIDE walked, but no mitigations chosen"

The methodology is means, not end. Each threat needs a concrete control or explicit acceptance.

### "All threats critical"

Risk ranking is broken. Score with DREAD or CVSS to differentiate. Engineering can only address top-N; rest must be detection + acceptance.

### "No trust boundary analysis"

Most common omission. Without trust boundaries, threats appear ad-hoc. With them, threats appear systematically at each boundary.

### "Threat model authored without engineering"

Controls proposed that can't be built (technically infeasible) or that the team won't build (effort exceeds priority). Threat models without engineering input become aspirational.

### "Compliance audit blames us for not having a model"

SOC 2 + ISO 27001 expect documented threat models for material features. Don't catch this at audit; build the practice continuously.

## Cross-references

- See `incident-response` plugin — when threats materialize
- See `penetration-testing` — to validate the model against real attack
- See `compliance-frameworks` — for audit-evidence requirements
- See cloud-security-* per provider — for provider-specific threats and controls
- MITRE ATT&CK: https://attack.mitre.org
- OWASP Threat Modeling Cheat Sheet
- Adam Shostack, *Threat Modeling: Designing for Security*
