# /incident-postmortem

> Generate a structured blameless post-incident review from incident timeline, actions taken, and outcomes.

## Trigger

Use this command when:
- A security incident has been resolved and is ready for review
- A near-miss event occurred that warrants analysis
- Periodic review of past incidents for pattern identification
- Compliance requirements mandate documented incident reviews

## Input

Required:
- **Incident summary**: What happened, when, and what was the impact
- **Timeline**: Sequence of events from detection through resolution

Optional:
- **Actions taken**: What containment, eradication, and recovery steps were performed
- **Root cause**: If already determined, the underlying cause
- **Impact metrics**: Duration, affected users, data exposure scope, financial impact

## Process

### Step 1: Timeline Construction

Build a complete, chronological timeline from all available information:

1. **Initial compromise** (if known): When the attacker first gained access
2. **Dwell time**: Period between compromise and detection
3. **Detection**: How and when the incident was first identified
4. **Triage**: When severity was classified and response activated
5. **Containment**: When spread was stopped
6. **Eradication**: When the threat was removed
7. **Recovery**: When services were restored
8. **Resolution**: When the incident was declared resolved

Key metrics to extract:
- **Mean Time to Detect (MTTD)**: Time from compromise to detection
- **Mean Time to Respond (MTTR)**: Time from detection to containment
- **Mean Time to Recover**: Time from containment to full service restoration
- **Total incident duration**: End-to-end from compromise to resolution

### Step 2: Root Cause Analysis

Use the "5 Whys" technique to drill past symptoms to root causes:

1. Why did the incident occur? (Proximate cause)
2. Why was that possible? (Contributing factor)
3. Why wasn't it prevented? (Control failure)
4. Why didn't we detect it sooner? (Detection gap)
5. Why wasn't there a faster remediation path? (Process gap)

Distinguish between:
- **Root cause**: The fundamental reason the incident happened
- **Contributing factors**: Conditions that enabled or amplified the incident
- **Triggering event**: The specific action that initiated the incident

### Step 3: What Went Well

Document what worked:
- Detection mechanisms that fired correctly
- Response procedures that were followed effectively
- Communication that was clear and timely
- Technical controls that limited blast radius
- Team actions that prevented escalation

### Step 4: What Could Be Improved

Document improvement areas (blameless):
- Detection gaps that allowed dwell time
- Response delays and their causes
- Communication breakdowns
- Missing or inadequate runbooks
- Tool or access limitations that slowed response
- Knowledge gaps that needed to be filled during the incident

### Step 5: Action Items

For each improvement area, create specific, actionable items:
- **What**: Clear description of the change
- **Why**: Which aspect of the incident this prevents or improves
- **Owner**: Who is responsible
- **Priority**: Critical (prevents recurrence) / High (significant improvement) / Medium (incremental improvement)
- **Deadline**: When it should be completed
- **Verification**: How to confirm the action was completed and effective

### Step 6: Report Assembly

Compile all sections into the postmortem document.

## Output

```
# Post-Incident Review

## Incident: [ID] - [Title]
**Date**: [incident date]
**Severity**: SEV[1-4]
**Duration**: [total time from detection to resolution]
**Review Date**: [postmortem date]
**Participants**: [who participated in the review]

## Executive Summary
[2-3 paragraph summary suitable for leadership: what happened, what was the impact, what are we doing about it]

## Impact
- **Service impact**: [what was affected and for how long]
- **Data impact**: [what data was exposed/modified/destroyed]
- **User impact**: [how many users affected and how]
- **Financial impact**: [estimated cost including response, remediation, and business impact]
- **Regulatory impact**: [notification requirements triggered]

## Timeline
| Time (UTC) | Event | Category |
|------------|-------|----------|

## Key Metrics
| Metric | Value |
|--------|-------|
| Time to detect | |
| Time to respond | |
| Time to contain | |
| Time to recover | |
| Total duration | |

## Root Cause Analysis
### Root Cause
[What fundamentally caused this incident]

### Contributing Factors
[What made it possible or worse]

### 5 Whys
1. Why: ...
2. Why: ...
3. Why: ...
4. Why: ...
5. Why: ...

## What Went Well
- [Positive item 1]
- [Positive item 2]

## What Could Be Improved
- [Improvement area 1]
- [Improvement area 2]

## Action Items
| # | Action | Owner | Priority | Deadline | Status |
|---|--------|-------|----------|----------|--------|

## Lessons Learned
[Key takeaways for the organization]

## Appendix
- [Link to incident timeline]
- [Link to evidence]
- [Link to communications log]
```
