# SOC 2 Controls

> SOC 2 Type II Trust Service Criteria reference covering Security, Availability, Processing Integrity, Confidentiality, and Privacy with common controls and evidence requirements.

## Knowledge Base

### SOC 2 Overview

SOC 2 (System and Organization Controls 2) is an audit framework developed by the AICPA (American Institute of Certified Public Accountants) for service organizations. It evaluates controls relevant to the Trust Service Criteria.

**Type I**: Point-in-time assessment of control design (do the controls exist?).
**Type II**: Assessment of control design AND operating effectiveness over a period (typically 12 months). Type II is what customers typically require.

### Trust Service Categories

| Category | Required? | Focus |
|----------|-----------|-------|
| Security (Common Criteria) | Always | Protection against unauthorized access |
| Availability | Optional | System availability per commitments |
| Processing Integrity | Optional | System processing is complete, valid, accurate, timely |
| Confidentiality | Optional | Confidential information is protected |
| Privacy | Optional | Personal information collection, use, retention, disclosure, disposal |

### Common Criteria (Security) -- Detailed Controls

#### CC1: Control Environment

**CC1.1**: The entity demonstrates a commitment to integrity and ethical values.
- Evidence: Code of conduct, employee handbook, whistleblower policy
- Common control: Signed acknowledgment of code of conduct during onboarding

**CC1.2**: The board of directors demonstrates independence from management.
- Evidence: Board meeting minutes, board composition, independent directors
- Applicable mainly to larger organizations

**CC1.3**: Management establishes structures, reporting lines, and authorities.
- Evidence: Organization chart, role descriptions, RACI matrix for security responsibilities

**CC1.4**: The entity demonstrates commitment to attract, develop, and retain competent individuals.
- Evidence: Job descriptions with security qualifications, training records, performance reviews

**CC1.5**: The entity holds individuals accountable for their internal control responsibilities.
- Evidence: Security responsibilities in job descriptions, security metrics in reviews, policy violation consequences

#### CC2: Communication and Information

**CC2.1**: The entity obtains or generates relevant, quality information.
- Evidence: Security monitoring dashboards, risk assessment reports, vulnerability scan results

**CC2.2**: The entity internally communicates information.
- Evidence: Security awareness training, policy distribution, security newsletter/updates, incident notification records

**CC2.3**: The entity communicates with external parties.
- Evidence: Customer security documentation, vendor security requirements, regulatory notifications, service status page

#### CC3: Risk Assessment

**CC3.1**: The entity specifies objectives with sufficient clarity.
- Evidence: Information security policy, security objectives, risk appetite statement

**CC3.2**: The entity identifies risks to the achievement of its objectives.
- Evidence: Risk assessment document, threat model, risk register

**CC3.3**: The entity considers the potential for fraud.
- Evidence: Fraud risk assessment, separation of duties analysis, anti-fraud controls

**CC3.4**: The entity identifies and assesses changes that could significantly impact the system.
- Evidence: Change management process, architecture review for significant changes, M&A security assessment

#### CC5: Control Activities

**CC5.1**: The entity selects and develops control activities.
- Evidence: Control inventory, security architecture documentation

**CC5.2**: The entity selects and develops general controls over technology.
- Evidence: IT general controls documentation, automated controls inventory

**CC5.3**: The entity deploys control activities through policies.
- Evidence: Security policies, procedures, standards. Policy review and approval records.

#### CC6: Logical and Physical Access Controls

**CC6.1**: Logical access security software, infrastructure, and architectures.
- Evidence: Network diagram, firewall rules, VPN configuration, encryption configuration
- Common controls: WAF, IDS/IPS, network segmentation, TLS everywhere

**CC6.2**: Prior to issuing system credentials, the entity registers and authorizes new users.
- Evidence: User provisioning process, approval workflows, onboarding checklist
- Common controls: HR-initiated access requests, manager approval, role-based access

**CC6.3**: The entity authorizes, modifies, or removes access based on roles.
- Evidence: RBAC configuration, access review records, offboarding checklist showing access revocation
- Common controls: Quarterly access reviews, automated offboarding, least privilege enforcement

**CC6.4**: The entity restricts physical access to facilities and protected information assets.
- Evidence: Badge access logs, visitor logs, data center access controls
- Cloud note: Covered by cloud provider's SOC 2 for IaaS/PaaS components

**CC6.5**: The entity discontinues logical and physical access when no longer needed.
- Evidence: Termination access revocation records (within 24 hours), access review removal records
- Common controls: Automated deprovisioning integrated with HR system

**CC6.6**: The entity implements logical access security measures.
- Evidence: MFA configuration, password policy, session timeout settings
- Common controls: MFA on all accounts, SSO, password manager deployment

**CC6.7**: The entity restricts the transmission, movement, and removal of information.
- Evidence: DLP policies, email security configuration, removable media policy
- Common controls: Email DLP, endpoint DLP, encrypted file transfer

**CC6.8**: The entity implements controls to prevent or detect and act on unauthorized or malicious software.
- Evidence: Endpoint protection configuration, malware scan results, application allowlisting
- Common controls: EDR deployment, email attachment scanning, web content filtering

