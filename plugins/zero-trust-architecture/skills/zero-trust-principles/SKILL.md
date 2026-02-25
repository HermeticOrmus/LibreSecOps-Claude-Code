# Zero Trust Principles

> NIST SP 800-207 reference knowledge, core tenets, deployment models, and the theoretical foundation of zero trust architecture.

## Knowledge Base

### NIST SP 800-207 Core Tenets

NIST defines seven tenets of zero trust:

1. **All data sources and computing services are considered resources.** A network is not just servers -- laptops, phones, SaaS applications, IoT devices, and cloud functions are all resources that need protection.

2. **All communication is secured regardless of network location.** Internal network traffic is not inherently more trustworthy than external traffic. Encrypt and authenticate all communication.

3. **Access to individual enterprise resources is granted on a per-session basis.** Trust is not persistent. Each access request is evaluated independently based on current context.

4. **Access to resources is determined by dynamic policy.** Policies consider identity, device state, behavioral patterns, and environmental attributes -- not just static role assignments.

5. **The enterprise monitors and measures the integrity and security posture of all owned and associated assets.** No device is trusted by default. Device health, patch level, and configuration are continuously evaluated.

6. **All resource authentication and authorization are dynamic and strictly enforced before access is allowed.** Authentication is not a one-time gate. It is a continuous process that responds to changing risk signals.

7. **The enterprise collects as much information as possible about the current state of assets, network infrastructure, and communications and uses it to improve its security posture.** Visibility is not optional. You cannot enforce zero trust without comprehensive telemetry.

### Logical Components (NIST SP 800-207)

**Policy Engine (PE)**: The brain. Makes the access decision based on policy, identity, device state, threat intelligence, and behavioral analytics.

**Policy Administrator (PA)**: Executes the PE's decision by instructing the enforcement point to allow or deny access. May generate session-specific credentials (tokens, certificates).

**Policy Enforcement Point (PEP)**: The gate. Sits in the data path and allows or denies connections based on instructions from the PA. This could be a reverse proxy, API gateway, firewall, or service mesh sidecar.

**Data sources** that feed the PE:
- Identity provider (IdP) -- who is making the request
- Device inventory / MDM -- is the device healthy and managed
- SIEM / behavioral analytics -- has this user/device behaved abnormally
- Threat intelligence -- are the source indicators associated with known threats
- Compliance system -- does this access comply with policy

### CISA Zero Trust Maturity Model

The Cybersecurity and Infrastructure Security Agency (CISA) defines maturity across five pillars:

| Pillar | Traditional | Initial | Advanced | Optimal |
|--------|------------|---------|----------|---------|
| **Identity** | Passwords, no MFA | MFA for some, basic SSO | MFA everywhere, risk-based access, PAM | Phishing-resistant MFA, continuous verification, ABAC |
| **Devices** | No inventory | Basic inventory, some MDM | Full inventory, device health checks at login | Continuous posture assessment, real-time risk scoring |
| **Networks** | Flat network, VPN | Basic segmentation, some encryption | Microsegmentation, encrypted east-west, ZTNA | Identity-based networking, full mTLS, no implicit trust |
| **Applications** | Perimeter-protected | WAF, basic access control | Per-app policy, API security, integrated testing | Continuous runtime protection, immutable workloads |
| **Data** | No classification | Basic classification, encryption at rest | Classification-based access, DLP, key management | Automated classification, real-time DLP, tokenization |

### Deployment Models (NIST SP 800-207)

**Enhanced Identity Governance (EIG)**: Uses identity as the primary control plane. The enterprise strengthens its identity management to make access decisions based on verified identity and attributes. Best for organizations with strong IdP infrastructure and primarily SaaS/cloud workloads.

**Micro-Segmentation**: Uses network-level segmentation (VLANs, firewall rules, software-defined networking) to create fine-grained perimeters around individual workloads or small groups. Best for data center and IaaS environments with traditional infrastructure.

**Software-Defined Perimeter (SDP)**: Uses overlay networks and application-level access proxies to make resources invisible to unauthorized users. The resource is not even reachable at the network level unless access is granted. Best for remote access replacement (VPN alternative) and protecting legacy applications.

Most real implementations combine elements of all three.

## Patterns

### Pattern 1: BeyondCorp-Style Access Architecture

Google's BeyondCorp is the most well-known zero trust implementation. Key design decisions:

