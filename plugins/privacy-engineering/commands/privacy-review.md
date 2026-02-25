# /privacy-review

> Review a system, feature, or architecture for privacy concerns, producing a structured assessment with findings categorized by privacy principle and regulatory requirement.

## Trigger

Use when evaluating the privacy posture of a system or feature. Appropriate for:
- New feature design review (before development)
- Architecture review for privacy implications
- Pre-launch privacy assessment
- Code review focused on personal data handling
- Third-party integration privacy assessment
- Post-incident privacy evaluation

## Input

- **System/feature description**: What the system does and what data it processes
- **Architecture details**: System components, data stores, external services, APIs
- **Data categories**: Types of personal data collected or processed (if known)
- **Code or configuration** (optional): Relevant code handling personal data
- **Regulatory context**: Applicable privacy regulations (GDPR, CCPA, HIPAA, etc.)
- **Intended users**: Who the system serves (consumers, employees, patients, children, etc.)

## Process

1. **Personal data identification** -- Identify all personal data in the system:
   - Direct identifiers (name, email, phone, SSN, IP address)
   - Indirect identifiers (location, device fingerprint, behavioral patterns)
   - Sensitive data (health, biometric, racial/ethnic origin, political opinions, religious beliefs)
   - Derived data (inferences, profiles, scores, predictions)

2. **Purpose assessment** -- For each data element, evaluate:
   - What is the stated purpose of collection?
   - Is the data necessary for that purpose (data minimization)?
   - Could the purpose be achieved with less data or anonymized data?
   - Are there secondary uses beyond the stated purpose (function creep)?

3. **Legal basis evaluation** -- For each processing activity:
   - What is the legal basis (consent, contract, legitimate interest, legal obligation)?
   - Is the legal basis appropriate for this type of processing?
   - If consent, is it freely given, specific, informed, and unambiguous?
   - If legitimate interest, has a balancing test been conducted?

4. **Technical controls assessment** -- Evaluate existing controls:
   - Encryption (at rest, in transit, field-level)
   - Access controls (who can access what personal data)
   - Pseudonymization (are identifiers separated from attributes?)
   - Anonymization (is any data claimed to be anonymous truly anonymous?)
   - Retention and deletion (are there automatic deletion mechanisms?)
   - Logging and audit (is access to personal data logged?)

5. **Data subject rights** -- Evaluate implementation of:
   - Right of access (can data subjects get a copy of their data?)
   - Right to rectification (can they correct inaccurate data?)
   - Right to erasure (can they request deletion?)
   - Right to portability (can they export their data?)
   - Right to restriction (can they limit processing?)
   - Right to object (can they object to processing?)

6. **Third-party assessment** -- For external services:
   - What personal data is shared?
   - Is there a Data Processing Agreement?
   - Is the third party in an adequate jurisdiction?
   - Are there appropriate transfer safeguards (SCCs, BCRs)?

## Output

```
## Privacy Review Report

**System/Feature**: [name]
**Date**: [review date]
**Regulations**: [applicable regulations]

### Personal Data Inventory
| Data Element | Category | Sensitive? | Purpose | Legal Basis | Minimized? |
|-------------|----------|-----------|---------|------------|-----------|
| [element] | [PII/sensitive] | [yes/no] | [purpose] | [basis] | [yes/no] |

### Findings

#### [HIGH] Finding Title
**Principle**: [data minimization / purpose limitation / transparency / etc.]
**Regulation**: [specific article or section]
**Risk**: [what harm could result for data subjects]
**Current state**: [what the system does now]
**Recommendation**: [specific technical change]

### Data Subject Rights Implementation
| Right | Implemented? | Mechanism | Gap |
|-------|-------------|-----------|-----|
| Access | [yes/no/partial] | [how] | [what is missing] |
| Erasure | [yes/no/partial] | [how] | [what is missing] |

### Third-Party Data Sharing
| Partner | Data Shared | DPA? | Jurisdiction | Transfer Mechanism |
|---------|------------|------|-------------|-------------------|
| [name] | [data] | [y/n] | [country] | [SCCs/adequacy/BCR] |

### Recommendations Priority
1. **[CRITICAL]**: [most urgent privacy fix]
2. **[HIGH]**: [second priority]
3. **[MEDIUM]**: [third priority]
```
