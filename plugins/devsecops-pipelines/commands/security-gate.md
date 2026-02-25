# /security-gate

> Define or modify quality gates that determine whether a build passes or fails based on security findings.

## Trigger

Use when you need to:

- Define security gates for a new pipeline
- Adjust existing gate thresholds (too strict causing friction, or too loose letting vulns through)
- Add a gate for a specific scanner or finding type
- Implement differential gating (stricter for new code, lenient for existing)

## Input

- **Required**: The CI/CD configuration file to modify or the pipeline platform being used
- **Optional**: `--scanner [sast|sca|dast|container|iac|secrets]` -- configure gate for specific scanner
- **Optional**: `--strategy [strict|balanced|permissive]` -- preset threshold strategy
- **Optional**: `--baseline` -- establish a baseline of existing findings to suppress

## Process

1. **Current Gate Analysis**: Review existing pipeline configuration for any quality gate definitions. Identify what thresholds are set, what scanners are gated, and what is warn-only.

2. **Strategy Selection**: Based on the requested strategy or interactive assessment:

   **Strict** (new projects, security-critical applications):
   - Block on any Critical or High finding
   - Warn on Medium
   - Log Low and Informational
   - Zero tolerance for new secrets in code

   **Balanced** (established projects, general applications):
   - Block on Critical findings
   - Block on High findings with EPSS > 10%
   - Warn on other High and Medium
   - Log Low
   - Block on new secrets only (baseline suppression for existing)

   **Permissive** (legacy codebases being onboarded, initial adoption):
   - Block on Critical findings with known exploits (CISA KEV)
   - Warn on Critical and High
   - Log everything else
   - Block on new secrets only

3. **Differential Gating Configuration**: Configure the pipeline to distinguish between:
   - New findings (introduced in this PR/commit) -- stricter gates
   - Existing findings (baseline) -- tracked but not blocking
   - Suppressions (reviewed and accepted) -- excluded from gates

4. **Scanner-Specific Thresholds**: Configure appropriate thresholds for each scanner type:
   - **SAST**: Severity + confidence level (high confidence Critical/High = block)
   - **SCA**: CVSS + EPSS + fix availability (fixable Critical = block)
   - **Secrets**: Any new secret detected = block (no threshold)
   - **Container**: Critical CVEs in base image with available update = block
   - **DAST**: High-confidence findings only (DAST has high false positive rates)
   - **IaC**: Critical misconfigurations (public S3, no encryption) = block

5. **Implementation**: Generate the gate configuration in the pipeline syntax:
   - Exit codes and conditional steps
   - SARIF severity filtering
   - Threshold configuration files for each tool
   - Suppression/allowlist files

6. **Feedback Configuration**: Ensure gate failures produce actionable output:
   - Which findings caused the failure
   - Severity and description for each
   - Remediation guidance
   - How to suppress false positives (with justification requirement)

## Output

```
# Security Gate Configuration

## Strategy: [strict/balanced/permissive]

## Gate Definitions

| Scanner | Block On | Warn On | Log Only |
|---------|----------|---------|----------|
| SAST | Critical + High (new) | Medium (new) | Low, Existing |
| SCA | Critical (fixable) | High, Critical (no fix) | Medium, Low |
| Secrets | Any new detection | -- | -- |
| Container | Critical (updatable) | High | Medium, Low |
| IaC | Critical misconfig | High misconfig | Medium, Low |
| DAST | Critical (high confidence) | High | Everything else |

## Differential Gating
- New findings: [thresholds above]
- Baseline: [count] existing findings tracked, not blocking
- Suppressions: [count] reviewed and accepted (require justification)

## Configuration Files Generated
- [tool-specific threshold configs]
- [baseline/suppression files]
- [pipeline gate step configuration]

## Override Process
To suppress a finding:
1. Add to [suppression file] with justification
2. Requires review approval from security team or tech lead
3. Suppression expires after [90 days] and must be re-justified
```
