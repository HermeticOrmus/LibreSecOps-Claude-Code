# SOAR Patterns

> Playbook design patterns, orchestration architecture, and integration strategies for security automation platforms.

## Knowledge Base

### SOAR Architecture Components

**Orchestration**: Coordinating actions across multiple security tools through a central platform. The SOAR platform acts as the conductor, calling APIs, passing data between tools, and managing the workflow state.

**Automation**: Executing predefined actions without human intervention. Ranges from simple (enrich an IP) to complex (isolate an endpoint, disable an account, block a domain, create a ticket, notify stakeholders).

**Response**: The actions taken to contain, remediate, and recover from a security incident. SOAR codifies response procedures as executable playbooks.

### Playbook Categories

| Category | Trigger | Risk Level | Human Approval |
|----------|---------|------------|----------------|
| Enrichment | Every alert | None (read-only) | Not required |
| Triage | Every alert | Low (classification) | Not required |
| Notification | Severity threshold | None (informational) | Not required |
| Investigation | Analyst-initiated | Low (queries only) | Optional |
| Containment | Confirmed threat | Medium-High (action) | Required initially |
| Remediation | Post-containment | High (changes systems) | Required |
| Recovery | Post-remediation | Medium (restores) | Required |

### Platform Comparison

| Feature | Shuffle (OSS) | TheHive/Cortex (OSS) | Tines | Splunk SOAR | XSOAR |
|---------|--------------|---------------------|-------|-------------|-------|
| Cost | Free | Free | $$ | $$$ | $$$ |
| No-code builder | Yes | Partial | Yes | Yes | Yes |
| Custom code | Python, Go | Python (Cortex analyzers) | Ruby/JS | Python | Python/JS |
| Integrations | 100+ | 150+ (Cortex) | 200+ | 350+ | 700+ |
| Self-hosted | Yes | Yes | No | Yes | Yes |
| Case management | No (external) | Yes (built-in) | No (external) | No (external) | Yes |
| Community | Growing | Mature | Growing | Mature | Large |

## Patterns

### Pattern 1: Alert Enrichment Playbook

The most common and lowest-risk automation. Automatically gather context for every alert.

```python
"""
Playbook: Universal Alert Enrichment
Trigger: Any new SIEM alert
Risk: None (read-only operations)
Approval: Not required
"""

import asyncio
from datetime import datetime
from typing import Dict, List, Optional

async def enrich_alert(alert: dict) -> dict:
    """Main enrichment orchestrator."""

    # Extract IOCs from alert
    iocs = extract_iocs(alert)

    # Parallel enrichment -- all read-only, no risk
    enrichment_tasks = []

    for ioc in iocs:
        if ioc['type'] == 'ip':
            enrichment_tasks.extend([
                check_virustotal_ip(ioc['value']),
                check_abuseipdb(ioc['value']),
                check_greynoise(ioc['value']),
                check_shodan_ip(ioc['value']),
                check_internal_ioc_db(ioc['value']),
            ])
        elif ioc['type'] == 'domain':
            enrichment_tasks.extend([
                check_virustotal_domain(ioc['value']),
                check_whois(ioc['value']),
                check_dns_history(ioc['value']),
                check_internal_ioc_db(ioc['value']),
            ])
        elif ioc['type'] == 'hash':
            enrichment_tasks.extend([
                check_virustotal_hash(ioc['value']),
                check_malware_bazaar(ioc['value']),
                check_internal_ioc_db(ioc['value']),
            ])

    # Asset enrichment
    if alert.get('src_ip'):
        enrichment_tasks.append(lookup_asset(alert['src_ip']))
    if alert.get('user'):
        enrichment_tasks.append(lookup_user(alert['user']))

    # Historical enrichment
    enrichment_tasks.append(get_related_alerts(alert, lookback_days=30))

    # Execute all enrichments in parallel
    results = await asyncio.gather(*enrichment_tasks, return_exceptions=True)

    # Compile enrichment
    enriched_alert = {
        **alert,
        'enrichment': compile_results(results),
        'enriched_at': datetime.utcnow().isoformat(),
        'auto_severity': calculate_severity(alert, results),
    }

    return enriched_alert


def extract_iocs(alert: dict) -> List[dict]:
    """Extract IP addresses, domains, hashes, and URLs from alert fields."""
    iocs = []
    # IP extraction
    for field in ['src_ip', 'dest_ip', 'remote_ip', 'attacker_ip']:
        if alert.get(field):
            iocs.append({'type': 'ip', 'value': alert[field], 'field': field})
    # Domain extraction
    for field in ['domain', 'url', 'dns_query']:
        if alert.get(field):
            iocs.append({'type': 'domain', 'value': alert[field], 'field': field})
    # Hash extraction
    for field in ['file_hash', 'md5', 'sha256']:
        if alert.get(field):
            iocs.append({'type': 'hash', 'value': alert[field], 'field': field})
    return iocs


async def check_virustotal_ip(ip: str) -> dict:
    """Check IP reputation on VirusTotal."""
    # Rate limit: 4 requests/minute on free tier
    async with rate_limiter('virustotal', max_per_minute=4):
        response = await http_get(
            f'https://www.virustotal.com/api/v3/ip_addresses/{ip}',
            headers={'x-apikey': get_secret('VIRUSTOTAL_API_KEY')},
            timeout=10
        )
        if response.status == 200:
            data = response.json()
            return {
                'source': 'virustotal',
                'ioc': ip,
                'malicious': data['data']['attributes']['last_analysis_stats']['malicious'],
                'total': sum(data['data']['attributes']['last_analysis_stats'].values()),
                'reputation': data['data']['attributes'].get('reputation', 0),
            }
        return {'source': 'virustotal', 'ioc': ip, 'error': f'HTTP {response.status}'}
```

