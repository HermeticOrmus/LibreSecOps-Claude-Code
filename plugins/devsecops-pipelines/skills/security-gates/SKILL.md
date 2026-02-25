# Security Gates

> Quality gate definitions, threshold configuration, and the decision framework for when to break the build versus when to warn.

## Knowledge Base

### What is a Security Gate

A security gate is a decision point in a CI/CD pipeline where security findings are evaluated against defined thresholds to determine if the build should proceed, warn, or fail. Gates are the enforcement mechanism that turns security scanning from informational noise into actionable workflow.

### Gate Types

**Hard Gate (Block)**: The pipeline fails. The PR cannot be merged, the artifact cannot be deployed. Reserved for findings that represent unacceptable risk.

**Soft Gate (Warn)**: The pipeline succeeds, but findings are surfaced prominently -- in PR comments, dashboard alerts, or Slack notifications. Used for findings that need attention but should not block velocity.

**Log Gate (Track)**: Findings are recorded for metrics and trending but not surfaced to developers in real time. Used for low-severity findings and baseline tracking.

### The Gate Paradox

Too strict: Developers route around security (force-merge, disable checks, move to unprotected branches). Too loose: Vulnerabilities ship to production. The goal is a gate configuration that developers perceive as fair, consistent, and actionable.

## Patterns

### Pattern 1: Severity-Based Gate Matrix

The most common approach. Gate decisions based on finding severity.

```yaml
# gate-config.yml -- conceptual, implemented per-tool
gates:
  sast:
    block:
      - severity: critical
        confidence: high
      - severity: high
        confidence: high
        new_only: true  # Only block on NEW high findings
    warn:
      - severity: high
        confidence: medium
      - severity: medium
    log:
      - severity: low
      - severity: info

  sca:
    block:
      - severity: critical
        fix_available: true    # Only block if there's a fix
      - cisa_kev: true         # Block any actively exploited vuln
    warn:
      - severity: critical
        fix_available: false   # No fix yet -- track closely
      - severity: high
    log:
      - severity: medium
      - severity: low

  secrets:
    block:
      - any: true              # Any secret detection blocks
    exceptions:
      - pattern: "example_*"   # Test/example values allowed
      - path: "test/**"        # Test fixtures may contain fake secrets

  container:
    block:
      - severity: critical
        fix_available: true
    warn:
      - severity: critical
        fix_available: false
      - severity: high
    log:
      - severity: medium
      - severity: low

  iac:
    block:
      - severity: critical     # Public buckets, unencrypted data stores
    warn:
      - severity: high
    log:
      - severity: medium
      - severity: low
```

### Pattern 2: Risk-Based Gating with EPSS

Move beyond raw CVSS severity by incorporating exploit probability.

```yaml
# Risk-based SCA gate using CVSS + EPSS + KEV
sca_risk_gate:
  block:
    # Actively exploited -- fix immediately regardless of CVSS
    - condition: "cisa_kev == true AND fix_available == true"
      reason: "Known exploited vulnerability with available fix"

    # Very likely to be exploited soon -- high urgency
    - condition: "epss >= 0.5 AND cvss >= 7.0 AND fix_available == true"
      reason: "High exploit probability with severe impact"

    # Critical severity with any fix available
    - condition: "cvss >= 9.0 AND fix_available == true"
      reason: "Critical severity with available remediation"

  warn:
    # High exploit probability but no fix yet
    - condition: "epss >= 0.5 AND fix_available == false"
      reason: "High exploit probability, monitoring for fix availability"

    # High severity
    - condition: "cvss >= 7.0 AND cvss < 9.0"
      reason: "High severity, remediation recommended"

  log:
    # Everything else
    - condition: "cvss < 7.0"
```

### Pattern 3: Differential Gating (New vs. Existing)

The most practical approach for onboarding security scanning into an existing project.

```yaml
# Differential gate: strict on new code, lenient on existing
differential_gate:
  new_findings:  # Introduced in this PR/commit
    block:
      - severity: [critical, high]
      - type: secret  # Any new secret
    warn:
      - severity: medium

  existing_findings:  # Present in baseline
    action: track
    dashboard: true
    burndown_target: "10% reduction per quarter"

  # Baseline management
  baseline:
    file: .security-baseline.json
    refresh: weekly       # Re-scan and update baseline weekly
    auto_promote: false   # New findings don't auto-enter baseline
    max_age: 180          # Baseline entries expire after 180 days
```

