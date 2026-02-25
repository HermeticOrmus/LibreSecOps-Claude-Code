# /compliance-check

> Assess a system against a specified compliance framework and produce a gap analysis report.

## Trigger

Use this command when:
- Preparing for a compliance audit (SOC 2, ISO 27001, PCI DSS, etc.)
- Evaluating compliance posture of a new or existing system
- Determining which controls need to be implemented for a specific framework
- Mapping existing security controls to framework requirements
- Assessing readiness for a customer security questionnaire

## Input

Required:
- **Framework**: `soc2`, `gdpr`, `pci-dss`, `hipaa`, `iso27001`, `nist-800-53`, `nist-csf`

Optional:
- **Scope**: Description of in-scope systems, data types, and processes
- **Profile/Level**: For frameworks with tiers (NIST 800-53: Low/Moderate/High, ISO 27001: specific Annex A controls)
- **Existing controls**: Description of security measures already in place
- **Exclusions**: Controls known to be not applicable with justification

## Process

### Step 1: Scope Definition

1. Identify the systems, data, and processes in scope for the framework
2. Determine the applicable profile or tier level
3. For PCI DSS: determine the cardholder data environment (CDE) boundaries
4. For GDPR: identify personal data processing activities and legal bases
5. For HIPAA: identify covered entities, business associates, and ePHI flows
6. Document scope boundaries and exclusions with justifications

### Step 2: Control Inventory

Based on the framework, enumerate all applicable controls:

**SOC 2** (Trust Service Criteria):
- CC1: Control Environment (7 criteria)
- CC2: Communication and Information (3 criteria)
- CC3: Risk Assessment (4 criteria)
- CC4: Monitoring Activities (2 criteria)
- CC5: Control Activities (3 criteria)
- CC6: Logical and Physical Access Controls (8 criteria)
- CC7: System Operations (5 criteria)
- CC8: Change Management (1 criterion)
- CC9: Risk Mitigation (2 criteria)
- Plus criteria for selected additional categories (Availability, Processing Integrity, Confidentiality, Privacy)

**GDPR** (Key Articles):
- Article 5: Data processing principles
- Article 6: Lawful basis for processing
- Articles 12-23: Data subject rights
- Article 25: Data protection by design and default
- Article 28: Processor requirements
- Article 30: Records of processing activities
- Article 32: Security of processing
- Article 33-34: Breach notification
- Article 35: Data Protection Impact Assessment
- Article 44-49: International transfers

**PCI DSS v4.0** (12 Requirements):
- Req 1-2: Network security
- Req 3-4: Data protection
- Req 5-6: Vulnerability management
- Req 7-8: Access control
- Req 9: Physical security
- Req 10: Logging and monitoring
- Req 11: Security testing
- Req 12: Security policy

### Step 3: Current State Assessment

For each control:
1. Determine if a corresponding control exists in the environment
2. Assess its design effectiveness (does it address the requirement?)
3. Assess its operating effectiveness (is it consistently applied?)
4. Identify evidence of the control's operation
5. Rate: Fully Met, Partially Met, Not Met, Not Applicable

### Step 4: Gap Analysis

For each gap (Partially Met or Not Met):
1. Describe the specific deficiency
2. Assess the risk of the gap (what could go wrong)
3. Estimate remediation effort (hours/days/weeks)
4. Identify dependencies (other gaps that must be fixed first)
5. Recommend a remediation approach

### Step 5: Report Generation

Compile findings into a compliance assessment report.

## Output

```
# Compliance Assessment: [Framework]

**Date**: [date]
**Scope**: [in-scope description]
**Profile**: [applicable tier/level]

## Summary
| Status | Count | Percentage |
|--------|-------|------------|
| Fully Met | | |
| Partially Met | | |
| Not Met | | |
| Not Applicable | | |

## Overall Readiness: [Ready | Needs Work | Significant Gaps]

## Control Assessment
[Section-by-section assessment with status, evidence, and gaps]

## Critical Gaps
[Gaps that would result in audit failure or qualified opinion]

## Remediation Roadmap
[Prioritized plan to close gaps before audit]

## Evidence Status
[What evidence exists and what needs to be collected]
```
