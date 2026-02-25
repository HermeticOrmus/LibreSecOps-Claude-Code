# /security-policy

> Generate a security policy document tailored to organizational context, regulatory requirements, and workforce profile.

## Trigger

Use when creating new security policies or updating existing ones. Appropriate for:
- Establishing a security policy framework for a new organization
- Updating policies for regulatory compliance (GDPR, HIPAA, SOC 2, PCI-DSS)
- Creating role-specific policies (developer security, remote work, BYOD)
- Standardizing informal security practices into formal documentation
- Preparing for security audits or certifications

## Input

- **Policy type**: Which policy to create. Options include:
  - Acceptable Use Policy
  - Information Classification and Handling
  - Incident Reporting and Response
  - Access Control and Authentication
  - Password and Credential Management
  - Remote Work and BYOD
  - Data Retention and Disposal
  - Vendor and Third-Party Risk
  - Change Management
  - Physical Security
  - Social Media and Public Communication
  - Encryption and Key Management
  - Network Security
  - Mobile Device Management
- **Organization context**: Industry, size, risk profile, existing policies
- **Regulatory requirements**: Applicable regulations and standards
- **Audience**: Who the policy applies to (all employees, IT staff, contractors, etc.)
- **Enforcement model**: How violations are handled in the organization
- **Existing policies** (optional): Related policies already in place for cross-referencing

## Process

1. **Requirements gathering** -- Identify the regulatory, business, and risk requirements the policy must address

2. **Scope definition** -- Determine who the policy applies to, what systems/data/activities it covers, and any explicit exclusions

3. **Policy drafting** -- Write the policy in clear, direct language:
   - Use active voice ("You must..." not "It is required that...")
   - Provide concrete examples for abstract requirements
   - Include the rationale for each requirement
   - Avoid unnecessary jargon (or define it in a glossary)
   - Keep sentences short and paragraphs focused on one topic

4. **Regulatory mapping** -- Map policy requirements to specific regulatory controls:
   - NIST CSF subcategories
   - ISO 27001 Annex A controls
   - CIS Controls
   - Specific regulatory clauses (HIPAA 164.312, GDPR Art. 32, etc.)

5. **Enforcement framework** -- Define:
   - How compliance is monitored
   - What constitutes a violation
   - Progressive discipline approach
   - Exception request process
   - Appeal process

6. **Review and maintenance** -- Set review schedule and change management process

## Output

```
# [Organization] [Policy Type] Policy

**Document ID**: [POL-XXX]
**Version**: [1.0]
**Classification**: [Internal]
**Owner**: [CISO / Security Team]
**Approved by**: [Executive Sponsor]
**Effective date**: [date]
**Review date**: [date + review cycle]

---

## 1. Purpose
[Clear statement of why this policy exists and what it protects]

## 2. Scope
**Applies to**: [who -- employees, contractors, third parties]
**Covers**: [what -- systems, data, activities]
**Exceptions**: [any explicit exclusions]

## 3. Definitions
| Term | Definition |
|------|-----------|
| [term] | [plain-language definition] |

## 4. Policy

### 4.1 [Topic Area]
**Requirement**: [Clear statement of what must/must not be done]
**Rationale**: [Why this matters]
**Examples**:
- [Concrete example of compliant behavior]
- [Concrete example of non-compliant behavior]

### 4.2 [Topic Area]
[Same structure]

## 5. Roles and Responsibilities
| Role | Responsibilities |
|------|-----------------|
| All employees | [specific duties] |
| Managers | [specific duties] |
| IT/Security team | [specific duties] |
| Executive leadership | [specific duties] |

## 6. Compliance Monitoring
[How adherence is measured and monitored]

## 7. Enforcement
[Progressive discipline: verbal warning -> written warning -> suspension -> termination]
[Note: proportional to severity and intent]

## 8. Exceptions
**Process**: [How to request an exception]
**Approval**: [Who approves]
**Documentation**: [What must be recorded]
**Review**: [How often exceptions are reviewed]

## 9. Related Documents
| Document | Relationship |
|----------|-------------|
| [policy name] | [how it relates] |

## 10. Regulatory Mapping
| Requirement | Regulation | Clause |
|-------------|-----------|--------|
| [policy requirement] | [regulation] | [specific clause] |

## Revision History
| Version | Date | Author | Changes |
|---------|------|--------|---------|

---

**Acknowledgment**
I have read and understand this policy. I agree to comply with its requirements.

Signature: _______________ Date: _______________
```
