# /network-audit

> Structured audit of network configuration covering firewalls, segmentation, exposure, and monitoring.

## Trigger

Use when you need to:
- Review firewall rules (iptables, nftables, cloud security groups) for security
- Assess network segmentation and lateral movement risk
- Identify unnecessary network exposure
- Audit VPN or tunnel configurations
- Evaluate network monitoring and IDS/IPS coverage

## Input

One or more of:
- **Firewall rules**: `iptables-save` output, `nft list ruleset` output, cloud security group exports
- **Network diagram**: Topology showing segments, trust zones, and traffic flows
- **Live system access**: SSH access to hosts for `ss`, `iptables-save`, `ip route` inspection
- **Cloud configuration**: Terraform files defining security groups/NSGs/firewall rules
- **Specific scope**: Focus area (e.g., "DMZ security", "internal segmentation", "VPN config")

## Process

### Phase 1: Topology & Exposure

1. **External attack surface**
   - Internet-facing IP addresses and services
   - Open ports visible from the internet (authorized scan or cloud config review)
   - Services that should NOT be internet-facing (databases, admin panels, monitoring)
   - Management interfaces (SSH, RDP) accessible from internet

2. **Network segments**
   - Identified trust zones (public, DMZ, internal, management, database)
   - Inter-zone firewall rules
   - Flat network segments (no internal firewalling)
   - VLAN configuration and trunk security

### Phase 2: Firewall Rules

3. **Rule assessment**
   - Default policy (ACCEPT is a critical finding for INPUT/FORWARD chains)
   - Rules allowing `0.0.0.0/0` ingress (any source)
   - Rules allowing broad port ranges or `any` port
   - Rules with no logging
   - Orphaned rules (reference dead IPs or decommissioned services)
   - Rule ordering (iptables processes sequentially -- early broad allows bypass later specific denies)

4. **Egress filtering**
   - Outbound traffic restrictions (default allow outbound is common and dangerous)
   - Permitted outbound ports (HTTP/HTTPS/DNS are common, but should be the only allowed)
   - Data exfiltration paths (can internal hosts send arbitrary traffic outbound?)

### Phase 3: Access Controls

5. **Remote access**
   - VPN configuration (protocol, cipher suites, authentication method)
   - SSH configuration (key-based auth, disabled password auth, allowed users)
   - Jump box / bastion host architecture
   - RDP exposure (should never be internet-facing)
   - Management network isolation

6. **DNS security**
   - Internal DNS resolver configuration
   - DNS query logging
   - DNSSEC validation
   - DNS filtering or sinkholing

### Phase 4: Monitoring

7. **Network monitoring**
   - IDS/IPS deployment (sensor placement, inline vs passive)
   - Traffic logging (NetFlow, VPC Flow Logs, firewall logs)
   - Log retention and analysis
   - Alert configuration for security events

8. **Encryption**
   - TLS enforcement on all external-facing services
   - Internal TLS for service-to-service communication
   - VPN encryption algorithms (avoid deprecated: 3DES, RC4, SHA1)
   - Certificate management (expiration monitoring, CA trust)

### Phase 5: IPv6

9. **IPv6 assessment**
   - IPv6 enabled on interfaces?
   - IPv6 firewall rules exist? (often IPv4 is firewalled but IPv6 is wide open)
   - IPv6 link-local addresses accessible?

## Output

```
## Network Security Audit Results

### Scope
- Network segments assessed: [List]
- Firewalls reviewed: [List]
- Method: [Config review / live assessment / cloud config]
- Date: [Assessment date]

### Network Topology
[ASCII diagram or description of segments and flows]

### Summary
| Category | Critical | High | Medium | Low | Pass |
|----------|----------|------|--------|-----|------|
| Exposure |          |      |        |     |      |
| Firewall |          |      |        |     |      |
| Segmentation |      |      |        |     |      |
| Access   |          |      |        |     |      |
| Monitoring |        |      |        |     |      |
| Encryption |        |      |        |     |      |

### Findings (by severity)

#### Critical
[Findings with specific rule changes or configuration fixes]

#### High
[Findings]

#### Medium
[Findings]

### Lateral Movement Assessment
[What an attacker can reach from each zone after initial compromise]

### Remediation Priority
1. [Close external exposure]
2. [Implement egress filtering]
3. [Segment internal networks]
4. [Deploy monitoring]

### Positive Findings
[Well-configured controls]
```