Implementation in GitHub Actions:

```yaml
- name: SAST with baseline comparison
  run: |
    # Full scan
    semgrep scan --config p/default --sarif --output full-scan.sarif .

    # Compare against baseline
    python scripts/diff-sarif.py \
      --baseline .security-baseline.json \
      --current full-scan.sarif \
      --output new-findings.sarif

    # Gate only on new findings
    NEW_CRITICAL=$(jq '[.runs[].results[] | select(.level=="error")] | length' new-findings.sarif)
    if [ "$NEW_CRITICAL" -gt 0 ]; then
      echo "::error::$NEW_CRITICAL new critical/high findings detected"
      exit 1
    fi
```

### Pattern 4: Application-Tiered Gating

Different applications have different risk profiles. A public-facing payment service needs stricter gates than an internal admin tool.

```yaml
# Application risk tiers
tiers:
  tier1_critical:  # Payment, auth, PII handling
    applies_to: ["payment-service", "auth-service", "user-data-api"]
    sast: { block: [critical, high], warn: [medium] }
    sca: { block: [critical, high], warn: [medium] }
    secrets: { block: all }
    dast: { block: [critical], warn: [high] }
    required_review: security-team

  tier2_standard:  # Business logic, internal APIs
    applies_to: ["inventory-service", "notification-service"]
    sast: { block: [critical], warn: [high] }
    sca: { block: [critical], warn: [high] }
    secrets: { block: all }

  tier3_internal:  # Admin tools, dev utilities
    applies_to: ["admin-dashboard", "dev-tools"]
    sast: { warn: [critical, high] }
    sca: { block: [critical_with_fix], warn: [high] }
    secrets: { block: all }
```

### Pattern 5: Gate Override Process

Every gate needs an escape valve for legitimate exceptions.

```yaml
# Override workflow
override:
  mechanism: "Pull request label + security team approval"
  labels:
    - "security-override:false-positive"   # Requires justification
    - "security-override:risk-accepted"    # Requires risk owner sign-off
    - "security-override:fix-planned"      # Requires linked issue with deadline

  requirements:
    false_positive:
      approvers: [security-team]
      justification: required
      expiry: never  # Added to permanent suppression list

    risk_accepted:
      approvers: [security-team, engineering-director]
      justification: required
      expiry: 90_days  # Must be re-evaluated
      tracking: jira_ticket_required

    fix_planned:
      approvers: [security-team]
      justification: required
      expiry: 30_days  # Must be fixed by deadline
      tracking: jira_ticket_required
```

## Anti-Patterns

- **Binary gates with no override**: If the only option is "fix it now or nothing merges," developers will find ways to disable the scanner entirely. Provide documented override paths.
- **Same gates for all applications**: A prototype and a production payment service should not have the same gate thresholds. Tier your applications by risk.
- **Gating on all DAST findings**: DAST tools produce high false positive rates (30-60%). Gate only on high-confidence critical findings. Everything else should be manual review.
- **No baseline for existing projects**: Adding a scanner to a codebase with 200 existing findings and blocking on all of them is not security -- it is a denial of service on development. Establish a baseline, block on new findings, and burn down the backlog on a schedule.
- **Static thresholds forever**: Gate thresholds should tighten over time as teams build security maturity. Start permissive, tighten quarterly. Schedule regular threshold reviews.
- **Counting findings instead of assessing risk**: "Block if more than 5 findings" is a bad gate. Five informational findings should not block, but one critical should. Gate on severity and risk, not count.

## References

- OWASP DevSecOps Maturity Model: https://owasp.org/www-project-devsecops-maturity-model/
- NIST SP 800-218 SSDF (Secure Software Development Framework): https://csrc.nist.gov/publications/detail/sp/800-218/final
- SARIF 2.1.0 Specification (for programmatic gate evaluation): https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html
- FIRST EPSS Model: https://www.first.org/epss/model
- CVSS v3.1 Specification: https://www.first.org/cvss/v3.1/specification-document
