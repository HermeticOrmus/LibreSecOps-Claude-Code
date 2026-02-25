# /siem-setup

> Design a SIEM architecture including log source prioritization, collection strategy, retention policies, and initial detection rule set.

## Trigger

Use when deploying a new SIEM, migrating between SIEM platforms, or redesigning an existing SIEM architecture. Also useful for evaluating SIEM readiness and identifying critical gaps in current deployments.

## Input

- **Environment**: Cloud (AWS/Azure/GCP), on-premises, hybrid, multi-cloud
- **Scale**: Number of endpoints, users, servers, cloud workloads
- **Operating systems**: Windows, Linux, macOS distribution
- **Key applications**: Active Directory, Office 365, AWS services, custom applications
- **Current state**: Existing log collection, current SIEM (if any), known gaps
- **Compliance requirements**: Regulatory frameworks requiring specific log retention or monitoring
- **Budget context**: License model preference (per-GB, per-EPS, open-source), operational budget range
- **Team size**: SOC analysts, detection engineers, SIEM administrators available

## Process

1. **Platform recommendation** -- Based on environment, budget, and team:
   - Splunk: Best query language, highest cost, strong ecosystem
   - Elastic Security: Open-source core, strong endpoint integration, good for technical teams
   - Microsoft Sentinel: Best for Azure/O365-heavy environments, consumption-based pricing
   - For smaller teams/budgets: Wazuh (open-source), Graylog, Security Onion

2. **Log source prioritization** -- Ranked by detection value:

   **Tier 1 (Deploy first -- highest detection value)**:
   - Windows Security Event Logs (Event IDs: 4624, 4625, 4648, 4672, 4688, 4698, 4720, 7045)
   - Sysmon (process creation, network connections, file creation, registry, DNS)
   - EDR telemetry (CrowdStrike, Defender for Endpoint, SentinelOne)
   - DNS query logs (internal resolver)
   - Authentication platform logs (Active Directory, Okta, Azure AD)

   **Tier 2 (Deploy second -- critical context)**:
   - Cloud audit logs (CloudTrail, Azure Activity Log, GCP Audit Log)
   - Proxy/web gateway logs
   - Email gateway logs (for phishing detection)
   - Firewall connection logs
   - VPN authentication logs

   **Tier 3 (Deploy third -- enrichment and compliance)**:
   - Linux auditd / syslog
   - Application logs (custom apps, databases)
   - DLP alerts
   - Physical security logs (badge access)
   - DHCP/CMDB for IP-to-asset mapping

3. **Collection architecture design** -- Agent-based vs agentless, log routing (Cribl, Logstash), syslog infrastructure, API-based collection for cloud/SaaS

4. **Parsing and normalization** -- Schema selection (CIM, ECS, ASIM), custom parser development for non-standard sources

5. **Retention design** -- Hot/warm/cold tiers based on investigation needs and compliance

6. **Initial detection rule set** -- Top 20 rules covering the most common and impactful ATT&CK techniques

## Output

```
## SIEM Architecture Design

### Recommended Platform
**Platform**: [name]
**Rationale**: [why this platform for this environment]
**Deployment model**: [cloud/on-prem/hybrid]

### Log Source Roadmap
| Phase | Source | Collection Method | EPS Est. | Priority |
|-------|--------|-------------------|----------|----------|
| 1 (Week 1-4) | [source] | [method] | [EPS] | Critical |
| 2 (Week 5-8) | [source] | [method] | [EPS] | High |
| 3 (Week 9-12) | [source] | [method] | [EPS] | Medium |

### Collection Architecture
[Infrastructure diagram description: forwarders, collectors, routing, SIEM]

### Normalization Strategy
**Schema**: [CIM/ECS/ASIM]
**Custom parsers needed**: [non-standard sources]

### Retention Policy
| Tier | Storage | Duration | Data Types |
|------|---------|----------|-----------|
| Hot | [type] | [days] | All active data |
| Warm | [type] | [days] | Searchable archive |
| Cold | [type] | [months] | Compliance retention |

### Initial Detection Rules (Top 20)
| # | Detection | ATT&CK | Log Source | Sigma ID |
|---|-----------|--------|-----------|----------|
| 1 | [name] | [T####] | [source] | [if exists] |

### Capacity Estimate
- **Total EPS**: [estimated]
- **Daily ingest**: [GB/day]
- **Annual storage**: [TB/year]
- **Estimated cost**: [annual]

### Implementation Timeline
[Phased deployment schedule]
```