```
User Request Flow:
  User + Device --> Identity-Aware Proxy --> Access Policy Engine --> Resource

Components:
  1. Device Inventory Service (all devices registered, certificates issued)
  2. Device State Assessment (OS patches, disk encryption, screen lock)
  3. User Authentication (SSO + hardware security key)
  4. Access Control Engine (policy combines user role + device trust + resource sensitivity)
  5. Identity-Aware Proxy (enforces access decisions, no VPN needed)

Key Principle:
  Access is determined by WHO you are + WHAT device you are on + WHERE you are going
  NOT by WHAT network you are on
```

### Pattern 2: Conditional Access Policy Design

```yaml
# Conceptual conditional access policy
policy: "Access to Production Database Admin Console"
conditions:
  identity:
    - user_groups: ["database-admins"]
    - mfa_method: ["fido2", "push-notification"]  # Not SMS
    - session_risk: ["low", "medium"]  # Block if risk is high
  device:
    - managed: true
    - os_patched: true  # Within 48 hours of patch release
    - disk_encrypted: true
    - edr_running: true
  network:
    - any  # Network location is NOT a factor (zero trust principle)
  time:
    - business_hours: true  # After-hours access requires additional approval
actions:
  grant:
    - access_level: "read-only"  # Default to least privilege
    - session_duration: "1h"     # Short session, must re-authenticate
    - audit_logging: "enhanced"  # Log all queries
  deny:
    - notify: "security-team"
    - log: "access-denied-production-db"
```

### Pattern 3: Zero Trust Network Access (ZTNA) Replacing VPN

```
Traditional VPN:
  Authenticate once --> Full network access to everything on the VPN subnet
  Problem: Lateral movement is trivial once on the VPN

ZTNA Model:
  Authenticate per-application --> Access only the specific application authorized
  Each application has its own access policy

Implementation Options:
  - Cloudflare Access (identity-aware proxy)
  - Zscaler Private Access
  - Tailscale with ACLs (open source WireGuard-based)
  - Pomerium (open source identity-aware proxy)
  - Boundary (HashiCorp, session-based access)
```

### Pattern 4: Service-to-Service Zero Trust with SPIFFE

```yaml
# SPIFFE ID format: spiffe://trust-domain/workload-identifier
# Example: spiffe://example.com/payment-service

# SPIRE server configuration
server {
  trust_domain = "example.com"
  data_dir = "/opt/spire/data/server"
  log_level = "INFO"
  ca_ttl = "168h"       # CA certificate TTL: 7 days
  default_x509_svid_ttl = "1h"  # Workload certificate TTL: 1 hour
}

# Service mesh authorization using SPIFFE identity
# Istio AuthorizationPolicy
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: payment-service-policy
  namespace: production
spec:
  selector:
    matchLabels:
      app: payment-service
  rules:
    - from:
        - source:
            principals: ["cluster.local/ns/production/sa/checkout-service"]
      to:
        - operation:
            methods: ["POST"]
            paths: ["/api/v1/charge"]
    # Default: deny everything else
```

## Anti-Patterns

- **Rebranding the VPN as "zero trust"**: Adding MFA to a VPN and calling it zero trust misses the point entirely. If authenticated users still get broad network access, it is still perimeter security.
- **Zero trust as a product purchase**: No single product delivers zero trust. It is an architectural approach implemented through coordinated controls across identity, network, endpoint, application, and data layers.
- **Ignoring legacy systems**: Legacy systems that cannot support modern authentication still need to be addressed -- through isolation, proxying, and enhanced monitoring, not exclusion from the architecture.
- **All-or-nothing implementation**: Attempting to implement full zero trust across the entire organization simultaneously leads to failure. Start with the highest-value, highest-risk use cases and expand.
- **Forgetting about user experience**: If zero trust makes legitimate work significantly harder, users will find workarounds that create security gaps. Design for seamless secure access.
- **Over-relying on network controls**: Network microsegmentation is one tool. Without strong identity, device posture, and application-level controls, segmentation alone does not achieve zero trust.

## References

- NIST SP 800-207 (Zero Trust Architecture): https://csrc.nist.gov/publications/detail/sp/800-207/final
- CISA Zero Trust Maturity Model v2.0: https://www.cisa.gov/zero-trust-maturity-model
- Google BeyondCorp Papers: https://cloud.google.com/beyondcorp
- DoD Zero Trust Reference Architecture: https://dodcio.defense.gov/Portals/0/Documents/Library/ZTRefArch.pdf
- NIST SP 800-53 Rev 5 (Security Controls): https://csrc.nist.gov/publications/detail/sp/800-53/rev-5/final
- SPIFFE Specification: https://spiffe.io/docs/latest/spiffe-about/overview/
