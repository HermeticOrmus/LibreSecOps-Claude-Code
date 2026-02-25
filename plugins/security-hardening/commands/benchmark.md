# /benchmark

> Assess configuration against CIS Benchmark requirements and produce a compliance report.

## Trigger

Use this command when:
- Conducting a CIS Benchmark compliance assessment
- Preparing for a security audit that references CIS controls
- Validating that hardening changes were applied correctly
- Establishing a baseline compliance score for a system
- Monitoring configuration drift from hardened state

## Input

Required:
- **Target**: Platform to assess (e.g., `ubuntu-22.04`, `docker`, `kubernetes`, `aws`, `nginx`)

Optional:
- **Profile**: `level-1` or `level-2` (defaults to `level-1`)
- **Configuration**: Path to configuration files for static analysis
- **Previous assessment**: Path to previous report for delta comparison
- **Sections**: Specific benchmark sections to assess (comma-separated)

## Process

### Step 1: Benchmark Selection

1. Match target platform to the correct CIS Benchmark document and version
2. Apply the selected profile level (Level 1 or Level 2)
3. Filter to specified sections if provided

### Step 2: Control Assessment

For each applicable control in the benchmark:

1. **Read the requirement**: What the CIS Benchmark specifies
2. **Check current state**: Examine configuration files, system settings, or cloud configuration
3. **Assess compliance**: PASS (meets requirement), FAIL (does not meet), N/A (not applicable to this environment)
4. **Document evidence**: The specific configuration value or command output that supports the assessment
5. **Provide remediation**: For FAIL findings, specific steps to achieve compliance

### Step 3: Scoring

Calculate compliance percentage:
- Only scored controls count toward the percentage
- Not Applicable controls are excluded from the total
- Compliance % = Passed / (Passed + Failed) * 100

### Step 4: Gap Analysis

For failed controls:
1. Group by severity (critical gaps vs minor gaps)
2. Estimate remediation effort for each
3. Identify dependencies between controls
4. Produce a prioritized remediation plan

### Step 5: Report Generation

Compile the full assessment report with summary, detailed findings, and remediation plan.

## Output

```
# CIS Benchmark Assessment

**Target**: [platform]
**Benchmark**: [CIS benchmark name and version]
**Profile**: Level [1|2]
**Date**: [assessment date]

## Compliance Summary
- **Score**: [X]% ([passed]/[total scored])
- Passed: [n]
- Failed: [n]
- Not Applicable: [n]
- Exceptions: [n]

## Compliance by Section
| Section | Controls | Pass | Fail | N/A | Score |
|---------|----------|------|------|-----|-------|

## Critical Gaps (Immediate Action Required)
[Failed controls with high security impact]

## Remediation Plan
| Priority | Control | Current | Required | Effort | Impact |
|----------|---------|---------|----------|--------|--------|

## Detailed Assessment
[Full control-by-control assessment with evidence]

## Comparison with Previous Assessment (if applicable)
| Metric | Previous | Current | Change |
|--------|----------|---------|--------|
```
