# Automated Response

> Automated remediation patterns, containment actions, and the decision framework for when to automate versus when to require human approval.

## Knowledge Base

### The Automation Decision Framework

Not every action should be automated. The decision depends on three factors:

**Reversibility**: Can the action be undone easily? Blocking an IP is reversible (unblock it). Deleting data is not. Reversible actions are better candidates for automation.

**Blast radius**: What is the worst-case impact if the automation acts on a false positive? Isolating one endpoint is limited blast radius. Blocking a CDN IP range affects thousands of users.

**Confidence**: How certain is the detection that triggered the action? A verified IOC from multiple threat feeds warrants automated response. A single low-confidence alert does not.

```
Automation Decision Matrix:

                    High Confidence    Low Confidence
                   ┌─────────────────┬─────────────────┐
  Reversible,      │ AUTOMATE        │ AUTOMATE with   │
  Low Blast Radius │ (no approval)   │ approval gate   │
                   ├─────────────────┼─────────────────┤
  Irreversible OR  │ AUTOMATE with   │ DO NOT          │
  High Blast Radius│ approval gate   │ AUTOMATE        │
                   └─────────────────┴─────────────────┘
```

### Common Automated Response Actions

| Action | Tool | Reversibility | Blast Radius | Typical Approval |
|--------|------|--------------|-------------|-----------------|
| Block IP at firewall | Palo Alto, Fortinet API | Reversible | Low (single IP) | Auto for known-malicious |
| Isolate endpoint | CrowdStrike, SentinelOne API | Reversible | Medium (user impacted) | Approval required |
| Disable user account | Okta, Azure AD API | Reversible | Medium (user impacted) | Approval required |
| Quarantine email | M365, Proofpoint API | Reversible | Low (single email) | Auto for confirmed phishing |
| Block domain at DNS | DNS firewall API | Reversible | Low-Medium | Auto for known-malicious |
| Kill process | EDR API | Irreversible (process state lost) | Low | Auto for known malware |
| Delete file | EDR API, endpoint script | Irreversible | Low | Approval required |
| Reset password | IAM API | Partially reversible | Medium | Approval required |
| Revoke sessions | IAM API | Reversible (re-auth) | Medium | Auto for confirmed compromise |

### Containment Timing

Research consistently shows that containment speed is the strongest predictor of breach cost reduction.

```
Timeline of automated vs. manual response:

Automated (SOAR):
  Alert ──(seconds)──> Enrichment ──(seconds)──> Triage ──(seconds)──> Containment
  Total: 1-5 minutes

Manual:
  Alert ──(minutes)──> Analyst sees alert ──(minutes)──> Investigation ──(minutes)──> Containment
  Total: 30-120 minutes (often hours if after-hours)

After-hours manual:
  Alert ──(hours)──> Analyst paged ──(minutes)──> Investigation ──(minutes)──> Containment
  Total: 1-4 hours

The gap between automated and manual response is where damage accumulates.
```

## Patterns

### Pattern 1: Endpoint Containment Playbook

```python
"""
Playbook: Automated Endpoint Containment
Trigger: EDR alert with high confidence malware detection
Approval: Required for production servers, auto for workstations
"""

async def contain_endpoint(alert: dict) -> dict:
    """Orchestrate endpoint containment."""

    endpoint_id = alert['endpoint_id']
    hostname = alert['hostname']

    # Step 1: Gather context (parallel)
    asset_info, user_info, recent_alerts = await asyncio.gather(
        get_asset_info(hostname),
        get_user_info(alert.get('username')),
        get_recent_alerts(endpoint_id, hours=24),
    )

    # Step 2: Determine if approval is needed
    needs_approval = (
        asset_info.get('criticality') in ['critical', 'high'] or
        asset_info.get('type') == 'server' or
        user_info.get('is_executive', False)
    )

    # Step 3: Request approval if needed, otherwise auto-contain
    if needs_approval:
        approval = await request_approval(
            channel='#soc-approvals',
            message=f"Contain {hostname}? Asset: {asset_info['type']}, "
                    f"User: {alert.get('username')}, "
                    f"Detection: {alert['detection_name']}",
            timeout_minutes=15,
            escalate_to='on-call-manager'
        )
        if not approval.approved:
            return {'action': 'pending', 'reason': 'Approval denied or timed out'}

    # Step 4: Execute containment
    containment_result = await isolate_endpoint(
        endpoint_id=endpoint_id,
        allow_dns=True,     # Allow DNS for troubleshooting
        allow_dhcp=True,    # Keep network lease
        note=f"Auto-contained: {alert['detection_name']} "
             f"(Alert ID: {alert['alert_id']})"
    )

    # Step 5: Additional containment actions
    if alert.get('username'):
        await revoke_user_sessions(alert['username'])

    # Step 6: Create incident and notify
    incident = await create_incident(
        title=f"Malware containment: {hostname}",
        severity=alert.get('severity', 'high'),
        description=f"Endpoint {hostname} auto-contained due to "
                    f"{alert['detection_name']}. "
                    f"User sessions revoked for {alert.get('username')}.",
        artifacts={
            'alert': alert,
            'asset': asset_info,
            'containment': containment_result,
        }
    )

    await notify_stakeholders(
        channels=['#soc-alerts', '#it-ops'],
        message=f"Endpoint {hostname} contained. "
                f"Incident: {incident['id']}. "
                f"User {alert.get('username')} sessions revoked."
    )

    return {
        'action': 'contained',
        'endpoint': hostname,
        'incident_id': incident['id'],
        'containment_result': containment_result,
    }
```