### Pattern 2: Phishing Response Playbook

```yaml
# Shuffle SOAR / Generic SOAR playbook structure
playbook:
  name: "Phishing Email Response"
  description: "Automated triage and response for reported phishing emails"
  trigger:
    type: webhook
    source: "email-security-gateway"
    filter: "alert_type == 'phishing'"

  steps:
    - id: extract_iocs
      action: "Extract IOCs from email"
      type: automated
      inputs:
        email_headers: "{{ trigger.data.headers }}"
        email_body: "{{ trigger.data.body }}"
        attachments: "{{ trigger.data.attachments }}"
      outputs:
        urls: list
        domains: list
        ips: list
        attachment_hashes: list

    - id: enrich_iocs
      action: "Enrich all extracted IOCs"
      type: automated
      parallel: true
      depends_on: [extract_iocs]
      sub_steps:
        - check_virustotal: "{{ extract_iocs.urls + extract_iocs.attachment_hashes }}"
        - check_urlscan: "{{ extract_iocs.urls }}"
        - check_abuseipdb: "{{ extract_iocs.ips }}"

    - id: check_recipients
      action: "Identify all recipients of this email"
      type: automated
      depends_on: [extract_iocs]
      tool: "email-gateway-api"
      query: "message_id == '{{ trigger.data.message_id }}'"
      outputs:
        recipient_count: integer
        recipient_list: list

    - id: severity_assessment
      action: "Calculate severity"
      type: automated
      depends_on: [enrich_iocs, check_recipients]
      logic: |
        if any IOC is known-malicious AND recipients > 10:
          severity = "critical"
        elif any IOC is known-malicious:
          severity = "high"
        elif any IOC is suspicious:
          severity = "medium"
        else:
          severity = "low"

    - id: auto_quarantine
      action: "Quarantine email from all inboxes"
      type: automated
      depends_on: [severity_assessment]
      condition: "severity_assessment.severity in ['critical', 'high']"
      tool: "email-gateway-api"
      action_type: "quarantine"
      target: "{{ check_recipients.recipient_list }}"

    - id: block_domains
      action: "Block malicious domains"
      type: approval_required  # Human-in-the-loop
      depends_on: [severity_assessment]
      condition: "severity_assessment.severity == 'critical'"
      approvers: ["soc-team"]
      timeout: "30m"
      tool: "dns-firewall-api"
      action_type: "block"
      target: "{{ extract_iocs.domains }}"

    - id: create_ticket
      action: "Create incident ticket"
      type: automated
      depends_on: [severity_assessment]
      tool: "jira-api"
      template: "phishing-incident"
      fields:
        summary: "Phishing: {{ trigger.data.subject }}"
        severity: "{{ severity_assessment.severity }}"
        enrichment: "{{ enrich_iocs.results }}"
        recipients: "{{ check_recipients.recipient_count }}"

    - id: notify
      action: "Send notifications"
      type: automated
      depends_on: [create_ticket]
      channels:
        - type: slack
          channel: "#soc-alerts"
          condition: "severity in ['critical', 'high']"
        - type: pagerduty
          condition: "severity == 'critical'"
```

