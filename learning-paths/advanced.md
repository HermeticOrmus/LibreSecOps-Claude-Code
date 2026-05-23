# Advanced — red/blue, compliance, zero-trust

## Red team / blue team exercises

Quarterly:

- **Red**: simulate a specific adversary scenario (insider threat, ransomware, supply chain compromise)
- **Blue**: detect + respond
- **Purple**: red + blue work together; red shows blue what they did, blue shows red what they detected
- **Tabletop**: walkthrough without live exploitation

Use MITRE ATT&CK for adversary scenarios. Map exercise findings to detection gaps.

## Compliance audit prep

For SOC 2 Type 2:

- 6-12 months evidence collection before audit
- Auditor expects: documented controls, evidence of operation, no major exceptions
- Internal pre-audit by GRC team (or external GRC consultant)

Standard control families:
- Access control (CC6)
- System operations (CC7)
- Change management (CC8)
- Risk assessment (CC4)
- Monitoring (CC4 + CC7)

Cost: $30-100k+ audit fees + significant internal time.

## Zero-trust migration

From perimeter-based to zero-trust:

1. **Identity-first networking** — every request authenticated, regardless of origin
2. **Microsegmentation** — workload-to-workload policy, not just network-edge
3. **Continuous verification** — session-level, not just login
4. **Just-in-time access** — temporary credentials, not standing access
5. **Data-centric security** — protect data, not just network

This is a multi-year journey. Most orgs achieve 60-80% maturity; few achieve 100%.

Pair with:
- Identity provider (Okta, Azure AD, Auth0)
- Cloud access proxy (Zscaler, Netskope, Cloudflare Zero Trust)
- Workload identity (SPIFFE/SPIRE)
- Policy engine (OPA, AWS verified access)

## What's still hard

- **Attacker creativity outpaces defender frameworks**. Frameworks are last-decade attacks; today's attacks evolve faster.
- **Compliance theater vs. real security**. SOC 2 passes != secure. Some controls are theater; some real security work isn't in any framework.
- **Insider threats**. Hardest to detect; least addressed by tooling.
- **Supply chain**. xz-utils style attacks. Defense is hard.