### Pattern 2: IOC Blocking Playbook

```python
"""
Playbook: Automated IOC Blocking
Trigger: Threat intelligence feed or analyst submission
Risk: Low-Medium (reversible, but false positive blocks legitimate traffic)
"""

async def block_ioc(ioc: dict) -> dict:
    """Block a confirmed malicious IOC across security controls."""

    ioc_type = ioc['type']  # ip, domain, hash, url
    ioc_value = ioc['value']
    confidence = ioc.get('confidence', 'medium')

    # Step 1: Validate IOC
    if not validate_ioc_format(ioc_type, ioc_value):
        return {'action': 'rejected', 'reason': 'Invalid IOC format'}

    # Step 2: Check against allowlist (prevent blocking critical infrastructure)
    if await is_allowlisted(ioc_value):
        await notify_analyst(
            f"IOC {ioc_value} matches allowlist. Manual review required."
        )
        return {'action': 'blocked_by_allowlist', 'ioc': ioc_value}

    # Step 3: Check for blast radius
    blast_radius = await assess_blast_radius(ioc_type, ioc_value)
    if blast_radius['affected_users'] > 100:
        approval = await request_approval(
            message=f"Blocking {ioc_value} would affect "
                    f"{blast_radius['affected_users']} users. Approve?",
            timeout_minutes=30
        )
        if not approval.approved:
            return {'action': 'pending_approval', 'blast_radius': blast_radius}

    # Step 4: Block across security controls
    results = {}

    if ioc_type == 'ip':
        results['firewall'] = await block_ip_firewall(ioc_value)
        results['siem_watchlist'] = await add_to_siem_watchlist(ioc_value, 'ip')

    elif ioc_type == 'domain':
        results['dns_firewall'] = await block_domain_dns(ioc_value)
        results['proxy'] = await block_domain_proxy(ioc_value)
        results['siem_watchlist'] = await add_to_siem_watchlist(ioc_value, 'domain')

    elif ioc_type == 'hash':
        results['edr_block'] = await block_hash_edr(ioc_value)
        results['siem_watchlist'] = await add_to_siem_watchlist(ioc_value, 'hash')

    # Step 5: Set expiration (IOC blocks should not be permanent)
    expiration_days = {'high': 90, 'medium': 30, 'low': 7}
    await schedule_unblock(
        ioc_value,
        days=expiration_days.get(confidence, 30),
        review_required=True
    )

    # Step 6: Log and document
    await log_block_action(
        ioc=ioc,
        results=results,
        expiration=expiration_days.get(confidence, 30),
        source=ioc.get('source', 'unknown')
    )

    return {'action': 'blocked', 'ioc': ioc_value, 'results': results}
```

### Pattern 3: Alert Fatigue Reduction

