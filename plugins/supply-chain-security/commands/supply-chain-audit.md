# /supply-chain-audit

> Audit a project's dependencies for known vulnerabilities, license risks, integrity issues, and supply chain health.

## Trigger

Use when you need to assess the security posture of a project's dependency tree. Appropriate for:

- Pre-release security review
- Onboarding to a new codebase
- Periodic dependency hygiene checks
- Compliance requirements (EO 14028, NIS2, FDA cybersecurity)
- After a public supply chain incident to check exposure

## Input

The command operates on the current project directory. It needs:

- **Required**: At least one package manager lockfile or manifest (package-lock.json, yarn.lock, pnpm-lock.yaml, Cargo.lock, go.sum, requirements.txt, poetry.lock, Gemfile.lock, composer.lock, pom.xml, build.gradle)
- **Optional flag**: `--sbom` -- generate a full SBOM in addition to the audit report
- **Optional flag**: `--format [spdx|cyclonedx]` -- SBOM output format (default: CycloneDX 1.5)
- **Optional flag**: `--deep` -- include maintainer health analysis and typosquatting checks (slower, more thorough)

## Process

1. **Ecosystem Detection**: Scan the project root and subdirectories for package manager lockfiles and manifests. Identify all ecosystems in use (monorepos often use multiple).

2. **Dependency Tree Mapping**: Parse lockfiles to build the complete dependency tree including all transitive dependencies. Count direct vs. transitive. Identify maximum depth.

3. **Vulnerability Scan**: Cross-reference every dependency and version against:
   - National Vulnerability Database (NVD)
   - OSV (Open Source Vulnerabilities)
   - GitHub Advisory Database
   - CISA Known Exploited Vulnerabilities catalog

4. **Severity Prioritization**: For each finding, assess:
   - CVSS v3.1 base score
   - EPSS (Exploit Prediction Scoring System) probability
   - CISA KEV status (actively exploited in the wild)
   - Whether the vulnerable code path is reachable from the project

5. **License Analysis**: Check each dependency's declared license against:
   - SPDX license identifier validity
   - Copyleft vs. permissive classification
   - License compatibility with the project's own license
   - Missing or ambiguous license declarations

6. **Integrity Checks** (with `--deep`):
   - Check for known typosquatting patterns
   - Verify provenance attestations where available
   - Flag packages with suspicious install scripts
   - Assess maintainer activity and bus factor

7. **SBOM Generation** (with `--sbom`):
   - Generate machine-readable SBOM in the specified format
   - Include all required fields per the standard
   - Embed vulnerability information as VEX (Vulnerability Exploitability eXchange) where applicable

8. **Report Generation**: Compile all findings into a prioritized, actionable report.

## Output

```
# Supply Chain Audit Report
Generated: [timestamp]
Project: [name from manifest]

## Summary
| Metric | Count |
|--------|-------|
| Direct dependencies | X |
| Transitive dependencies | X |
| Total unique packages | X |
| Critical vulnerabilities | X |
| High vulnerabilities | X |
| Medium vulnerabilities | X |
| Low vulnerabilities | X |
| License issues | X |
| Integrity concerns | X |

## Critical & High Findings

### [CVE-XXXX-XXXXX] [Package name]@[version]
- **Severity**: Critical (CVSS 9.8)
- **EPSS**: 87.3% probability of exploitation in next 30 days
- **CISA KEV**: Yes -- actively exploited
- **Introduced via**: [direct dependency] -> [transitive chain]
- **Reachable**: Yes -- called from src/api/handler.ts:42
- **Description**: [brief vulnerability description]
- **Fix**: Upgrade [package] to >= [fixed version]
- **Workaround**: [if no fix available]

[...additional findings...]

## License Summary
| License | Count | Risk |
|---------|-------|------|
| MIT | X | None |
| Apache-2.0 | X | None |
| GPL-3.0 | X | Copyleft -- review required |
| UNLICENSED | X | Unknown -- investigate |

## Dependency Health (--deep only)
[Unmaintained packages, single-maintainer risks, archived repositories]

## Recommendations
1. [Highest priority action]
2. [Second priority action]
3. [...]

## SBOM Location (--sbom only)
Output: ./sbom.[spdx.json|cdx.json]
```
