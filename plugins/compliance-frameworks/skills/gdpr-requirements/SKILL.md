# GDPR Requirements

> GDPR compliance patterns for technology organizations covering data processing principles, data subject rights, technical and organizational measures, and breach notification.

## Knowledge Base

### GDPR Overview

The General Data Protection Regulation (EU 2016/679) is the European Union's data protection law. It applies to any organization that processes personal data of individuals in the EU/EEA, regardless of where the organization is located. Non-compliance can result in fines up to 20 million EUR or 4% of global annual turnover, whichever is higher.

### Key Definitions

| Term | Definition |
|------|-----------|
| **Personal data** | Any information relating to an identified or identifiable natural person (data subject). Includes: name, email, IP address, location data, cookie identifiers, health data, biometric data. |
| **Processing** | Any operation performed on personal data: collection, storage, use, transmission, erasure, and everything in between. |
| **Controller** | The entity that determines the purposes and means of processing. (Your organization, if you decide what data to collect and why.) |
| **Processor** | The entity that processes data on behalf of the controller. (Your cloud provider, email service, analytics provider.) |
| **Data subject** | The individual whose personal data is being processed. |
| **DPA** | Data Protection Authority -- the regulatory body that enforces GDPR in each EU member state. |
| **DPO** | Data Protection Officer -- required for certain organizations (Article 37). |

### Article 5: Data Processing Principles

These seven principles are the foundation of GDPR. Every processing activity must comply with all of them.

**1. Lawfulness, Fairness, and Transparency**
- Processing must have a lawful basis (Article 6)
- Data subjects must be informed about how their data is processed
- Privacy policy must be clear, accessible, and written in plain language
- No hidden data collection or processing

**Implementation**: Privacy policy, cookie consent, clear data collection notices, Records of Processing Activities (ROPA).

**2. Purpose Limitation**
- Data must be collected for specified, explicit, and legitimate purposes
- Data cannot be processed for purposes incompatible with the original purpose
- Secondary use requires separate legal basis or compatibility assessment

**Implementation**: Document the purpose for each data collection. Review new features to ensure data isn't repurposed without basis.

**3. Data Minimization**
- Collect only the personal data that is adequate, relevant, and limited to what is necessary
- Don't collect "just in case" data
- Regularly review what data you're collecting and whether you still need it

**Implementation**: Review registration forms, API data collection, logging, and analytics. Remove unnecessary fields. Anonymize where possible.

**4. Accuracy**
- Personal data must be accurate and kept up to date
- Inaccurate data must be rectified or erased without delay

**Implementation**: Data validation on input, user profile editing capabilities, data quality processes.

**5. Storage Limitation**
- Data must not be kept longer than necessary for the stated purpose
- Define and enforce retention periods for each data category
- Anonymize or delete data when the retention period expires

**Implementation**: Data retention policy, automated data deletion/anonymization, retention period configuration per data type.

**6. Integrity and Confidentiality**
- Personal data must be processed securely
- Appropriate technical and organizational measures against unauthorized access, destruction, loss, or damage

**Implementation**: Encryption at rest and in transit, access controls, audit logging, security testing, incident response plan.

**7. Accountability**
- The controller must be able to demonstrate compliance with all principles
- Documentation is mandatory, not optional

**Implementation**: ROPA, DPIA records, consent records, processing agreements, audit trails, training records.

### Article 6: Lawful Bases for Processing

Every processing activity must have one of these six lawful bases:

| Basis | When to Use | Example |
|-------|-------------|---------|
| **Consent** | Data subject has given clear consent for a specific purpose | Marketing emails, analytics cookies, newsletter |
| **Contract** | Processing is necessary to fulfill a contract with the data subject | Shipping address for delivery, email for account creation |
| **Legal obligation** | Processing required by EU/member state law | Tax records, employment law requirements |
| **Vital interests** | Protect someone's life (rarely applicable in tech) | Medical emergency data sharing |
| **Public interest** | Processing for a task in the public interest | Government services, research |
| **Legitimate interests** | Necessary for controller's legitimate interests, balanced against data subject rights | Fraud prevention, network security, direct marketing to existing customers |

