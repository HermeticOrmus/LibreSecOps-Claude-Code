# Privacy by Design

> The seven foundational principles of Privacy by Design with practical implementation patterns for software engineering.

## Knowledge Base

### Origin and Context

Privacy by Design (PbD) was developed by Dr. Ann Cavoukian, former Information and Privacy Commissioner of Ontario, Canada. The framework was formally adopted as an international standard in 2010 by the International Assembly of Privacy Commissioners. GDPR Article 25 codified "data protection by design and by default" into law, making PbD a legal requirement for organizations processing EU residents' data.

PbD is not a checklist -- it is a design philosophy. The principles guide architectural decisions, feature design, and engineering practices throughout the system lifecycle.

### The Seven Foundational Principles

**Principle 1: Proactive not Reactive; Preventive not Remedial**

Privacy measures must be designed in from the start, not added after privacy incidents occur.

Implementation patterns:
- Include privacy requirements in feature specifications alongside functional requirements
- Conduct privacy threat modeling (LINDDUN) during architecture design
- Perform DPIAs before building high-risk features, not after launch
- Include privacy criteria in definition-of-done for user stories

Anti-patterns:
- Building features first, then "adding privacy later"
- Conducting privacy reviews only when regulators ask
- Treating privacy incidents as the trigger for privacy improvements

**Principle 2: Privacy as the Default Setting**

Users should not need to take action to protect their privacy. The most privacy-protective settings must be the defaults.

Implementation patterns:
```python
# Default to most restrictive sharing
class UserProfile:
    profile_visibility = "private"        # NOT "public"
    location_sharing = False              # NOT True
    activity_tracking = False             # NOT True
    third_party_data_sharing = False      # NOT True
    marketing_communications = False      # NOT True
```

- Opt-in for data collection beyond what is necessary for the core service
- Opt-in for marketing and promotional communications
- Minimum data collection by default (do not pre-check optional fields)
- Shortest reasonable retention periods by default
- Most restrictive sharing settings by default

Anti-patterns:
- Pre-checked consent boxes
- Public-by-default profiles
- Requiring users to navigate through settings to disable tracking
- Dark patterns that make privacy-protective choices difficult

**Principle 3: Privacy Embedded into Design**

Privacy must be an integral component of system architecture, not an add-on or afterthought.

Implementation patterns:
- Separate identity stores from behavioral data stores at the architecture level
- Design database schemas with privacy in mind (personal data in separate tables, foreign key relationships that support selective deletion)
- Build consent management into the data pipeline, not as a UI overlay
- Implement data classification at the schema level

```sql
-- Privacy-aware schema design
-- Personal data in dedicated table with access controls
CREATE TABLE user_identities (
    id UUID PRIMARY KEY,
    email VARCHAR(255) ENCRYPTED,
    name VARCHAR(255) ENCRYPTED,
    phone VARCHAR(20) ENCRYPTED,
    created_at TIMESTAMP,
    retention_expires_at TIMESTAMP  -- Automatic cleanup
);

-- Behavioral data pseudonymized with token reference
CREATE TABLE user_activities (
    id UUID PRIMARY KEY,
    user_token UUID,  -- Pseudonymous reference, NOT user_id
    activity_type VARCHAR(50),
    activity_data JSONB,
    created_at TIMESTAMP
);
```

Anti-patterns:
- Mixing personal data with operational data in the same tables
- Storing personal data in log files without redaction
- Architectural designs that make data deletion technically difficult

**Principle 4: Full Functionality -- Positive-Sum, not Zero-Sum**

Privacy and functionality are not in conflict. Reject false dichotomies ("we need to track everything for the product to work").

Implementation patterns:
- Use aggregated analytics instead of individual tracking where possible
- Implement differential privacy for analytics that need individual-level signals
- Design recommendations using on-device processing when feasible
- Use privacy-preserving computation (federated learning, secure aggregation)

Example: Instead of "we need to track every page view per user for personalization," use collaborative filtering on anonymized interaction patterns or on-device personalization.

Anti-patterns:
- Framing privacy as the enemy of innovation
- Claiming maximum data collection is necessary without evaluating alternatives
- Treating privacy as a feature to be traded off against other features

**Principle 5: End-to-End Security -- Full Lifecycle Protection**

Personal data must be protected throughout its entire lifecycle: collection, processing, storage, sharing, and deletion.

Implementation patterns:
- Encryption at rest (database, file storage, backups)
- Encryption in transit (TLS 1.2+ for all connections)
- Field-level encryption for highly sensitive data (SSN, health data)
- Secure deletion (cryptographic erasure for encrypted data, overwrite for unencrypted)
- Backup alignment with retention policies
- Secure development practices (no personal data in logs, error messages, or developer environments)

