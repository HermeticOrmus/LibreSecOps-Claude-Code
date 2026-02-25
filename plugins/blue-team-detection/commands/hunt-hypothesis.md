# /hunt-hypothesis

> Generate a structured threat hunting hypothesis with data sources, analysis approach, and expected indicators.

## Trigger

Use when you need to:

- Start a threat hunt and need a structured hypothesis
- Investigate a specific ATT&CK technique proactively
- Follow up on threat intelligence with a targeted hunt
- Explore a detection gap identified during a red team exercise
- Conduct a periodic hunt against common adversary behaviors

## Input

- **Required**: One of the following:
  - ATT&CK tactic or technique (e.g., `credential-access`, `T1003.001`)
  - Threat intelligence indicator or report to investigate
  - Detection gap description (e.g., "we have no detection for DNS tunneling")
  - Broad category (e.g., "lateral-movement", "persistence", "exfiltration")
- **Optional**: Available data sources (SIEM platform, log types collected, EDR product)
- **Optional flag**: `--queries` -- include ready-to-run SIEM queries
- **Optional flag**: `--playbook` -- generate a full hunt playbook with step-by-step instructions

## Process

1. **Hypothesis Formulation**: Construct a testable hypothesis:
   - Based on the input, what specific adversary behavior are we looking for?
   - What would evidence of this behavior look like in our telemetry?
   - What is the null hypothesis (expected benign baseline)?

2. **Scope Definition**: Define the hunt boundaries:
   - Time window (last 7 days, 30 days, 90 days)
   - Systems in scope (all endpoints, servers only, specific segments)
   - Data sources to query

3. **Data Source Mapping**: Identify the specific data sources needed:
   - Which log types contain the relevant telemetry?
   - What fields are we analyzing?
   - Are there data gaps that limit the hunt?

4. **Analysis Approach**: Design the analytical methodology:
   - **Statistical**: Frequency analysis, baseline deviation, rare value identification
   - **Pattern matching**: Known indicators, behavioral signatures
   - **Temporal**: Time-series analysis, beaconing detection, periodicity analysis
   - **Relational**: Process tree analysis, network graph analysis, user-entity mapping

5. **Query Development**: Build the specific queries for the available SIEM platform:
   - Initial broad query to establish baseline
   - Refinement queries to narrow to suspicious activity
   - Contextual queries to investigate specific findings

6. **Expected Indicators**: Document what a true positive and false positive look like for this hunt.

7. **Documentation Template**: Provide the hunt documentation structure for recording findings.

## Output

```
# Threat Hunt Hypothesis

## Hypothesis
"If [adversary behavior] is occurring in our environment, we would expect to see
[specific indicators] in [data source] within [time window]."

## ATT&CK Mapping
- Tactic: [tactic name]
- Technique: [ID - Name]
- Sub-technique: [ID - Name] (if applicable)

## Scope
- Time window: [range]
- Systems: [scope definition]
- Data sources: [list]

## Required Telemetry
| Data Source | Field | Purpose |
|-------------|-------|---------|
| [source] | [field name] | [what it tells us] |

## Analysis Approach

### Step 1: Baseline Establishment
Query: [baseline query]
Expected: [normal behavior description]

### Step 2: Anomaly Identification
Query: [anomaly detection query]
Look for: [specific indicators]

### Step 3: Investigation
Query: [deep-dive query for suspicious findings]
Context: [what additional information to gather]

## Indicators of Compromise
### True Positive Indicators
- [Indicator 1]
- [Indicator 2]

### False Positive Indicators (Benign)
- [Indicator 1]
- [Indicator 2]

## Decision Tree
- Finding matches hypothesis --> Escalate to IR, create detection rule
- Finding is benign --> Document, add to known-good baseline
- No finding --> Document null result, identify telemetry gaps
- Inconclusive --> Expand scope or adjust hypothesis

## Documentation Template
[Pre-filled template for recording hunt results]
```
