# /awareness-plan

> Design a complete security awareness training program with phased implementation, role-based content, simulation calendar, and measurable outcomes.

## Trigger

Use when building or overhauling a security awareness program. Appropriate for:
- Establishing a new awareness program from scratch
- Restructuring an existing compliance-focused program into a behavior-change program
- Scaling an informal awareness effort into a structured program
- Responding to a regulatory requirement for awareness training
- Post-incident program redesign after a social engineering breach

## Input

- **Organization**: Industry, size, geographic distribution, culture description
- **Current state**: Existing awareness activities, training history, simulation results
- **Budget**: Available budget for tools, content, and personnel
- **Goals**: What the program should achieve (compliance, behavior change, culture change)
- **Regulatory requirements**: Specific training requirements (HIPAA, PCI-DSS, SOC 2, etc.)
- **Risk profile**: Top social engineering threats facing the organization
- **Constraints**: Timeline, technology limitations, language requirements, workforce characteristics
- **Champions**: Executive sponsor, security team size, department contacts

## Process

1. **Maturity assessment** -- Evaluate current state using the SANS Security Awareness Maturity Model:
   - Level 1: Nonexistent (no program)
   - Level 2: Compliance-focused (annual training, checkbox)
   - Level 3: Promoting awareness and behavior change (engaging, measurable)
   - Level 4: Long-term sustainment and culture change (integrated, continuous)
   - Level 5: Metrics framework (robust measurement, continuous improvement)

2. **Audience segmentation** -- Define training tracks based on role and risk:
   - All employees: Baseline security awareness
   - Executives: BEC, whaling, strategic threats, data protection responsibility
   - Finance/accounting: Wire fraud, invoice fraud, payment redirect
   - IT/engineering: Supply chain attacks, credential management, secure development
   - HR: Data protection, social engineering targeting new hires
   - Customer-facing staff: Social engineering via customers, phone scams
   - New hires: Onboarding security module

3. **Content planning** -- Design training modules by topic:
   - Phishing recognition and reporting
   - Password/credential security and MFA
   - Social engineering (phone, in-person, social media)
   - Physical security awareness
   - Data handling and classification
   - Remote work security
   - Incident reporting procedures
   - Industry-specific topics (HIPAA, PCI, financial regulations)

4. **Simulation calendar** -- Plan phishing simulations with progressive difficulty:
   - Month 1: Baseline measurement (medium difficulty)
   - Months 2-3: Low difficulty (obvious red flags, educational purpose)
   - Months 4-6: Medium difficulty (plausible pretexts, some personalization)
   - Months 7-9: Medium-high difficulty (organization-specific scenarios)
   - Months 10-12: High difficulty (targeted, multi-vector)

5. **Communication plan** -- Design ongoing security communications:
   - Monthly security newsletters (real incident summaries, tips)
   - Weekly micro-tips (30-second security reminders)
   - Incident-triggered communications (when relevant threats emerge)
   - Recognition communications (celebrating reporting behavior)

6. **Metrics framework** -- Define KPIs and measurement approach:
   - Primary: Reporting rate (% of simulation recipients who report)
   - Secondary: Click rate (% who clicked, trending down)
   - Tertiary: Time-to-report (decreasing over time)
   - Outcome: Real phishing incident reduction
   - Engagement: Training completion rates, quiz scores

## Output

```
## Security Awareness Program Plan

### Program Overview
- **Organization**: [name]
- **Current maturity**: [SANS level]
- **Target maturity**: [SANS level by when]
- **Executive sponsor**: [role]
- **Program owner**: [role]

### Audience Segments
| Segment | Size | Key Threats | Training Track |
|---------|------|------------|---------------|
| All employees | [n] | [threats] | Baseline |
| Executives | [n] | [threats] | Executive |
| Finance | [n] | [threats] | Financial fraud |
| IT/Engineering | [n] | [threats] | Technical |
| [custom] | [n] | [threats] | [track] |

### Implementation Phases

#### Phase 1: Foundation (Months 1-3)
**Objective**: Establish baseline and deploy core infrastructure
- [ ] Deploy phishing report button in email client
- [ ] Run baseline phishing simulation (measure without prior training)
- [ ] Deploy baseline security awareness training (all employees)
- [ ] Establish security awareness communications channel
- [ ] Launch security champion nomination process
- **Milestone**: Baseline metrics established

#### Phase 2: Behavior Change (Months 4-9)
**Objective**: Drive measurable behavior improvement
- [ ] Roll out role-based training tracks
- [ ] Run monthly phishing simulations with progressive difficulty
- [ ] Launch monthly security newsletter
- [ ] Activate security champion network
- [ ] Introduce recognition program for reporting behavior
- **Milestone**: Report rate > [target]%, click rate < [target]%

#### Phase 3: Culture Integration (Months 10-12+)
**Objective**: Embed security awareness into organizational culture
- [ ] Integrate security awareness into onboarding process
- [ ] Launch advanced simulation scenarios (multi-vector)
- [ ] Implement department-level security scorecard
- [ ] Conduct annual program assessment and refresh
- **Milestone**: Sustained metrics improvement, security champion coverage

### Training Module Catalog
| Module | Audience | Format | Duration | Delivery |
|--------|----------|--------|----------|----------|
| Phishing Fundamentals | All | Interactive | 15 min | Quarterly |
| BEC & Wire Fraud | Finance, Exec | Scenario-based | 20 min | Quarterly |
| Credential Security | All | Video + quiz | 10 min | Semi-annual |
| Physical Security | All (on-site) | Interactive | 10 min | Annual |
| Secure Remote Work | Remote staff | Interactive | 15 min | Semi-annual |
| Incident Reporting | All | Quick guide | 5 min | On hire + annual |

### Phishing Simulation Calendar
| Month | Difficulty | Theme | Red Flags | Learning Goal |
|-------|-----------|-------|-----------|--------------|
| 1 | Baseline | [theme] | [flags] | Measurement |
| 2 | 2/5 | [theme] | [flags] | [goal] |
| 3 | 2/5 | [theme] | [flags] | [goal] |
| 4 | 3/5 | [theme] | [flags] | [goal] |
| ... | ... | ... | ... | ... |
| 12 | 4/5 | [theme] | [flags] | [goal] |

### Metrics Dashboard
| KPI | Baseline | Q1 Target | Q2 Target | Q3 Target | Q4 Target |
|-----|----------|-----------|-----------|-----------|-----------|
| Report rate | [%] | [%] | [%] | [%] | [%] |
| Click rate | [%] | [%] | [%] | [%] | [%] |
| Time to report | [hrs] | [hrs] | [hrs] | [hrs] | [hrs] |
| Training completion | [%] | 90% | 95% | 95% | 95% |

### Budget
| Item | Annual Cost | Category |
|------|------------|----------|
| Simulation platform | [cost] | Tooling |
| Training content | [cost] | Content |
| Communication materials | [cost] | Content |
| Program management | [cost] | Personnel |
| **Total** | **[total]** | |

### Risk and Contingency
- [Risk 1]: [mitigation]
- [Risk 2]: [mitigation]
```
