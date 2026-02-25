# Dependency Risk Assessment

> Methodology for scoring and prioritizing dependency risk across vulnerability history, maintainer health, dependency depth, license compatibility, and provenance.

## Knowledge Base

### Why Risk Scoring Matters

Not all dependency vulnerabilities are equal. A critical CVE in a deeply nested, never-called transitive dependency is lower risk than a medium-severity issue in a direct dependency that processes user input. Risk assessment applies context to raw vulnerability data so teams fix what matters first.

### Risk Dimensions

**1. Vulnerability Exposure**

- Known CVEs (NVD, OSV, GitHub Advisory Database)
- CVSS v3.1 base score (severity of the vulnerability itself)
- EPSS score (probability of exploitation in the next 30 days, based on real-world data)
- CISA KEV status (confirmed active exploitation in the wild)
- Time since disclosure (unpatched for longer = higher risk)
- Patch availability (fix exists but not applied vs. no fix exists)

**2. Reachability**

- Is the vulnerable function/method actually called by your code?
- Is the vulnerable code path reachable through your application's entry points?
- Does your configuration enable the vulnerable feature?
- Static analysis (call graph) vs. dynamic analysis (runtime tracing)

**3. Maintainer Health**

- Last commit date (>12 months without activity = concern)
- Number of active maintainers (bus factor)
- Issue and PR response time
- Whether the maintainer has enabled 2FA (npm audit signatures)
- Maintainer account age and reputation
- History of security response (how quickly past CVEs were patched)

**4. Dependency Depth and Breadth**

- Direct dependency vs. transitive (and how many levels deep)
- Number of downstream dependents (high-value target for attackers)
- Number of own transitive dependencies (larger attack surface)
- Whether the dependency is a build-time-only or runtime dependency

**5. License Risk**

- Copyleft licenses (GPL, AGPL) in proprietary codebases
- License incompatibility between dependencies
- Missing or ambiguous license declarations
- "UNLICENSED" or custom license terms requiring legal review

**6. Provenance and Integrity**

- Sigstore signatures or npm provenance attestations
- Reproducible builds (can the published artifact be rebuilt from source?)
- Build process transparency (SLSA level)
- Registry-level protections (two-factor publish, trusted publishers)

### Composite Risk Score Formula

```
Risk Score = (Vuln_Score * 0.35) + (Reachability * 0.25) + (Maintainer_Risk * 0.15)
           + (Depth_Risk * 0.10) + (License_Risk * 0.05) + (Provenance_Risk * 0.10)

Each dimension scored 0-10:
  0-3: Low risk
  4-6: Medium risk
  7-8: High risk
  9-10: Critical risk
```

## Patterns

### Pattern 1: Triage Decision Matrix

| CVSS | EPSS > 10% | CISA KEV | Reachable | Action |
|------|-----------|----------|-----------|--------|
| Critical (9.0+) | Yes | Yes | Yes | Fix immediately. Drop everything. |
| Critical (9.0+) | Yes | Yes | No | Fix within 24 hours. May become reachable. |
| Critical (9.0+) | No | No | Yes | Fix within 1 week. |
| Critical (9.0+) | No | No | No | Fix within 30 days. |
| High (7.0-8.9) | Yes | Yes | Yes | Fix within 48 hours. |
| High (7.0-8.9) | No | No | Yes | Fix within 2 weeks. |
| High (7.0-8.9) | No | No | No | Fix within 60 days. |
| Medium (4.0-6.9) | Any | No | Any | Fix within 90 days or next release. |
| Low (0.1-3.9) | Any | No | Any | Track. Fix opportunistically. |

### Pattern 2: New Dependency Evaluation Checklist

Before adding any new dependency, evaluate:

```markdown
## Dependency Evaluation: [package-name]

### Purpose
- [ ] What problem does this solve?
- [ ] Can this be solved with existing dependencies or stdlib?
- [ ] Is the problem significant enough to justify a new dependency?

### Trust Assessment
- [ ] Maintainer(s) identified and reputable
- [ ] >1000 weekly downloads (not brand new / unknown)
- [ ] Active maintenance (commits within last 6 months)
- [ ] No unresolved security advisories
- [ ] License compatible with project

### Technical Assessment
- [ ] Transitive dependency count acceptable (<20 for utility libraries)
- [ ] No native binaries or install scripts (or they are justified)
- [ ] TypeScript types available (if TS project)
- [ ] Tests exist in the repository
- [ ] No known typosquatting concerns

### Decision: [ADOPT / DEFER / REJECT]
```

### Pattern 3: Automated Risk Monitoring

```yaml
# .github/workflows/dependency-risk.yml
name: Dependency Risk Monitor
on:
  schedule:
    - cron: '0 6 * * 1'  # Weekly Monday 6am UTC
  pull_request:
    paths:
      - '**/package-lock.json'
      - '**/yarn.lock'
      - '**/Cargo.lock'
      - '**/go.sum'
      - '**/requirements*.txt'
      - '**/poetry.lock'

jobs:
  risk-assessment:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run osv-scanner
        uses: google/osv-scanner-action/osv-scanner-action@v1
        with:
          scan-args: |-
            --lockfile=./package-lock.json
            --format=json
            --output=osv-results.json
      - name: Run scorecard on critical dependencies
        uses: ossf/scorecard-action@v2
        with:
          results_file: scorecard-results.sarif
          publish_results: true
```

### Pattern 4: Dependency Pinning Strategy

```
# GOOD: Pin exact versions in lockfiles (automatic with lockfiles)
# package-lock.json, yarn.lock, Cargo.lock -- always commit these

# GOOD: Pin ranges in manifests to allow controlled updates
"dependencies": {
  "express": "^4.18.2",      // Minor + patch updates OK
  "jsonwebtoken": "~9.0.0"   // Patch updates only for security-sensitive
}

# BAD: Unpinned or wildcard versions
"dependencies": {
  "some-lib": "*",            // Any version -- never do this
  "other-lib": "latest"       // Same problem
}
```

## Anti-Patterns

- **Treating all CVEs as equal priority**: A critical CVE in an unreachable code path is lower priority than a high CVE in your authentication flow. Context matters more than raw scores.
- **Ignoring EPSS data**: CVSS tells you how bad a vulnerability could be. EPSS tells you how likely it is to be exploited. A CVSS 7.5 with 90% EPSS is more urgent than a CVSS 9.8 with 0.1% EPSS.
- **Bulk-updating everything at once**: Mass dependency updates are high-risk. Update one dependency at a time, test, and verify. Automated tools like Dependabot and Renovate help manage this.
- **No dependency review process**: Adding dependencies should require the same review rigor as adding code. Every dependency is code you did not write and cannot fully control.
- **Confusing vulnerability presence with exploitability**: The presence of a CVE in your dependency tree does not mean your application is exploitable. Reachability analysis separates real risk from noise.

## References

- EPSS (Exploit Prediction Scoring System): https://www.first.org/epss/
- CISA Known Exploited Vulnerabilities Catalog: https://www.cisa.gov/known-exploited-vulnerabilities-catalog
- OpenSSF Scorecard: https://securityscorecards.dev/
- SLSA Framework: https://slsa.dev/
- OSV (Open Source Vulnerabilities): https://osv.dev/
- deps.dev (Google Open Source Insights): https://deps.dev/
- NIST SP 800-161r1 (Supply Chain Risk Management): https://csrc.nist.gov/publications/detail/sp/800-161/rev-1/final
