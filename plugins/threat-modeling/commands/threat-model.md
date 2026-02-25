# /threat-model

> Generate a complete threat model for a system using STRIDE methodology with prioritized threats and recommended mitigations.

## Trigger

Use this command when:
- Designing a new system or service (the best time to threat model)
- Adding significant new features that change data flows or trust boundaries
- Reviewing the security posture of an existing system
- Preparing for a security audit or compliance assessment
- After a security incident to identify what threats were missed

## Input

Required:
- **System description**: Architecture overview -- what components exist, how they communicate, what data they handle, who the users are

Optional:
- **Architecture diagram**: DFD, component diagram, or sequence diagrams
- **Technology stack**: Specific frameworks, databases, message queues, cloud services
- **Compliance requirements**: Frameworks that apply (PCI DSS, HIPAA, SOC 2, GDPR)
- **Known threats**: Previously identified threats to carry forward
- **Focus area**: Specific component or data flow to focus on (for incremental modeling)

## Process

### Step 1: System Decomposition

1. Identify all system components (processes, services, functions)
2. Identify all data stores (databases, caches, file systems, queues, logs)
3. Identify all external entities (users, third-party services, external APIs)
4. Map all data flows between components, stores, and entities
5. Define trust boundaries (where privilege levels change, where networks change, where organizations change)
6. Identify the sensitivity of data on each flow (PII, credentials, financial, health, public)

### Step 2: Data Flow Diagram Construction

Build a text-based DFD showing:
```
[External Entity] ---(data flow)---> [Process] ---(data flow)---> [Data Store]
                                        |
                                   [Trust Boundary]
                                        |
                              [Another Process]
```

For each element, note:
- Processes: What they do, what privileges they run with
- Data stores: What they contain, who has access
- Data flows: What data, encrypted or cleartext, authenticated or not
- Trust boundaries: What changes at each boundary

### Step 3: STRIDE Analysis

For each element in the DFD, apply the applicable STRIDE categories:

**Spoofing (Authentication threats)**:
- Can an attacker impersonate a user, service, or system component?
- Where is authentication enforced? Where is it missing?

**Tampering (Integrity threats)**:
- Can data be modified in transit or at rest?
- Are there integrity checks (signatures, checksums, MACs)?

**Repudiation (Audit threats)**:
- Can a user deny performing an action?
- Is there sufficient logging and non-repudiation evidence?

**Information Disclosure (Confidentiality threats)**:
- Can data be exposed to unauthorized parties?
- In transit, at rest, in error messages, in logs?

**Denial of Service (Availability threats)**:
- Can the service be disrupted?
- Resource exhaustion, dependency failure, queue flooding?

**Elevation of Privilege (Authorization threats)**:
- Can a user gain permissions they shouldn't have?
- Horizontal (accessing other users' data) and vertical (user to admin)?

### Step 4: Risk Rating

For each threat, assess:
- **Likelihood**: How likely is this to be attempted and succeed?
- **Impact**: What is the consequence of successful exploitation?
- **Risk**: Likelihood x Impact = prioritization score

Use DREAD or a simple High/Medium/Low matrix.

### Step 5: Mitigation Mapping

For each significant threat:
1. Identify the appropriate security control category
2. Recommend a specific implementation
3. Assess the mitigation's effectiveness
4. Note any residual risk after mitigation

### Step 6: Report Assembly

Compile findings into the structured threat model document.

## Output

```
# Threat Model: [System Name]
**Version**: [number]
**Date**: [date]
**Modeled by**: [who]
**Scope**: [what's included]

## 1. System Overview
[Business context and system purpose]

## 2. Data Flow Diagram
[Text-based DFD]

## 3. Assets
[What we're protecting and why]

## 4. Threat Analysis
[STRIDE analysis per component with risk ratings]

## 5. Prioritized Mitigations
[Ordered by risk reduction, grouped by effort]

## 6. Accepted Risks
[Documented risk acceptance with rationale]

## 7. Assumptions and Dependencies
[What this model assumes about the environment]

## 8. Review Schedule
[When this model should be revisited]
```
