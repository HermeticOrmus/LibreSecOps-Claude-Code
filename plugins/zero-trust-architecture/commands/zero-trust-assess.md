# /zero-trust-assess

> Assess the current security posture against the CISA Zero Trust Maturity Model and identify the path to higher maturity levels.

## Trigger

Use when you need to:

- Evaluate how close an organization or project is to zero trust principles
- Identify the highest-impact gaps in current security architecture
- Create a prioritized roadmap for zero trust adoption
- Satisfy compliance requirements that reference zero trust (NIST, FedRAMP, CMMC 2.0)
- Justify security investment with a maturity-based framework

## Input

The command works through an interactive assessment across five pillars. It needs:

- **Required**: Willingness to answer questions about current security infrastructure, policies, and tooling across each pillar.
- **Optional**: Architecture diagrams, network topology, IAM configuration, existing security policies.
- **Optional flag**: `--pillar [identity|devices|networks|applications|data]` -- assess a single pillar in depth instead of all five.
- **Optional flag**: `--target [initial|advanced|optimal]` -- specify the target maturity level for gap analysis.

## Process

1. **Pillar 1: Identity Assessment**
   - How are users authenticated? (Password-only, MFA, phishing-resistant MFA)
   - Is there centralized identity management (SSO/IdP)?
   - Are access policies risk-based or static?
   - Is privileged access managed separately (PAM)?
   - How are service-to-service identities handled?
   - Is access reviewed periodically? Automated or manual?
   - Score: Traditional / Initial / Advanced / Optimal

2. **Pillar 2: Devices Assessment**
   - Is there a device inventory (all devices known)?
   - Is device health assessed before granting access?
   - Are unmanaged devices allowed? With what restrictions?
   - Is endpoint detection and response (EDR) deployed?
   - Is device posture continuously evaluated or only at login?
   - Score: Traditional / Initial / Advanced / Optimal

3. **Pillar 3: Networks Assessment**
   - Is the network flat or segmented?
   - Is east-west traffic encrypted?
   - Are network policies identity-aware or IP-based?
   - Is DNS traffic encrypted and monitored?
   - Is there micro-segmentation at the workload level?
   - Are there internal resources accessible without VPN/ZTNA?
   - Score: Traditional / Initial / Advanced / Optimal

4. **Pillar 4: Applications & Workloads Assessment**
   - Are applications accessed through a reverse proxy / gateway?
   - Is application access policy-based (conditional)?
   - Are workloads isolated from each other?
   - Is application security testing integrated into development?
   - Are APIs authenticated and authorized independently?
   - Score: Traditional / Initial / Advanced / Optimal

5. **Pillar 5: Data Assessment**
   - Is data classified by sensitivity?
   - Is encryption applied at rest and in transit?
   - Are access controls applied based on data classification?
   - Is data loss prevention (DLP) in place?
   - Is data access logged and auditable?
   - Score: Traditional / Initial / Advanced / Optimal

6. **Cross-Cutting Capabilities Assessment**
   - Visibility and analytics (logging, SIEM, behavioral analysis)
   - Automation and orchestration (automated response, policy enforcement)
   - Governance (policies, standards, compliance mapping)

7. **Gap Analysis**: For each pillar, identify the specific capabilities missing to reach the target maturity level.

8. **Roadmap Generation**: Produce a phased implementation plan prioritized by risk reduction and feasibility.

## Output

```
# Zero Trust Maturity Assessment
Date: [timestamp]

## Maturity Scorecard

| Pillar | Current Level | Target Level | Gap |
|--------|--------------|--------------|-----|
| Identity | Initial | Advanced | Medium |
| Devices | Traditional | Initial | High |
| Networks | Initial | Advanced | High |
| Applications | Initial | Advanced | Medium |
| Data | Traditional | Initial | High |

## Overall Maturity: Initial
## Target Maturity: Advanced

## Pillar Details

### Identity (Current: Initial)
**Strengths:**
- SSO deployed for cloud applications
- MFA enabled for admin accounts

**Gaps to reach Advanced:**
- [ ] MFA for all users (not just admins)
- [ ] Phishing-resistant MFA (FIDO2/WebAuthn) for privileged accounts
- [ ] Risk-based conditional access policies
- [ ] Automated access reviews
- [ ] Service-to-service identity (SPIFFE/mTLS)

[...additional pillars...]

## Prioritized Roadmap

### Phase 1: Quick Wins (30 days)
| Action | Pillar | Impact | Effort |
|--------|--------|--------|--------|
| Enable MFA for all users | Identity | High | Low |
| Enable encryption at rest | Data | High | Low |
| Deploy EDR to endpoints | Devices | High | Medium |

### Phase 2: Foundation (90 days)
[...]

### Phase 3: Advanced Controls (180 days)
[...]

### Phase 4: Optimization (Ongoing)
[...]

## Compliance Mapping
| Control | Framework | ZT Pillar | Status |
|---------|-----------|-----------|--------|
| AC-2 Account Management | NIST 800-53 | Identity | Partial |
| SC-7 Boundary Protection | NIST 800-53 | Networks | Gap |
[...]
```
