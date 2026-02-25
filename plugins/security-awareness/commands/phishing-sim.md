# /phishing-sim

> Design a phishing awareness simulation exercise with realistic scenarios, difficulty progression, measurement criteria, and educational follow-up materials.

## Trigger

Use when designing phishing awareness exercises for authorized organizational training. Appropriate for:
- Launching a new security awareness program
- Conducting regular phishing simulation campaigns
- Testing awareness after training delivery
- Measuring improvement over time
- Preparing for compliance audits requiring awareness testing

This is for authorized, educational exercises conducted by the organization's security team or authorized training provider. Never for actual phishing attacks.

## Input

- **Organization context**: Industry, size, typical communication patterns
- **Target audience**: All employees, specific departments, executives, new hires
- **Difficulty level**: Beginner (obvious red flags), Intermediate (subtle but detectable), Advanced (sophisticated, targeted)
- **Current baseline**: Previous simulation results if available (click rate, report rate)
- **Training objectives**: What specific awareness to build (URL inspection, attachment caution, BEC recognition, etc.)
- **Simulation platform** (optional): GoPhish, KnowBe4, Proofpoint, Cofense, or custom

## Process

1. **Scenario design** -- Create realistic phishing scenarios appropriate to the organization:

   **Beginner level** (obvious red flags):
   - Misspelled sender domain
   - Generic greeting ("Dear User")
   - Urgency with poor grammar
   - Suspicious attachment name
   - Obvious URL mismatch on hover

   **Intermediate level** (requires attention):
   - Plausible sender (IT department, HR, known vendor)
   - Professional formatting
   - Contextually relevant topic (password reset, benefits enrollment)
   - Subtle URL differences (homograph attacks, subdomain tricks)
   - No attachment, just a credential harvesting link

   **Advanced level** (spear-phishing):
   - Personalized with recipient's name, role, recent activities
   - Mimics real organizational communication style
   - References real projects, people, or events
   - Legitimate-looking landing page
   - BEC scenario (CFO requesting wire transfer, vendor invoice change)

2. **Landing page design** -- Create educational landing pages that:
   - Immediately explain this was a simulation (no shame, no fear)
   - Show what red flags were present in the email
   - Provide a 30-second training moment
   - Link to full training resources
   - Thank the user for helping improve organizational security

3. **Measurement framework** -- Define metrics:
   - **Click rate**: Percentage who clicked the link (goal: decrease over time)
   - **Report rate**: Percentage who reported to security team (goal: increase over time)
   - **Time to report**: How quickly people report (goal: decrease)
   - **Data entry rate**: Percentage who entered credentials (should be lower than click rate)
   - **Department comparison**: Identify teams needing additional support

4. **Post-simulation education** -- Design follow-up:
   - Results communication (organizational level, never individual shaming)
   - Targeted micro-training for those who clicked
   - Recognition for reporters
   - Tips specific to the attack technique used

## Output

```
## Phishing Simulation Exercise Design

### Campaign Overview
- **Objective**: [awareness goal]
- **Target audience**: [who]
- **Difficulty**: [level]
- **Duration**: [send window]
- **Expected volume**: [number of emails]

### Scenario 1: [Name]
**Theme**: [topic]
**Difficulty**: [1-5]
**Attack type**: [credential harvest / malware / BEC]

**Email content**:
- From: [sender display name <address>]
- Subject: [subject line]
- Body: [email body with red flags annotated]
- Link/Attachment: [what the CTA is]

**Red flags present** (for post-click education):
1. [Red flag with explanation]
2. [Red flag with explanation]
3. [Red flag with explanation]

**Landing page**: [Educational content shown on click]

### Scenario 2: [Name]
[Same structure]

### Measurement Plan
| Metric | Definition | Target | Measurement Method |
|--------|-----------|--------|--------------------|
| Click rate | % who clicked link | < [x]% | Platform analytics |
| Report rate | % who reported to IT | > [x]% | Reporting inbox count |
| Credential entry | % who entered data | < [x]% | Landing page form submissions |

### Communication Plan
- **Pre-campaign**: [What to communicate and to whom]
- **During**: [Monitoring and early termination criteria]
- **Post-campaign**: [Results sharing, training delivery, recognition]

### Follow-Up Training
[Specific training materials for post-exercise education]
```
