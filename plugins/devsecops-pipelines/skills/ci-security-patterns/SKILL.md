# CI Security Patterns

> Reference patterns for integrating security scanning into GitHub Actions, GitLab CI, and Jenkins pipelines with real workflow syntax and production-ready configurations.

## Knowledge Base

### Pipeline Security Stage Ordering

Security scans should be ordered by speed and cost. Fast checks run first so slow checks only run on code that passes basic hygiene.

```
Pre-commit (local) --> Secrets + Lint
     |
Commit/PR (CI) --> Secrets --> SAST --> SCA --> License
     |
Build (CI) --> Container Scan --> SBOM --> Sign
     |
Test (CI) --> DAST (baseline) --> API Scan
     |
Deploy (CI) --> IaC Scan --> Artifact Verification
     |
Runtime (CD) --> Monitoring --> Runtime Protection
```

### Key Design Decisions

**Scan-on-PR vs. Scan-on-Push**: Run fast scans (SAST, secrets, SCA) on every PR. Run slower scans (DAST, full container scan) on merge to main or on a schedule.

**Incremental vs. Full Scan**: On PRs, scan only changed files (incremental) for speed. On main branch, run full scans. This is critical for SAST where full-project scans can take minutes.

**Fail-open vs. Fail-closed on tool error**: If the scanner itself crashes (not a finding, but the tool failing), should the pipeline pass or fail? Default: fail-open on PR (do not block development due to tool issues), fail-closed on deploy to production.

## Patterns

### Pattern 1: GitHub Actions -- Comprehensive Security Pipeline

```yaml
name: Security Pipeline
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main]
  schedule:
    - cron: '0 4 * * 1'  # Full scan weekly

permissions:
  contents: read
  security-events: write  # Required for SARIF upload
  pull-requests: write     # Required for PR comments

jobs:
  # Stage 1: Fast checks (< 1 minute)
  secrets-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # Full history for gitleaks
      - name: Run gitleaks
        uses: gitleaks/gitleaks-action@v2
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  # Stage 2: SAST (1-5 minutes)
  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run Semgrep
        uses: semgrep/semgrep-action@v1
        with:
          config: >-
            p/default
            p/owasp-top-ten
            p/r2c-security-audit
          generateSarif: "1"
      - name: Upload SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: semgrep.sarif

  # Stage 3: SCA (1-3 minutes)
  dependency-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run osv-scanner
        uses: google/osv-scanner-action/osv-scanner-action@v1
        with:
          scan-args: |-
            --recursive
            --format=sarif
            --output=osv-results.sarif
            .
      - name: Upload SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: osv-results.sarif

  # Stage 4: Container scan (if Dockerfile exists)
  container-scan:
    runs-on: ubuntu-latest
    if: hashFiles('**/Dockerfile') != ''
    needs: [secrets-scan, sast]  # Only if earlier stages pass
    steps:
      - uses: actions/checkout@v4
      - name: Build image
        run: docker build -t ${{ github.repository }}:${{ github.sha }} .
      - name: Run Trivy
        uses: aquasecurity/trivy-action@0.28.0
        with:
          image-ref: ${{ github.repository }}:${{ github.sha }}
          format: sarif
          output: trivy-results.sarif
          severity: CRITICAL,HIGH
          exit-code: 1  # Fail on critical/high
      - name: Upload SARIF
        if: always()
        uses: github/codeql-action/upload-sarif@v3
        with:
          sarif_file: trivy-results.sarif

  # Stage 5: IaC scan (if terraform/cloudformation present)
  iac-scan:
    runs-on: ubuntu-latest
    if: hashFiles('**/*.tf') != '' || hashFiles('**/cloudformation/**') != ''
    steps:
      - uses: actions/checkout@v4
      - name: Run Checkov
        uses: bridgecrewio/checkov-action@v12
        with:
          output_format: sarif
          output_file_path: checkov-results.sarif
          soft_fail: false
          framework: terraform,cloudformation

  # Stage 6: SBOM generation (on main branch only)
  sbom:
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    needs: [sast, dependency-scan]
    steps:
      - uses: actions/checkout@v4
      - name: Generate SBOM
        uses: anchore/sbom-action@v0
        with:
          format: cyclonedx-json
          output-file: sbom.cdx.json
      - name: Upload SBOM
        uses: actions/upload-artifact@v4
        with:
          name: sbom
          path: sbom.cdx.json
```

### Pattern 2: GitLab CI -- Security Scanning Integration

