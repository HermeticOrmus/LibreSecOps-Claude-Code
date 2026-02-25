# /compliance-gap

> Identify specific compliance gaps between current state and framework requirements, with prioritized remediation roadmap.

## Trigger

Use this command when:
- A compliance assessment has identified gaps that need remediation planning
- Preparing a remediation project plan before an upcoming audit
- Prioritizing security investments based on compliance requirements
- A customer or partner requires specific compliance certifications and you need to identify the work required

## Input

Required:
- **Framework**: Target compliance framework
- **Current state**: Description of existing security controls, policies, and practices

Optional:
- **Audit date**: When the audit is scheduled (drives priority and timeline)
- **Budget/resources**: Available budget and team capacity (drives feasibility)
- **Previous assessment**: Results of prior compliance assessment for delta tracking
- **Multi-framework**: Additional frameworks to map gaps against (enables efficient multi-framework remediation)

## Process

### Step 1: Gap Identification

For each framework requirement, determine the gap type:

| Gap Type | Description | Example |
|----------|-------------|---------|
| **Missing Control** | No control exists to address the requirement | No vulnerability scanning program |
| **Incomplete Control** | Control exists but doesn't fully meet the requirement | Access reviews happen but not quarterly |
| **Undocumented Control** | Control exists and works but has no documentation | Backup process works but no policy exists |
| **Missing Evidence** | Control exists and is documented but evidence isn't collected | MFA is enforced but no enrollment reports are generated |
| **Stale Evidence** | Evidence exists but is outdated | Last penetration test was 18 months ago |

### Step 2: Risk Assessment per Gap

For each gap, assess:
- **Audit risk**: Likelihood the auditor will test this control and the consequence of failure (exception, qualified opinion, material weakness)
- **Security risk**: Does this gap represent an actual security weakness or just a documentation gap?
- **Business risk**: Could this gap affect customer trust, contracts, or regulatory standing?

### Step 3: Remediation Options

For each gap, identify remediation approaches:

1. **Implement**: Build or configure the missing control
2. **Document**: Write the policy, procedure, or evidence for an existing control
3. **Automate**: Set up automated evidence collection for an existing control
4. **Accept**: Document the gap with risk acceptance and compensating controls (only for low-risk gaps)
5. **Compensate**: Implement an alternative control that achieves the same objective

### Step 4: Prioritization

Rank gaps using a priority matrix:

| Priority | Criteria | Timeline |
|----------|----------|----------|
| P1 - Critical | Would cause audit failure, significant security risk | Before audit |
| P2 - High | Would cause exception or finding, moderate security risk | Before audit if possible |
| P3 - Medium | Minor finding, documentation gap, low security risk | During audit period |
| P4 - Low | Enhancement, not likely to be tested | After audit |

### Step 5: Remediation Roadmap

Build a timeline-aware remediation plan:
1. Group related gaps into work streams (e.g., "access control improvements," "documentation effort," "monitoring implementation")
2. Identify dependencies between gaps
3. Estimate effort for each work stream
4. Assign ownership
5. Set milestones aligned with audit date
6. Include evidence collection in the remediation plan (not just the control implementation)

### Step 6: Multi-Framework Optimization (if applicable)

When multiple frameworks apply:
1. Identify gaps that affect multiple frameworks
2. Prioritize these gaps higher (maximum compliance ROI)
3. Design controls that satisfy the most restrictive requirement (superset approach)
4. Map single pieces of evidence to multiple framework requirements

## Output

```
# Compliance Gap Analysis

**Framework**: [name and version]
**Current State**: [summary of existing controls]
**Audit Date**: [if known]
**Assessment Date**: [date]

## Gap Summary
| Gap Type | Count | Critical | High | Medium | Low |
|----------|-------|----------|------|--------|-----|
| Missing Control | | | | | |
| Incomplete Control | | | | | |
| Undocumented Control | | | | | |
| Missing Evidence | | | | | |
| Stale Evidence | | | | | |

## Detailed Gaps

### P1 - Critical Gaps
#### [Gap Title]
- **Requirement**: [framework control ID and description]
- **Gap Type**: [Missing/Incomplete/Undocumented/Evidence]
- **Current State**: [what exists now]
- **Required State**: [what the framework requires]
- **Remediation**: [specific actions]
- **Effort**: [estimated hours/days]
- **Owner**: [responsible team/person]
- **Evidence Needed**: [what the auditor will want to see]
- **Cross-Framework**: [other frameworks this gap affects]

## Remediation Roadmap

### Work Stream 1: [Name]
**Gaps Addressed**: [gap IDs]
**Effort**: [total estimate]
**Dependencies**: [prerequisite work streams]
**Milestones**:
- [ ] [Milestone 1] - [date]
- [ ] [Milestone 2] - [date]

## Quick Wins (High Impact, Low Effort)
[Gaps that can be closed quickly for maximum compliance improvement]

## Risk Acceptances
[Gaps recommended for acceptance with justification and compensating controls]
```