### Pattern 3: Automated Severity Calculation

```python
def calculate_severity(alert: dict, enrichment: dict) -> str:
    """
    Risk-based severity calculation using multiple signals.
    Returns: critical, high, medium, low, informational
    """
    score = 0

    # IOC reputation (0-40 points)
    if enrichment.get('ioc_malicious_count', 0) > 5:
        score += 40  # Multiple sources flag as malicious
    elif enrichment.get('ioc_malicious_count', 0) > 2:
        score += 25
    elif enrichment.get('ioc_suspicious', False):
        score += 10

    # Asset criticality (0-25 points)
    asset_crit = enrichment.get('asset_criticality', 'unknown')
    criticality_scores = {'critical': 25, 'high': 20, 'medium': 10, 'low': 5, 'unknown': 15}
    score += criticality_scores.get(asset_crit, 15)

    # User privilege level (0-15 points)
    if enrichment.get('user_is_admin', False):
        score += 15
    elif enrichment.get('user_is_privileged', False):
        score += 10

    # Historical context (0-10 points)
    related_count = enrichment.get('related_alerts_30d', 0)
    if related_count > 10:
        score += 10  # Repeated targeting
    elif related_count > 3:
        score += 5

    # Alert source confidence (0-10 points)
    if alert.get('confidence', 'medium') == 'high':
        score += 10
    elif alert.get('confidence', 'medium') == 'medium':
        score += 5

    # Map score to severity
    if score >= 75:
        return 'critical'
    elif score >= 50:
        return 'high'
    elif score >= 30:
        return 'medium'
    elif score >= 15:
        return 'low'
    else:
        return 'informational'
```

## Anti-Patterns

- **Automating without understanding the manual process first**: If you do not deeply understand the manual workflow, your automation will encode misunderstandings and edge cases into code that runs at machine speed.
- **Full automation from day one**: Start with enrichment (read-only), then triage (classification), then containment (action with approval). Do not jump straight to automated remediation.
- **No human-in-the-loop for high-impact actions**: Automatically disabling accounts, blocking IPs, or isolating endpoints without human review causes outages when false positives occur. Always start with approval gates for destructive actions.
- **Ignoring error handling**: An automation that fails silently is worse than no automation. Every external API call needs timeout, retry, and error reporting.
- **Hardcoded credentials in playbooks**: Playbook code is often stored in repositories or SOAR platforms. Use vault integration for all API keys and credentials.
- **Not testing with realistic data**: Test playbooks with realistic (sanitized) alert data, including edge cases and malformed inputs. Synthetic test data misses real-world complexity.

## References

- NIST SP 800-61 Rev 2 (Incident Handling Guide): https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final
- Shuffle SOAR: https://shuffler.io/
- TheHive Project: https://thehive-project.org/
- Cortex Analyzers: https://github.com/TheHive-Project/Cortex-Analyzers
- OASIS CACAO (Collaborative Automated Course of Action Operations): https://docs.oasis-open.org/cacao/security-playbooks/v2.0/security-playbooks-v2.0.html
- Splunk SOAR Playbook Best Practices: https://docs.splunk.com/Documentation/SOAR