```python
# Cryptographic erasure pattern
# Instead of deleting every record, destroy the encryption key
class UserDataManager:
    def create_user_data(self, user_id, data):
        # Generate per-user encryption key
        user_key = generate_key()
        store_key(user_id, user_key)
        encrypted_data = encrypt(data, user_key)
        store_data(user_id, encrypted_data)

    def delete_user_data(self, user_id):
        # Destroy the key -- all encrypted data becomes unreadable
        destroy_key(user_id)
        # Data can be physically deleted later in batch cleanup
```

Anti-patterns:
- Encrypting data at rest but logging it in plaintext
- Deleting active records but leaving backups with personal data indefinitely
- Using production personal data in development/staging environments

**Principle 6: Visibility and Transparency**

Data processing must be visible and verifiable. Users should understand what happens to their data.

Implementation patterns:
- Clear, layered privacy notices (summary + detail)
- Privacy dashboards showing data collected, purposes, and sharing
- Audit logging of access to personal data
- Machine-readable privacy policies (P3P successor, .well-known/privacy)
- Data subject access request automation (one-click data export)
- Transparency reports on government data requests

Anti-patterns:
- Privacy policies written in impenetrable legal language
- No mechanism for users to see what data is held about them
- No audit trail for internal access to personal data
- "Dark pattern" interfaces that obscure privacy choices

**Principle 7: Respect for User Privacy -- Keep it User-Centric**

Privacy design must center on the interests of the individual, not the organization. Default to what the user would reasonably expect.

Implementation patterns:
- Granular consent (per purpose, not blanket)
- Easy consent withdrawal (as easy as giving consent)
- Meaningful control over data sharing
- User-friendly data portability (standard formats, not proprietary)
- Responsive data subject request handling (within 30 days per GDPR)
- Accessible privacy controls (not buried in settings menus)

```javascript
// Granular consent implementation
const consentModel = {
  essential: true,          // Always on, no consent needed (contract)
  analytics: false,         // Default off, opt-in
  marketing: false,         // Default off, opt-in
  thirdPartySharing: false, // Default off, opt-in
  personalization: false,   // Default off, opt-in
  // Each can be toggled independently
  // Withdrawal is one click, same as granting
};
```

Anti-patterns:
- "Accept all" as the prominent option with "manage preferences" hidden
- Consent withdrawal that requires contacting support or navigating obscure settings
- Data portability in proprietary formats
- Data subject requests handled manually with multi-week delays

## Patterns

### Pattern: Privacy Threat Modeling (LINDDUN)
Apply LINDDUN methodology during architecture review:
- **L**inkability: Can data from different sources be linked to the same individual?
- **I**dentifiability: Can pseudonymous data be re-identified?
- **N**on-repudiation: Is there unwanted proof of an individual's actions?
- **D**etectability: Can the existence of personal data be detected?
- **D**isclosure: Can personal data be exposed inappropriately?
- **U**nawareness: Are data subjects unaware of processing?
- **N**on-compliance: Does processing violate regulations or policies?

### Pattern: Data Minimization Review
For every data element, ask three questions:
1. Is this data necessary for the stated purpose?
2. Could the purpose be achieved with less granular data?
3. Could the purpose be achieved with anonymized or aggregated data?

### Pattern: Purpose-Based Access Control
Beyond role-based access control, implement purpose-based access. A customer support agent can access a customer's order history (purpose: support resolution) but not their browsing behavior (purpose: analytics).

## Anti-Patterns

- **Consent as a cure-all**: Consent is one of six legal bases under GDPR. It is not appropriate for all processing and should not be used as a catch-all
- **Notice fatigue**: Overwhelming users with privacy notices and consent dialogs until they click "accept" without reading. Layered, clear notices are more effective
- **Privacy theater**: Implementing visible privacy controls (cookie banners) while continuing invasive tracking through other channels (fingerprinting, server-side tracking)
- **Anonymization overconfidence**: Claiming data is anonymous when it is merely pseudonymous. True anonymization must resist re-identification including through linkage with other datasets

## References

- Cavoukian, Ann -- "Privacy by Design: The 7 Foundational Principles" -- https://iapp.org/resources/article/privacy-by-design-the-7-foundational-principles/
- GDPR Article 25 -- Data protection by design and by default
- LINDDUN Privacy Threat Modeling -- https://linddun.org/
- NIST Privacy Framework -- https://www.nist.gov/privacy-framework
- Article 29 Working Party -- Guidelines on DPIA (WP248 rev.01)
- ICO Privacy by Design Guidance -- https://ico.org.uk/for-organisations/guide-to-data-protection/guide-to-the-general-data-protection-regulation-gdpr/accountability-and-governance/data-protection-by-design-and-default/
- ISO 31700:2023 -- Consumer protection: Privacy by design for consumer goods and services
