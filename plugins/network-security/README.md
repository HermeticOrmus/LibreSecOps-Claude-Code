# Network Security

> Firewall configuration, network segmentation, intrusion detection/prevention, and VPN/tunnel security patterns.

---

## Overview

Network security is the foundational layer that all other security controls depend on. Even with perfect application security, an improperly segmented network allows lateral movement -- one compromised host becomes a beachhead for accessing everything. Network security has evolved from simple perimeter firewalls to defense-in-depth with micro-segmentation, but the core principles remain: control what can communicate with what, detect anomalies in traffic patterns, and ensure that compromise of any single component does not compromise everything.

This plugin covers network security from host-level firewalls (iptables/nftables) through cloud security groups to network intrusion detection systems. The focus is on practical, defensive configuration -- actual firewall rules, real IDS signatures, and genuine segmentation strategies that you can implement.

---

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Network Security Architect | `agents/network-security-architect.md` | Designs and reviews network architecture, firewall rules, VPN configurations, and segmentation strategies |
| IDS/IPS Engineer | `agents/ids-ips-engineer.md` | Configures and tunes intrusion detection/prevention systems, analyzes network traffic for threats |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/network-audit` | `commands/network-audit.md` | Structured audit of network configuration covering firewalls, segmentation, exposure, and monitoring |

### Skills (Knowledge Bases)

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Firewall Patterns | `skills/firewall-patterns/` | iptables/nftables rulesets, cloud security group patterns, and firewall design principles |
| Network Segmentation | `skills/network-segmentation/` | Segmentation strategies, VLAN design, micro-segmentation, and zero-trust networking |

---

## Usage

### Network Review

Use `/network-audit` to systematically evaluate network security posture. Works with firewall configurations, network diagrams, cloud security group exports, or live system access.

### Architecture Design

Activate `network-security-architect` when designing new network architectures, evaluating segmentation strategies, or reviewing VPN/tunnel configurations.

### Threat Detection

Activate `ids-ips-engineer` when setting up or tuning intrusion detection systems, analyzing suspicious traffic, or designing network monitoring strategies.

### Reference

The skills directories contain reference material for firewall rule design and segmentation strategies. Particularly useful when translating security requirements into actual firewall rules.

---

## Key Principles

1. **Default deny, explicit allow.** Every firewall should deny all traffic by default. Each allowed flow must be explicitly justified.
2. **Segment to contain.** Network segmentation limits blast radius. A compromised web server should not be able to reach the database directly.
3. **Monitor everything.** Firewalls prevent unauthorized traffic; IDS/IPS detects authorized traffic being used maliciously.
4. **Encrypt in transit.** TLS for application traffic, IPsec or WireGuard for tunnel traffic. Unencrypted traffic on any network segment is a credential theft opportunity.
5. **Defense in depth.** No single control is sufficient. Layer host firewalls, network firewalls, security groups, NACLs, and IDS/IPS.

---

## Prerequisites

- Familiarity with TCP/IP, routing, and DNS
- Access to firewall configurations (iptables, nftables, cloud security groups) for auditing
- For IDS/IPS: Suricata, Snort, or Zeek installed in lab environments

---

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `kubernetes-security` | NetworkPolicy for Kubernetes pod-to-pod segmentation |
| `cloud-security-aws` | AWS Security Groups, NACLs, VPC design |
| `cloud-security-gcp` | GCP Firewall Rules, VPC Service Controls |
| `cloud-security-azure` | Azure NSGs, Azure Firewall, Private Endpoints |
| `zero-trust-architecture` | Zero-trust networking principles that build on segmentation |
| `cryptography-essentials` | TLS/SSL and encryption patterns for transit security |

---

## References

- [CIS Firewall Benchmarks](https://www.cisecurity.org/benchmark)
- [NIST SP 800-41: Firewall Guidelines](https://csrc.nist.gov/publications/detail/sp/800-41/rev-1/final)
- [NIST SP 800-125B: Network Segmentation](https://csrc.nist.gov/publications/detail/sp/800-125b/final)
- [Suricata Documentation](https://docs.suricata.io/)
- [Zeek Network Monitor](https://zeek.org/)
- [MITRE ATT&CK -- Lateral Movement](https://attack.mitre.org/tactics/TA0008/)