```yaml
# .gitlab-ci.yml
stages:
  - test
  - security
  - build
  - deploy

variables:
  SECURE_LOG_LEVEL: "info"

# Include GitLab security scanning templates
include:
  - template: Security/SAST.gitlab-ci.yml
  - template: Security/Secret-Detection.gitlab-ci.yml
  - template: Security/Dependency-Scanning.gitlab-ci.yml
  - template: Security/Container-Scanning.gitlab-ci.yml

# Override SAST to add custom rules
sast:
  stage: security
  variables:
    SAST_EXCLUDED_PATHS: "spec, test, tests, vendor"
    SEARCH_MAX_DEPTH: 10
  rules:
    - if: $CI_MERGE_REQUEST_IID
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

# Custom Semgrep scan with additional rulesets
semgrep-custom:
  stage: security
  image: semgrep/semgrep:latest
  script:
    - semgrep scan
      --config p/owasp-top-ten
      --config p/r2c-security-audit
      --sarif
      --output semgrep-results.sarif
      --error  # Exit non-zero on findings
  artifacts:
    reports:
      sast: semgrep-results.sarif
  rules:
    - if: $CI_MERGE_REQUEST_IID

# Trivy container scan with severity gate
container-scan-trivy:
  stage: security
  image:
    name: aquasec/trivy:latest
    entrypoint: [""]
  script:
    - trivy image
      --severity CRITICAL,HIGH
      --exit-code 1
      --format sarif
      --output trivy-results.sarif
      $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  artifacts:
    reports:
      container_scanning: trivy-results.sarif
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

### Pattern 3: Pre-commit Hooks for Local Security

```yaml
# .pre-commit-config.yaml
repos:
  # Secret detection before commit
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.4
    hooks:
      - id: gitleaks

  # SAST with Semgrep (fast, incremental)
  - repo: https://github.com/semgrep/semgrep
    rev: v1.56.0
    hooks:
      - id: semgrep
        args: ['--config', 'p/default', '--error']

  # Detect common security misconfigurations
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.5.0
    hooks:
      - id: detect-private-key
      - id: check-added-large-files
        args: ['--maxkb=500']  # Large binaries could hide malicious content
```

### Pattern 4: Jenkins Declarative Pipeline with Security

```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        TRIVY_CACHE = "${WORKSPACE}/.trivy-cache"
    }

    stages {
        stage('Security: Secrets Scan') {
            steps {
                sh '''
                    docker run --rm -v ${WORKSPACE}:/repo \
                      zricethezav/gitleaks:latest detect \
                      --source /repo \
                      --report-format sarif \
                      --report-path /repo/gitleaks-report.sarif
                '''
            }
            post {
                always {
                    recordIssues tool: sarif(pattern: 'gitleaks-report.sarif')
                }
            }
        }

        stage('Security: SAST') {
            steps {
                sh '''
                    docker run --rm -v ${WORKSPACE}:/src \
                      semgrep/semgrep:latest semgrep scan \
                      --config p/default \
                      --config p/owasp-top-ten \
                      --sarif --output /src/semgrep-results.sarif \
                      /src
                '''
            }
            post {
                always {
                    recordIssues tool: sarif(pattern: 'semgrep-results.sarif')
                }
            }
        }

        stage('Security: Dependency Check') {
            steps {
                dependencyCheck additionalArguments: '''
                    --scan .
                    --format SARIF
                    --out dependency-check-report.sarif
                ''', odcInstallation: 'dependency-check'
            }
            post {
                always {
                    recordIssues tool: sarif(pattern: 'dependency-check-report.sarif')
                }
            }
        }
    }

    post {
        failure {
            mail to: 'security-team@example.com',
                 subject: "Security gate failure: ${env.JOB_NAME}",
                 body: "Build ${env.BUILD_URL} failed security checks."
        }
    }
}
```

## Anti-Patterns

- **Adding every scanner at once**: Start with 2-3 scanners (secrets + SAST + SCA). Add more after the team adapts. Flooding developers with findings from six tools simultaneously guarantees they ignore all of them.
- **Running full DAST in PR pipelines**: DAST is slow (10-60+ minutes). Run baseline DAST scans nightly, not on every PR. Run full DAST scans pre-release.
- **Hardcoding secrets in pipeline configuration**: Pipeline YAML is code in the repository. Use CI/CD platform secret management (GitHub Secrets, GitLab CI Variables, Jenkins Credentials).
- **Ignoring scanner tool versions**: Pin scanner versions. An auto-updating scanner might introduce new rules mid-sprint that break builds for reasons unrelated to code changes.
- **No suppression mechanism**: Without a way to acknowledge and suppress false positives, developers learn to ignore all findings. Provide a suppression workflow with required justification.
- **Scanning only the application, not the pipeline**: The pipeline itself is an attack surface. Audit workflow permissions, runner access, secret scope, and artifact integrity.

## References

- GitHub Actions Security Hardening: https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions
- GitLab Security Scanning: https://docs.gitlab.com/ee/user/application_security/
- OWASP DevSecOps Guideline: https://owasp.org/www-project-devsecops-guideline/
- SARIF Specification: https://docs.oasis-open.org/sarif/sarif/v2.1.0/sarif-v2.1.0.html
- Semgrep Rules Registry: https://semgrep.dev/explore
- NIST SP 800-218 (SSDF): https://csrc.nist.gov/publications/detail/sp/800-218/final
