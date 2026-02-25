# /security-automate

> Automate a specific security workflow by analyzing the manual process and designing an automated equivalent with implementation code.

## Trigger

Use when you need to:

- Automate a repetitive security operations task
- Build an automated response playbook for a specific alert type
- Create enrichment automation for SOC analysts
- Design containment automation with appropriate approval gates
- Reduce mean time to respond (MTTR) for a specific incident type

## Input

- **Required**: Description of the security workflow to automate. Examples:
  - "Automate phishing email triage and response"
  - "Auto-enrich all SIEM alerts with IOC reputation data"
  - "Automate account lockout investigation and response"
  - "Build automated containment for ransomware alerts"
- **Optional**: Current tools in use (SIEM, EDR, email security, IAM, ticketing)
- **Optional flag**: `--platform [shuffle|tines|xsoar|python]` -- target automation platform
- **Optional flag**: `--risk [low|medium|high]` -- automation risk appetite (affects approval gates)

## Process

1. **Workflow Analysis**: Break down the manual workflow into discrete steps:
   - What triggers this workflow? (Alert, schedule, manual request)
   - What data is needed? (IOCs, user info, asset info, alert context)
   - What tools are involved? (SIEM query, EDR action, email gateway, IAM)
   - What decisions are made? (Is this malicious? What severity? What action?)
   - What actions are taken? (Quarantine, block, disable, escalate, close)
   - What is the output? (Ticket, notification, report)

2. **Automation Assessment**: For each step, determine:
   - Can this step be fully automated? (API available, deterministic decision)
   - Should this step be automated? (Risk of automated action vs. speed benefit)
   - Does this step need human approval? (High-impact, irreversible actions)

3. **Playbook Design**: Structure the automated workflow:
   - Trigger mechanism (webhook, polling, schedule)
   - Data enrichment steps (parallel where possible)
   - Decision logic (severity calculation, triage rules)
   - Automated actions (with rollback capability)
   - Human approval gates (for high-impact actions)
   - Notification and documentation steps
   - Error handling and failure paths

4. **Implementation**: Produce the playbook code or configuration:
   - Platform-specific playbook definition
   - Integration code for each tool
   - Configuration files and environment variables
   - Test cases

5. **Deployment Plan**: How to safely deploy the automation:
   - Shadow mode first (run automation but do not take action, compare to manual)
   - Limited scope (start with low-severity alerts, expand gradually)
   - Monitoring and alerting for automation failures
   - Rollback procedure

## Output

```
# Security Automation: [Workflow Name]

## Workflow Analysis
### Manual Process (Current State)
| Step | Action | Tool | Time | Automatable |
|------|--------|------|------|-------------|
| 1 | [action] | [tool] | [min] | Yes/No/Partial |
| 2 | [action] | [tool] | [min] | Yes/No/Partial |

### Manual time per execution: [X minutes]
### Estimated automated time: [Y minutes]
### Time savings: [X-Y minutes per execution]
### Monthly volume: [Z executions]
### Monthly time savings: [total hours]

## Playbook Design
[Visual workflow with decision points and approval gates]

## Implementation
[Complete playbook code / configuration]

## Integration Requirements
| Tool | API | Authentication | Actions Used |
|------|-----|---------------|-------------|
| [tool] | [API endpoint] | [auth method] | [list] |

## Test Plan
- Unit tests: [test cases]
- Integration tests: [scenarios]
- Shadow mode validation: [criteria for promotion to active]

## Deployment
1. Deploy in shadow mode (log-only, no actions)
2. Validate against [N] manual executions
3. Enable for low-severity alerts
4. Monitor for [2 weeks]
5. Expand to all severities
6. Enable containment actions (with approval gate)

## Monitoring
- Playbook execution success rate
- Average execution time
- False positive rate of automated decisions
- Human override frequency
```
