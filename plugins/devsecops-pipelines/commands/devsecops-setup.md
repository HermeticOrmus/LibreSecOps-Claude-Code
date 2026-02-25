# /devsecops-setup

> Configure security scanning in an existing CI/CD pipeline, detecting the platform and adding appropriate security stages.

## Trigger

Use when you need to add security scanning to an existing project's CI/CD pipeline, or when bootstrapping a new project with security-integrated CI/CD from day one. Appropriate for:

- Adding security to an existing pipeline that has none
- Auditing and improving an existing security pipeline
- Setting up CI/CD for a new project with security built in
- Migrating security scanning between CI/CD platforms

## Input

The command operates on the current project directory. It detects:

- **CI/CD platform**: .github/workflows/*.yml (GitHub Actions), .gitlab-ci.yml (GitLab CI), Jenkinsfile (Jenkins), .circleci/config.yml (CircleCI)
- **Project type**: Language, framework, and package manager from manifest files
- **Existing security scanning**: What is already configured
- **Optional flag**: `--platform [github|gitlab|jenkins]` -- force a specific platform
- **Optional flag**: `--level [minimal|standard|comprehensive]` -- security coverage level

## Process

1. **Platform Detection**: Identify the CI/CD platform from configuration files in the repository. If multiple are present, ask which is primary.

2. **Project Analysis**: Determine the tech stack from package manifests, build files, and source code patterns. This informs which scanning tools are relevant.

3. **Current State Audit**: Parse existing pipeline configuration to identify:
   - Which security scanning stages already exist
   - How they are configured (thresholds, gates)
   - What gaps remain

4. **Gap Analysis**: Compare current state against the selected coverage level:
   - **Minimal**: Secret detection + SCA (known vulnerabilities)
   - **Standard**: Minimal + SAST + container scanning (if applicable)
   - **Comprehensive**: Standard + DAST + IaC scanning + SBOM generation + license compliance

5. **Configuration Generation**: Produce pipeline configuration for the missing stages:
   - Use language-appropriate tools (e.g., Semgrep rules for the detected language, Bandit for Python-only)
   - Configure caching for scan databases
   - Set appropriate gates (block on critical/high for new projects, warn-only for existing projects with backlog)
   - Add SARIF upload where the platform supports it

6. **Integration Points**: Configure results to appear where developers see them:
   - GitHub: PR checks, Security tab (SARIF), Dependabot
   - GitLab: Merge request widgets, Security Dashboard
   - Jenkins: Build status, SonarQube integration

7. **Documentation**: Generate inline comments and a summary explaining each stage, tool choice, and gate threshold.

## Output

```
# DevSecOps Pipeline Setup Report

## Platform: [detected platform]
## Project: [language/framework]
## Coverage Level: [minimal/standard/comprehensive]

## Current Security Scanning
- [x] Secret detection (gitleaks - already configured)
- [ ] SAST (not present)
- [ ] SCA (not present)
- [x] Container scanning (Trivy - already configured)
- [ ] DAST (not present)
- [ ] IaC scanning (not present)

## Added Stages
[For each new stage:]
### [Stage Name]
- Tool: [tool name and version]
- Trigger: [when it runs]
- Gate: [block/warn/log]
- Configuration: [file path]

## Generated Files
- .github/workflows/security.yml (or equivalent)
- .semgrep.yml (SAST rules)
- .gitleaks.toml (secret patterns)
- .trivyignore (false positive suppressions)

## Next Steps
1. Review and merge the generated pipeline configuration
2. Run the pipeline on a feature branch to verify
3. Address initial findings before enabling blocking gates
4. Schedule a review to tighten thresholds after backlog burndown
```
