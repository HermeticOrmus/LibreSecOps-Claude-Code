# /data-flow-map

> Map personal data flows through a system, identifying collection points, processing activities, storage locations, sharing partners, and retention periods.

## Trigger

Use when you need to understand and document how personal data moves through a system. Required for:
- GDPR Article 30 Records of Processing Activities
- Data Protection Impact Assessments (input)
- Privacy review foundation
- Data subject access request implementation
- Data breach impact assessment (what data was where)
- System migration planning (ensuring all personal data is identified)

## Input

- **System name and purpose**: What the system does
- **Architecture description**: Components, databases, APIs, external services
- **User types**: Who interacts with the system (customers, employees, partners)
- **Known data elements**: Personal data types collected (if known; will be expanded during mapping)
- **Third-party services**: External services, APIs, analytics, payment processors
- **Deployment**: Cloud provider(s), regions, CDN

## Process

1. **Collection point identification** -- Map every point where personal data enters the system:
   - User registration forms
   - Login/authentication
   - Profile updates
   - Content creation (posts, comments, uploads)
   - Transaction processing
   - Customer support interactions
   - Automated collection (cookies, device fingerprinting, analytics, logging)
   - Third-party data imports (social login, data enrichment)

2. **Processing activity mapping** -- For each data element, trace:
   - What processing occurs (storage, analysis, transformation, profiling)
   - Which system components handle the data
   - What internal APIs transfer data between components
   - Where data is transformed, aggregated, or derived

3. **Storage identification** -- Map all locations where personal data persists:
   - Primary databases (relational, NoSQL, graph)
   - Search indices (Elasticsearch, Algolia)
   - Cache layers (Redis, Memcached)
   - File storage (S3, local filesystem, CDN)
   - Log aggregators (CloudWatch, ELK, Splunk)
   - Analytics platforms (Google Analytics, Mixpanel, Amplitude)
   - Email/notification services (SendGrid, Twilio)
   - Backup systems (database backups, disaster recovery)
   - Development/staging environments (often contain production data copies)

4. **Sharing mapping** -- Identify all data sharing:
   - Third-party processors (payment, email, hosting)
   - Third-party controllers (analytics providers, advertising)
   - Government/regulatory (legal obligations)
   - Cross-border transfers (what data leaves the jurisdiction)
   - Employee access (who within the organization can see what)

5. **Retention mapping** -- For each storage location:
   - What is the retention period?
   - Is there an automatic deletion mechanism?
   - What triggers deletion (time-based, event-based, user request)?
   - Are backups aligned with retention periods?

6. **Data flow diagram creation** -- Produce a visual representation showing data subjects, collection points, processing components, storage, sharing, and deletion.

## Output

```
## Personal Data Flow Map: [System Name]

### System Overview
**Purpose**: [what the system does]
**Data subjects**: [who the data is about]
**Data controller**: [organization]
**Data processors**: [list of processors]

### Data Collection Points

| # | Collection Point | Data Elements | Method | Legal Basis |
|---|-----------------|--------------|--------|------------|
| 1 | [registration form] | [name, email, password] | [direct input] | [contract] |
| 2 | [login] | [IP, timestamp, device] | [automatic] | [legitimate interest] |

### Data Flow Diagram

```
[Data Subject]
    |
    v
[Web/Mobile App] --personal data--> [API Server]
    |                                     |
    |                                     v
    |                              [Primary DB] (name, email, etc.)
    |                                     |
    |                                     v
    |                              [Analytics Service] (usage patterns)
    |                                     |
    v                                     v
[CDN] (uploaded content)          [Email Service] (email address)
    |                                     |
    v                                     v
[Cloud Storage] (S3)              [Third-party processor]
```

### Processing Activities

| Activity | Purpose | Data Elements | Legal Basis | Automated Decision? |
|----------|---------|--------------|------------|-------------------|
| [activity] | [purpose] | [elements] | [basis] | [yes/no] |

### Storage Locations

| Location | Data Elements | Encryption | Retention | Auto-Delete? | Region |
|----------|--------------|-----------|-----------|-------------|--------|
| [database] | [elements] | [at rest?] | [period] | [yes/no] | [region] |
| [logs] | [elements] | [at rest?] | [period] | [yes/no] | [region] |
| [backups] | [elements] | [at rest?] | [period] | [yes/no] | [region] |

### Third-Party Sharing

| Partner | Purpose | Data Shared | DPA Signed? | Jurisdiction | Transfer Mechanism |
|---------|---------|------------|------------|-------------|-------------------|
| [name] | [purpose] | [elements] | [yes/no] | [country] | [adequacy/SCCs] |

### Retention Schedule

| Data Category | Retention Period | Basis | Deletion Mechanism |
|--------------|-----------------|-------|-------------------|
| [category] | [period] | [why this period] | [automatic/manual] |

### Cross-Border Transfers

| Data | From | To | Mechanism | Risk Assessment |
|------|------|-----|-----------|----------------|
| [elements] | [origin] | [destination] | [safeguard] | [risk level] |

### Gaps and Recommendations
1. [Identified gap with recommendation]
2. [Next gap]
```