```python
"""
Playbook: Alert Deduplication and Correlation
Reduces alert fatigue by grouping related alerts into incidents.
"""

async def correlate_alerts(new_alert: dict) -> dict:
    """Check if new alert belongs to an existing incident."""

    # Look for related alerts in the last 24 hours
    related = await find_related_alerts(
        new_alert,
        lookback_hours=24,
        correlation_fields=[
            'src_ip',
            'dest_ip',
            'username',
            'hostname',
            'detection_name',
        ]
    )

    if related['matches']:
        # Add to existing incident instead of creating new alert
        existing_incident = related['matches'][0]['incident_id']
        await add_alert_to_incident(existing_incident, new_alert)
        await update_incident_severity(existing_incident)  # May escalate

        return {
            'action': 'correlated',
            'incident_id': existing_incident,
            'related_alert_count': len(related['matches']),
            'new_alert_created': False
        }

    # No correlation -- create new incident
    incident = await create_incident_from_alert(new_alert)

    return {
        'action': 'new_incident',
        'incident_id': incident['id'],
        'new_alert_created': True
    }
```

### Pattern 4: Scheduled Threat Intelligence Update

```python
"""
Playbook: Automated Threat Intelligence Processing
Trigger: Schedule (every 6 hours)
Purpose: Ingest, deduplicate, and operationalize threat feeds
"""

async def process_threat_feeds():
    """Pull and process all configured threat feeds."""

    feeds = [
        {'name': 'AlienVault OTX', 'type': 'otx', 'url': '...'},
        {'name': 'Abuse.ch URLhaus', 'type': 'csv', 'url': '...'},
        {'name': 'CISA Known Exploited', 'type': 'json', 'url': '...'},
        {'name': 'Internal TI Platform', 'type': 'stix', 'url': '...'},
    ]

    for feed in feeds:
        try:
            # Fetch
            raw_data = await fetch_feed(feed)

            # Normalize to STIX format
            normalized = normalize_to_stix(raw_data, feed['type'])

            # Deduplicate against existing IOC database
            new_iocs = await deduplicate(normalized)

            # Score by confidence and relevance
            scored = score_iocs(new_iocs, organization_context)

            # High-confidence IOCs: auto-deploy to security controls
            high_confidence = [i for i in scored if i['confidence'] >= 0.8]
            for ioc in high_confidence:
                await block_ioc(ioc)  # Uses the IOC blocking playbook

            # Medium-confidence: add to watchlist (alert but do not block)
            medium_confidence = [i for i in scored if 0.5 <= i['confidence'] < 0.8]
            for ioc in medium_confidence:
                await add_to_siem_watchlist(ioc)

            # Log stats
            await log_feed_processing(
                feed=feed['name'],
                total=len(raw_data),
                new=len(new_iocs),
                blocked=len(high_confidence),
                watchlisted=len(medium_confidence),
            )

        except Exception as e:
            await alert_on_feed_failure(feed['name'], str(e))
```

## Anti-Patterns

- **Automating containment without blast radius checks**: Automatically blocking an IP that turns out to be a CDN node (Cloudflare, AWS) can take down the business. Always check against an allowlist of critical infrastructure IPs and domains.
- **Permanent IOC blocks**: Threat infrastructure changes. An IP that is malicious today may be reassigned to a legitimate service tomorrow. All blocks should have expiration dates with review requirements.
- **Automation without observability**: If you cannot see what your automation is doing (what it blocked, what it allowed, what errors occurred), you cannot trust it and you cannot debug it.
- **Cascading automation without circuit breakers**: One false positive triggering a chain of automated responses (block IP, isolate endpoint, disable account, page management) is an automation catastrophe. Include circuit breakers that pause automation when action volume exceeds thresholds.
- **Automating the wrong things first**: Automating rare, complex scenarios provides little value. Automate high-volume, low-complexity tasks first (enrichment, triage routing, known-bad blocking).
- **No rollback capability**: Every automated action should have a documented and tested rollback procedure. Automation without rollback is a one-way street toward outages.

## References

- NIST SP 800-61 Rev 2 (Incident Handling): https://csrc.nist.gov/publications/detail/sp/800-61/rev-2/final
- OASIS CACAO Security Playbooks: https://docs.oasis-open.org/cacao/security-playbooks/v2.0/security-playbooks-v2.0.html
- FIRST CSIRT Services Framework: https://www.first.org/standards/frameworks/csirts/csirt_services_framework_v2.1
- RE&CT Framework (Response Actions): https://atc-project.github.io/atc-react/
- Palantir Alert and Detection Strategy Framework: https://blog.palantir.com/alerting-and-detection-strategy-framework-52dc33722f
