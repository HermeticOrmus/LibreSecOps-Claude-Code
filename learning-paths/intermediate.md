# Intermediate — DevSecOps + IR

## DevSecOps integration

Shift security left:

1. **SAST** (Static Application Security Testing) in CI — Semgrep, Snyk Code, CodeQL
2. **SCA** (Software Composition Analysis) — Dependabot, Snyk, Renovate
3. **DAST** (Dynamic) — OWASP ZAP, Burp Suite Pro
4. **Secret scanning** — gitleaks, GitHub secret scanning
5. **IaC scanning** — Checkov, tfsec, Terrascan
6. **Container scanning** — Trivy, Grype, Snyk Container
7. **Policy as code** — OPA, Conftest

Integrate into every pipeline. Fail the build on critical findings. Track findings to remediation.

## Incident response basics

When something happens:

1. **Detect** — alert fires; on-call paged
2. **Triage** — is this real? severity?
3. **Contain** — stop the bleeding (isolate, revoke, block)
4. **Eradicate** — remove the cause (patch, kill, remove)
5. **Recover** — restore service safely
6. **Lessons learned** — postmortem, prevention design

Have playbooks for top scenarios. Tabletop quarterly.

## Cloud security posture

For each cloud provider you use:

- IAM audit (over-permissive roles, unused credentials)
- Public exposure check (S3 buckets, security groups, public IPs)
- Logging enabled (CloudTrail, Activity Logs, Cloud Audit Logs)
- Encryption everywhere (at rest, in transit, key management)
- Network segmentation (VPCs, security groups, network policies)

Use cloud-native posture tools (AWS Security Hub, Azure Defender, GCP Security Command Center) or 3rd-party CSPM (Wiz, Lacework, Prisma).

## Next: [Advanced](advanced.md)
