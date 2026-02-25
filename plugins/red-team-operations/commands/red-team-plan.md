# /red-team-plan

> Create a structured adversary simulation plan with threat scenario, scope, rules of engagement, and phased operation design.

## Trigger

Use when you need to:

- Plan a red team engagement for authorized testing
- Structure an adversary simulation exercise
- Define rules of engagement and scope for an upcoming test
- Design a purple team exercise with detection validation points
- Prepare a red team proposal for stakeholder approval

**PREREQUISITE**: Written authorization from the system owner must be in place or in progress. This command produces a plan document, not an attack.

## Input

- **Required**: Target organization description (industry, size, technology stack, threat landscape)
- **Required**: Objective of the engagement (test detection, test response, validate controls, compliance requirement)
- **Optional**: Specific threat actor to emulate (e.g., "APT29-like scenario" or "ransomware group TTPs")
- **Optional**: Known constraints (off-limits systems, testing windows, budget)
- **Optional flag**: `--purple` -- design as a collaborative purple team exercise with built-in detection validation

## Process

1. **Threat Scenario Selection**: Based on the organization's industry, geography, and technology stack, identify the most relevant threat scenario:
   - Which threat actors target this type of organization?
   - What are their known TTPs?
   - What is their typical objective (data theft, ransomware, espionage, disruption)?

2. **Scope Definition**: Define the boundaries of the engagement:
   - In-scope systems, networks, and applications
   - Out-of-scope systems (production critical systems, third-party systems, etc.)
   - Authorized access methods
   - Prohibited actions (no data destruction, no customer data access, etc.)

3. **Rules of Engagement**: Establish operational boundaries:
   - Testing windows (business hours, after hours, weekends)
   - Notification requirements (who knows, who does not know)
   - Emergency stop procedures
   - Deconfliction (how to distinguish red team from real attacker)
   - Evidence handling (screenshots, logs, accessed data)
   - Legal review requirements

4. **ATT&CK Technique Selection**: Map the chosen threat scenario to specific MITRE ATT&CK techniques for each phase:
   - Initial Access (how does the adversary get in)
   - Execution (how do they run code)
   - Persistence (how do they maintain access)
   - Privilege Escalation (how do they get higher access)
   - Defense Evasion (how do they avoid detection)
   - Credential Access (how do they steal credentials)
   - Lateral Movement (how do they spread)
   - Collection and Exfiltration (how do they achieve their objective)

5. **Phase Design**: Structure the operation into phases with decision gates:
   - Each phase has an objective, techniques, and success/failure criteria
   - Decision gates determine whether to proceed, adjust, or stop
   - Purple team touchpoints define where to pause and share findings

6. **Detection Expectations**: For each phase, document what the blue team should detect if their controls are working properly.

7. **Reporting Structure**: Define the report format, audience, and delivery timeline.

## Output

```
# Red Team Engagement Plan: [Engagement Name]
Classification: [Confidential / Internal]
Version: [X.Y]
Date: [date]

## 1. Executive Summary
[What, why, expected outcome -- 1 paragraph]

## 2. Authorization
- Sponsor: [name and title]
- Authorization status: [APPROVED / PENDING]
- Legal review: [COMPLETED / PENDING]

## 3. Threat Scenario
- Emulated adversary: [name or profile]
- Scenario narrative: [realistic attack story]
- Objective: [what the adversary is trying to achieve]

## 4. Scope & Rules of Engagement
[Detailed scope and ROE tables]

## 5. Operation Phases

### Phase 1: [Name] (Days X-Y)
**Objective**: [what this phase achieves]
**ATT&CK Techniques**:
- T1566.001: Spearphishing Attachment
- T1059.001: PowerShell
**Blue Team Detection Expectation**:
- Email gateway should flag malicious attachment
- EDR should alert on Office spawning PowerShell
**Decision Gate**: [proceed/adjust/stop criteria]

### Phase 2: [Name] (Days X-Y)
[Same structure]

## 6. Safety Controls
- Emergency contact: [name, phone, email]
- Stop code: [code word]
- Deconfliction: [procedure]

## 7. Deliverables
- Daily status: [channel]
- Final report: [date]
- Debrief presentation: [date]
- Remediation roadmap: [date]
```
