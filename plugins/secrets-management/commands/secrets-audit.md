# /secrets-audit

> Scan a project for hardcoded secrets, exposed credentials, and secret management anti-patterns.

## Trigger

Use when you need to find leaked secrets in a codebase. Appropriate for:

- Security review of a new or acquired codebase
- Pre-deployment security check
- After a suspected credential leak
- Periodic hygiene scan
- Onboarding to a project to understand its secret handling

## Input

The command operates on the current project directory. It examines:

- **Source code**: All tracked and untracked files in the repository
- **Git history**: Full commit history for secrets that were added then removed
- **Configuration files**: .env, .env.*, config files, YAML, JSON, TOML, properties files
- **CI/CD configurations**: .github/workflows/*, .gitlab-ci.yml, Jenkinsfile, docker-compose.yml
- **Container files**: Dockerfile, docker-compose.yml (secrets in build args or environment)
- **Documentation**: README, docs (sometimes contain example credentials that are real)

Optional flags:
- `--history` -- include full git history scan (slower, more thorough)
- `--verify` -- attempt to verify if detected secrets are still valid (requires network access)
- `--fix` -- generate .gitignore updates and pre-commit hook configuration

## Process

1. **Repository Analysis**: Identify the tech stack, frameworks, and cloud providers in use. This determines which secret patterns to prioritize (AWS keys for AWS projects, database strings for backend services, etc.).

2. **Current Tree Scan**: Scan all files in the current working tree for secret patterns:
   - Known credential formats (AWS keys, GCP service accounts, GitHub tokens, etc.)
   - Generic high-entropy strings in security-sensitive contexts (variable names containing `secret`, `password`, `token`, `key`, `credential`)
   - Hardcoded connection strings with embedded credentials
   - Private keys (RSA, EC, Ed25519) in source code or configuration

3. **Git History Scan** (with `--history`): Scan the full git history for:
   - Secrets that were committed and then removed (still in history)
   - Secrets in deleted branches (if reachable)
   - Large binary blobs that might contain credential stores

4. **Anti-Pattern Detection**: Check for common secret management anti-patterns:
   - `.env` files committed to the repository
   - Secrets in CI/CD pipeline YAML without using the platform's secret management
   - Docker build args passing secrets (visible in image history)
   - Secrets in docker-compose.yml `environment` section (not using docker secrets)
   - Configuration files with production credentials alongside development settings

5. **Verification** (with `--verify`): For detected secrets that match known API formats, attempt to verify if the credential is still active. Report verification status.

6. **Severity Classification**:
   - **Critical**: Verified live credentials
   - **High**: Credentials matching known patterns, unverified but likely valid
   - **Medium**: Generic high-entropy strings in sensitive contexts
   - **Low**: Possibly expired or test credentials
   - **Info**: Anti-patterns and configuration issues

7. **Remediation Generation**: For each finding, provide specific remediation steps including revocation instructions, rotation procedures, and preventive measures.

## Output

```
# Secrets Audit Report
Generated: [timestamp]
Project: [name]

## Summary
| Severity | Count |
|----------|-------|
| Critical (verified live) | X |
| High (likely valid) | X |
| Medium (possible) | X |
| Low (test/expired) | X |
| Info (anti-patterns) | X |

## Critical Findings
[Details with masked secrets, file locations, commit SHAs, remediation]

## High Findings
[Details with masked secrets, file locations, remediation]

## Anti-Patterns Detected
- [ ] .env file committed to repository
- [ ] Secrets in CI/CD YAML without platform secrets
- [ ] Docker build args with credentials
- [ ] No pre-commit secret scanning configured
- [ ] No .gitignore entries for secret files

## Remediation Plan
1. [Immediate: Revoke live credentials]
2. [Short-term: Rotate all potentially exposed credentials]
3. [Medium-term: Implement vault for secret storage]
4. [Long-term: Configure pre-commit hooks and CI scanning]

## Prevention Recommendations
- Pre-commit hook: [gitleaks configuration]
- CI/CD scanning: [pipeline integration]
- .gitignore additions: [entries to add]
```