#### CC7: System Operations

**CC7.1**: To meet its objectives, the entity uses detection and monitoring procedures.
- Evidence: SIEM configuration, alert rules, monitoring dashboards, on-call rotation
- Common controls: Centralized logging, real-time alerting, 24/7 monitoring (or defined business hours)

**CC7.2**: The entity monitors system components for anomalies.
- Evidence: Anomaly detection configuration, baseline definitions, alert tuning records
- Common controls: IDS/IPS, UEBA, threat intelligence feeds

**CC7.3**: The entity evaluates security events to determine whether they are incidents.
- Evidence: Incident triage process, event classification criteria, triage records
- Common controls: Security event review process, escalation procedures

**CC7.4**: The entity responds to identified security incidents.
- Evidence: Incident response plan, incident tickets, postmortem reports, tabletop exercise records
- Common controls: Documented IR plan, defined roles, annual tabletop exercises

**CC7.5**: The entity identifies, develops, and implements activities to recover from incidents.
- Evidence: Recovery procedures, BCP/DR plan, backup verification records, recovery test results
- Common controls: Tested backup restoration, documented recovery procedures

#### CC8: Change Management

**CC8.1**: The entity authorizes, designs, develops or acquires, configures, documents, tests, approves, and implements changes.
- Evidence: Change management policy, PR review records, deployment logs, rollback procedures
- Common controls: PR reviews with approval, staging environments, automated testing, deployment pipelines

#### CC9: Risk Mitigation

**CC9.1**: The entity identifies, selects, and develops risk mitigation activities.
- Evidence: Risk treatment plans, control implementation evidence, risk acceptance records

**CC9.2**: The entity assesses and manages risks associated with vendors and business partners.
- Evidence: Vendor risk assessment questionnaires, vendor SOC 2 reports, vendor inventory, contract security requirements
- Common controls: Annual vendor security reviews, security requirements in contracts, vendor SOC 2 collection

### Evidence Quick Reference

| Control Area | Key Evidence |
|-------------|-------------|
| Access Control | IAM policy screenshots, access review records, MFA enrollment report |
| Change Management | Git PR history with reviews, CI/CD pipeline config, deployment logs |
| Vulnerability Management | Scan reports, remediation tickets, patch deployment records |
| Incident Response | IR plan document, incident tickets, postmortem reports, tabletop records |
| Monitoring | SIEM dashboard screenshots, alert configuration, on-call schedule |
| Encryption | TLS configuration, encryption-at-rest settings, key management procedures |
| Backup/Recovery | Backup configuration, restoration test records, BCP/DR plan |
| Vendor Management | Vendor inventory, assessment records, SOC 2 reports from vendors |
| Employee Security | Training completion records, background check policy, onboarding/offboarding records |
| Policy | Approved policies with review dates, distribution/acknowledgment records |

## Patterns

### SOC 2 Readiness Pattern

1. **Scope definition** (Month 1): Define the system boundary, select Trust Service categories
2. **Gap assessment** (Month 1-2): Assess current controls against criteria
3. **Remediation** (Month 2-6): Implement missing controls, document existing ones
4. **Evidence collection setup** (Month 3-6): Automate evidence collection, establish review cadences
5. **Observation period begins** (Month 6): Start the 12-month observation window
6. **Mid-period check** (Month 12): Internal assessment to verify controls are operating
7. **Audit** (Month 18): External auditor assessment of the 12-month period

### Common Auditor Requests

1. "Show me a list of all users with access to production systems and when their access was last reviewed"
2. "Show me evidence that code changes are reviewed before deployment"
3. "Show me the last three incidents and how they were handled"
4. "Show me vulnerability scan results and evidence that findings were remediated"
5. "Show me your backup verification -- when was the last successful restore test?"
6. "Show me evidence of security awareness training completion for all employees"

## Anti-Patterns

- **Checkbox compliance**: Implementing the minimum to pass without building real security. Auditors increasingly test operating effectiveness, not just existence.
- **Annual compliance sprints**: Scrambling to prepare evidence in the weeks before an audit. Continuous compliance through automation is far less painful.
- **Over-scoping**: Including every system in the SOC 2 scope. Reduce scope to the systems that actually process customer data.
- **Generic policies**: Copying policy templates without customizing to your organization. Auditors will ask questions that reveal generic policies.
- **Ignoring vendor risk**: Assuming your cloud provider's SOC 2 covers everything. Shared responsibility means you still own configuration, access control, and application security.
- **No evidence of control operation**: Having a policy that says "access reviews occur quarterly" but no records of quarterly access reviews actually happening.

## References

- [AICPA Trust Service Criteria (2017)](https://www.aicpa.org/interestareas/frc/assuranceadvisoryservices/trustdataintegritytaskforce.html)
- [AICPA SOC 2 Reporting](https://www.aicpa-cima.com/topic/audit-assurance/audit-and-assurance-greater-than-soc-2)
- [COSO Internal Control Framework](https://www.coso.org/guidance-on-ic)
- [SOC 2 Academy (educational resource)](https://www.itgovernance.co.uk/soc-reporting)