**Consent requirements** (Article 7):
- Must be freely given (not bundled with other agreements)
- Must be specific (per purpose, not blanket)
- Must be informed (data subject knows what they're consenting to)
- Must be unambiguous (clear affirmative action, no pre-ticked boxes)
- Must be withdrawable (as easy to withdraw as to give)
- Must be documented (you must prove consent was obtained)

### Articles 12-23: Data Subject Rights

| Right | Article | Obligation | Response Time |
|-------|---------|-----------|---------------|
| **Information** | 13-14 | Provide clear information about data processing | At time of collection |
| **Access** | 15 | Provide a copy of all personal data processed | 1 month |
| **Rectification** | 16 | Correct inaccurate personal data | 1 month |
| **Erasure (Right to be Forgotten)** | 17 | Delete personal data when no longer necessary | 1 month |
| **Restriction** | 18 | Restrict processing in certain circumstances | 1 month |
| **Data Portability** | 20 | Provide data in a structured, machine-readable format | 1 month |
| **Objection** | 21 | Stop processing based on legitimate interests | Without undue delay |
| **Automated Decision-Making** | 22 | Right not to be subject to solely automated decisions with legal effects | Implement safeguards |

**Implementation requirements**:
- Build data export functionality (API or admin tool) for access and portability requests
- Build data deletion functionality that covers all data stores (database, backups, logs, caches, third-party services)
- Create a process for receiving, authenticating, and responding to data subject requests within 1 month
- Track all requests with timestamps and response records

### Article 25: Data Protection by Design and Default

**By Design**: Integrate data protection into the design of processing activities and systems from the start, not as an afterthought.

Technical measures:
- Pseudonymization and encryption
- Data minimization in system design
- Access control by default
- Audit logging for personal data access

**By Default**: Only personal data necessary for each specific purpose is processed. By default, collect the minimum and restrict access to the minimum.

Implementation:
- Default privacy settings should be the most protective
- No opt-out approaches -- use opt-in
- New features start with data minimization review
- Privacy impact assessment for new processing activities

### Article 28: Processor Requirements

When using third-party processors (cloud providers, SaaS tools, analytics services):

1. **Data Processing Agreement (DPA)**: Required contract specifying processing instructions, security measures, sub-processor rules, deletion obligations, and audit rights
2. **Sub-processor management**: Processor must inform controller of new sub-processors with opportunity to object
3. **Security obligations**: Processor must implement appropriate technical and organizational measures
4. **Audit rights**: Controller must be able to audit processor compliance (often satisfied by processor's SOC 2 or ISO 27001)

### Articles 33-34: Breach Notification

**To the DPA (Article 33)**:
- Within **72 hours** of becoming aware of a personal data breach
- Unless the breach is unlikely to result in a risk to individuals
- Must include: nature of breach, categories/number of data subjects, likely consequences, measures taken
- If notification can't be complete within 72 hours, provide information in phases

**To data subjects (Article 34)**:
- Without undue delay if the breach is likely to result in a **high risk** to their rights
- Not required if data was encrypted/pseudonymized, if subsequent measures eliminated the risk, or if individual notification would be disproportionate effort (use public communication instead)

### Article 35: Data Protection Impact Assessment (DPIA)

Required when processing is likely to result in **high risk** to data subjects. Mandatory for:
- Systematic and extensive profiling with significant effects
- Large-scale processing of special categories (health, biometric, genetic data)
- Systematic monitoring of publicly accessible areas
- Processing that involves new technologies

DPIA must contain:
1. Description of processing operations and purposes
2. Assessment of necessity and proportionality
3. Assessment of risks to data subjects
4. Measures to address risks

## Patterns

### GDPR Compliance Checklist for SaaS Applications

**Data Mapping**:
- [ ] Document all personal data collected, where it's stored, and why
- [ ] Create Records of Processing Activities (ROPA)
- [ ] Identify lawful basis for each processing activity
- [ ] Map data flows to third-party processors

**User-Facing**:
- [ ] Privacy policy accessible and written in plain language
- [ ] Cookie consent with granular opt-in (not pre-ticked)
- [ ] Consent records stored with timestamp and version
- [ ] Data subject request process (access, deletion, portability)
- [ ] Account deletion capability that covers all data stores
- [ ] Data export in machine-readable format (JSON, CSV)

**Technical**:
- [ ] Encryption at rest for personal data
- [ ] Encryption in transit (TLS 1.2+)
- [ ] Access control on personal data (least privilege)
- [ ] Audit logging for personal data access
- [ ] Data retention enforcement (automated deletion)
- [ ] Pseudonymization where possible (analytics, logs)
- [ ] Backup procedures that respect deletion requests

**Organizational**:
- [ ] Data Processing Agreements with all processors
- [ ] Sub-processor list maintained and communicated
- [ ] Breach notification procedure (72-hour timeline)
- [ ] DPIA process for high-risk processing
- [ ] Employee training on data protection
- [ ] DPO appointed (if required)

### Data Deletion Pattern

When a user requests account deletion (Article 17):

1. Authenticate the requester (verify identity)
2. Delete from primary database
3. Delete from read replicas (propagation delay)
4. Delete from caches (Redis, CDN)
5. Delete from search indices (Elasticsearch)
6. Queue deletion from backups (or document retention with justification)
7. Delete from third-party services (analytics, email, CRM)
8. Retain only data required by legal obligation (with documentation)
9. Confirm deletion to the data subject within 1 month
10. Log the deletion request and completion (without logging the deleted personal data)

## Anti-Patterns

- **"We're not in the EU, GDPR doesn't apply"**: If you process personal data of individuals in the EU, GDPR applies regardless of your location.
- **Pre-ticked consent boxes**: Not valid consent under GDPR. Consent must be an affirmative action.
- **Bundled consent**: "By using our service, you consent to all processing." Must be specific and granular.
- **Ignoring processors**: Using SaaS tools that process personal data without DPAs in place.
- **Incomplete deletion**: Deleting from the main database but not from backups, caches, logs, analytics, and third-party services.
- **No retention policy**: Keeping personal data indefinitely "just in case." Define and enforce retention periods.
- **Cookie wall**: Blocking access to a website unless all cookies are accepted. Most DPAs consider this non-free consent.
- **Treating legitimate interest as a free pass**: Legitimate interest requires a balancing test and is not appropriate for all processing. It doesn't override data subject objection rights.

## References

- [GDPR Full Text (EUR-Lex)](https://eur-lex.europa.eu/legal-content/EN/TXT/?uri=CELEX:32016R0679)
- [Article 29 Working Party Guidelines (now EDPB)](https://edpb.europa.eu/our-work-tools/general-guidance/guidelines-recommendations-best-practices_en)
- [ICO Guide to GDPR (UK)](https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/)
- [CNIL GDPR Guide (France)](https://www.cnil.fr/en/gdpr-developers-guide)
- [NOYB - Data Protection Enforcement Tracker](https://noyb.eu/)
- [GDPRhub - Case Law Database](https://gdprhub.eu/)
