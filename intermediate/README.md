# Intermediate: Systematic Security Workflows with Claude Code

> You have the fundamentals. Now build systems that enforce security consistently, not through individual discipline, but through automation, architecture, and process.

**Prerequisites**: Complete `../beginner/` or have equivalent experience with OWASP Top 10, secure coding patterns, and Claude Code basics.

---

## Table of Contents

1. [Threat Modeling with Claude Code](#threat-modeling-with-claude-code)
2. [Security-as-Code: Embedding Checks in CI/CD](#security-as-code-embedding-checks-in-cicd)
3. [Dependency Auditing Workflows](#dependency-auditing-workflows)
4. [Secure Architecture Patterns](#secure-architecture-patterns)
5. [Case Study: Securing a SaaS Application](#case-study-securing-a-saas-application)
6. [CLAUDE.md Security Configuration](#claudemd-security-configuration)
7. [Weekly Security Learning Path](#weekly-security-learning-path)
8. [Integration with Security Tools](#integration-with-security-tools)

---

## Threat Modeling with Claude Code

Threat modeling is the practice of systematically identifying what can go wrong. It should happen before writing code, not after a breach.

### STRIDE Methodology

STRIDE is a framework developed at Microsoft for categorizing threats. Each letter represents a threat category:

| Category | Threat | Example | Security Property Violated |
|----------|--------|---------|---------------------------|
| **S**poofing | Pretending to be another user or system | Forged authentication tokens | Authentication |
| **T**ampering | Modifying data in transit or at rest | Altering price in a shopping cart request | Integrity |
| **R**epudiation | Denying an action occurred | User claims they never authorized a transfer | Non-repudiation |
| **I**nformation Disclosure | Exposing data to unauthorized parties | API returning full user objects including password hashes | Confidentiality |
| **D**enial of Service | Making a system unavailable | Unbounded query that locks the database | Availability |
| **E**levation of Privilege | Gaining higher access than authorized | Exploiting an IDOR to access admin endpoints | Authorization |

### STRIDE with Claude Code: Step by Step

**Step 1: Define the system boundary**

```
Prompt: "I'm building a multi-tenant SaaS platform for project management.
The system has: a React SPA frontend, a Node.js API, a PostgreSQL database,
Redis for sessions, and S3 for file storage. Users authenticate via email/password
and OAuth (Google, GitHub). There are three roles: viewer, editor, admin.
Each tenant's data must be completely isolated.

Create a data flow diagram listing every trust boundary, data store,
process, and external entity."
```

**Step 2: Apply STRIDE to each component**

```
Prompt: "Using the data flow diagram from the previous response, apply the
STRIDE model to each trust boundary crossing. For each crossing, enumerate:
1. What spoofing attacks are possible
2. Where data could be tampered with
3. What actions lack audit trails (repudiation)
4. Where information could leak (include side channels)
5. What denial of service vectors exist
6. Where privilege escalation is possible

Format as a threat table with: Threat ID, Category, Component, Description,
Likelihood (1-5), Impact (1-5), Risk Score, and Recommended Mitigation."
```

**Step 3: Prioritize and mitigate**

```
Prompt: "From the threat table, identify the top 10 risks by risk score.
For each, provide:
1. A specific, implementable mitigation (not generic advice)
2. The code or configuration change required
3. How to verify the mitigation works (test case)
4. What residual risk remains after mitigation"
```

### Threat Model Maintenance

A threat model is not a one-time document. Update it when:

- New features are added
- Architecture changes
- A new attack technique is published that affects your stack
- After any security incident

Store your threat model in version control alongside the code. A `THREAT_MODEL.md` in the repository root ensures it stays coupled to the codebase it describes.

---

## Security-as-Code: Embedding Checks in CI/CD

Manual security reviews do not scale. Encode your security requirements as automated checks that run on every commit, pull request, and deployment.

### The Security Pipeline

A mature security pipeline has these stages:

```
Commit → Pre-commit Hooks → CI Pipeline → Staging → Production
   │          │                  │            │          │
   │    Secret scanning    SAST scanning   DAST scan  WAF + monitoring
   │    Lint security      Dependency audit  Pen test  Runtime protection
   │    Format check       Container scan    Load test  Incident response
   │                       License audit
   │                       IaC scanning
```

### Pre-commit Hooks

Pre-commit hooks catch issues before they enter version control. This is the cheapest place to find a vulnerability -- before it is committed.

```yaml
# .pre-commit-config.yaml
repos:
  # Detect secrets before they are committed
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']

  # Security linting for Python
  - repo: https://github.com/PyCQA/bandit
    rev: 1.7.5
    hooks:
      - id: bandit
        args: ['-c', 'pyproject.toml']

  # Security linting for JavaScript/TypeScript
  - repo: https://github.com/nicolo-ribaudo/semgrep-pre-commit
    rev: v1.50.0
    hooks:
      - id: semgrep
        args: ['--config', 'p/javascript', '--config', 'p/typescript']
```

**Claude Code prompt for setup**:

```
"Generate a pre-commit configuration for a Node.js/TypeScript project
that includes: secret detection (detect-secrets), security linting
(semgrep with OWASP rules), and dependency checking (npm audit).
Include the installation instructions and a CI step that enforces
pre-commit hooks ran before merging."
```

### GitHub Actions Security Pipeline

```yaml
# .github/workflows/security.yml
name: Security Pipeline
on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  secret-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0
      - uses: trufflesecurity/trufflehog@main
        with:
          extra_args: --only-verified

  sast:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: returntocorp/semgrep-action@v1
        with:
          config: >-
            p/owasp-top-ten
            p/nodejs
            p/typescript

  dependency-audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npm audit --audit-level=high
      - run: npx better-npm-audit audit

  container-scan:
    runs-on: ubuntu-latest
    if: github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4
      - run: docker build -t app:${{ github.sha }} .
      - uses: aquasecurity/trivy-action@master
        with:
          image-ref: app:${{ github.sha }}
          severity: CRITICAL,HIGH
          exit-code: 1

  iac-scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: bridgecrewio/checkov-action@v12
        with:
          directory: infrastructure/
          framework: terraform
```

---

## Dependency Auditing Workflows

Your application's security is only as strong as its weakest dependency. Most modern applications are 80-90% third-party code.

### Node.js / npm

```bash
# Built-in audit
npm audit
npm audit --audit-level=high

# More detailed output with fix suggestions
npx better-npm-audit audit

# Automated fix (review changes before committing)
npm audit fix

# Check for outdated packages
npm outdated
```

**Claude Code workflow**:

```
"Audit all npm dependencies in this project. For each vulnerability
found: (1) explain the vulnerability in one sentence, (2) state
whether it's exploitable in our usage context, (3) recommend
update, replace, or accept-risk with justification."
```

### Python / pip

```bash
# Install pip-audit
pip install pip-audit

# Audit installed packages
pip-audit

# Audit from requirements file
pip-audit -r requirements.txt

# Generate SBOM
pip-audit --format=json -o audit-results.json
```

### Container Images

```bash
# Trivy for comprehensive container scanning
trivy image myapp:latest

# Scan with severity filter
trivy image --severity HIGH,CRITICAL myapp:latest

# Scan filesystem (not just container)
trivy fs --security-checks vuln,secret,config .

# Grype as an alternative
grype myapp:latest
```

### Snyk (Multi-ecosystem)

```bash
# Authenticate
snyk auth

# Test current project
snyk test

# Monitor continuously
snyk monitor

# Test a container image
snyk container test myapp:latest

# Test infrastructure as code
snyk iac test infrastructure/
```

### Automated Dependency Updates

Configure Dependabot or Renovate to automatically create PRs for dependency updates:

```yaml
# .github/dependabot.yml
version: 2
updates:
  - package-ecosystem: npm
    directory: "/"
    schedule:
      interval: weekly
    open-pull-requests-limit: 10
    labels:
      - "dependencies"
      - "security"
    # Group minor and patch updates
    groups:
      production-dependencies:
        patterns:
          - "*"
        update-types:
          - "minor"
          - "patch"
```

---

## Secure Architecture Patterns

### Defense in Depth

Never rely on a single security control. Layer independent defenses so that failure of one does not compromise the system.

```
Internet → WAF → Load Balancer → API Gateway → Application → Database
              │         │              │             │            │
         Rate limit  TLS termination  Auth/AuthZ   Input valid.  Encrypted
         IP filtering  DDoS protection  Rate limit  Parameterized  Row-level
         Geo blocking                  Logging     Output encoding  security
```

Each layer operates independently. If the WAF misses a SQL injection payload, the application's parameterized queries still prevent exploitation.

### Least Privilege

Every component should have the minimum permissions required to function.

**Database users**:

```sql
-- Application user: can only read/write application tables
CREATE USER app_user WITH PASSWORD '...';
GRANT SELECT, INSERT, UPDATE ON app.users TO app_user;
GRANT SELECT, INSERT, UPDATE, DELETE ON app.notes TO app_user;
-- No DROP, ALTER, CREATE, or access to other schemas

-- Migration user: used only during deployments
CREATE USER migration_user WITH PASSWORD '...';
GRANT ALL ON SCHEMA app TO migration_user;
-- Credentials rotated after each deployment
```

**API keys and tokens**: Scope to specific actions. An API key that reads user profiles should not be able to delete accounts.

**Cloud IAM**: Use roles, not root credentials. Scope roles to specific resources.

```
Prompt: "Review this IAM policy and apply least privilege. For each
permission, explain why it is needed or flag it for removal. The
application only needs to: read from S3 bucket X, write to SQS queue Y,
and read secrets from Secrets Manager path /app/prod/*."
```

### Zero Trust Basics

Traditional security assumes everything inside the network perimeter is trusted. Zero trust assumes nothing is trusted.

Core principles:

1. **Verify explicitly**: Always authenticate and authorize based on all available data points (user identity, location, device health, service or workload, data classification, anomalies).
2. **Use least-privilege access**: Limit user access with just-in-time and just-enough-access (JIT/JEA), risk-based adaptive policies.
3. **Assume breach**: Minimize blast radius with micro-segmentation, end-to-end encryption, continuous monitoring, and automated threat detection.

**Practical application with Claude Code**:

```
"Design the authentication and authorization architecture for a
microservices system using zero trust principles. Each service must
authenticate to every other service (no implicit trust from being
on the same network). Use mTLS for service-to-service auth, JWT
with short expiry (15 min) for user auth, and implement a policy
decision point that evaluates user identity + device posture +
request context for every API call."
```

---

## Case Study: Securing a SaaS Application

This case study walks through securing a project management SaaS application across four domains: authentication, API, data, and infrastructure.

### Authentication Layer

**Requirements**: Email/password and OAuth, MFA support, session management, account recovery.

```
Prompt: "Design and implement the authentication system for a
multi-tenant SaaS application with these requirements:

Authentication methods:
- Email/password with bcrypt (cost 12), minimum 12 chars, zxcvbn score >= 3
- OAuth 2.0 with Google and GitHub (PKCE flow for SPA)
- TOTP-based MFA (optional but prompted after first login)

Session management:
- Server-side sessions in Redis with 1-hour sliding expiry
- Secure cookie: HttpOnly, Secure, SameSite=Strict
- Concurrent session limit: 5 per user
- Session invalidation on password change

Account recovery:
- Time-limited reset tokens (15 min), single-use, stored hashed
- No security questions (they weaken security)
- Rate limit: 3 reset emails per hour per account

Logging:
- Log all auth events (login, logout, failed attempt, MFA, reset)
- Include: timestamp, IP, user agent, success/failure, user ID
- Exclude: passwords, tokens, session IDs"
```

### API Security

**Requirements**: Input validation, rate limiting, authorization, CORS, security headers.

```
Prompt: "Implement API middleware stack for Express.js with:

1. Helmet.js for security headers (CSP, HSTS, X-Frame-Options, etc.)
2. CORS restricted to app.example.com with credentials
3. Request body size limit: 1MB for JSON, 10MB for file uploads
4. Rate limiting:
   - Global: 100 req/min per IP
   - Auth endpoints: 5 req/15 min per IP
   - API endpoints: 60 req/min per user
5. Input validation middleware using Zod schemas
6. Request ID generation for tracing
7. Response time logging
8. Error handler that logs full error internally but returns
   generic message + request ID to client"
```

### Data Security

**Requirements**: Tenant isolation, encryption, backup security, data classification.

```
Prompt: "Design the data security architecture for a multi-tenant
PostgreSQL database:

Tenant isolation:
- Row-level security (RLS) policies on all tenant tables
- tenant_id column on every table, enforced by RLS
- Application cannot bypass RLS (separate migration user for schema changes)

Encryption:
- At rest: PostgreSQL TDE or volume encryption
- Sensitive fields (SSN, payment info): application-level encryption
  with AES-256-GCM, key managed by AWS KMS
- In transit: TLS 1.2+ required for all connections

Backup security:
- Automated daily backups, encrypted at rest
- Backup access requires separate credentials
- Test restore procedure monthly
- Backup retention: 30 days, then secure deletion

Data classification:
- Public: project names, public descriptions
- Internal: user emails, project details
- Confidential: passwords (hashed), API keys (encrypted), billing info
- Each classification has defined handling rules"
```

### Infrastructure Security

```
Prompt: "Design the infrastructure security for deploying this SaaS
application on AWS:

Network:
- VPC with public and private subnets
- Database and Redis in private subnets only
- NAT gateway for outbound from private subnets
- Security groups: minimal ingress, stateful

Compute:
- ECS Fargate (no EC2 instance management)
- Container images scanned with Trivy before deployment
- Non-root container user
- Read-only filesystem where possible

Secrets:
- AWS Secrets Manager for all credentials
- Automatic rotation for database credentials (30 days)
- No secrets in environment variables, container images, or code

Monitoring:
- CloudWatch for application and infrastructure logs
- CloudTrail for API audit trail
- GuardDuty for threat detection
- Alerting on: auth failures > threshold, privilege escalation,
  unusual data access patterns, configuration changes"
```

---

## CLAUDE.md Security Configuration

Your project's `CLAUDE.md` file configures Claude Code's behavior for that repository. Use it to enforce security standards automatically.

### Security-Focused CLAUDE.md Template

```markdown
# CLAUDE.md - Security Standards

## Security Requirements

All code generated for this project MUST:

1. Use parameterized queries for ALL database operations (never string concatenation)
2. Validate ALL input using Zod schemas before processing
3. Use bcrypt (cost >= 12) for password hashing
4. Include rate limiting on all public endpoints
5. Return generic error messages to clients (log details server-side)
6. Never log PII (passwords, tokens, emails, IP addresses in plain text)
7. Use environment variables for all secrets (never hardcode)
8. Set security headers via Helmet.js on all responses
9. Implement RBAC checks on every endpoint
10. Use HTTPS-only cookies with HttpOnly, Secure, SameSite=Strict

## Dependency Policy

- No new dependencies without justification
- All dependencies must be actively maintained (commit in last 6 months)
- No dependencies with known HIGH or CRITICAL CVEs
- Pin exact versions in package.json (no ^ or ~)

## Code Review Triggers

Flag for human review if generated code contains:
- eval(), Function(), or dynamic code execution
- innerHTML or dangerouslySetInnerHTML
- child_process.exec() with string arguments
- fs operations with user-supplied paths
- Disabled security controls (CORS *, TLS verification off)
- Raw SQL strings
- Any TODO or FIXME related to security

## Testing Requirements

All security-sensitive code must include:
- Unit tests for input validation (valid, invalid, edge cases, malicious)
- Integration tests for auth flows (success, failure, lockout, session expiry)
- Tests that verify errors do not leak sensitive information
```

### Per-Environment Overrides

For projects with multiple environments, section your CLAUDE.md:

```markdown
## Development Environment
- CORS: allow localhost:3000
- Rate limiting: relaxed (1000/min) for testing
- Logging: verbose, include stack traces

## Staging Environment
- CORS: allow staging.example.com
- Rate limiting: production values
- Logging: structured JSON, no stack traces

## Production Environment
- CORS: allow app.example.com only
- Rate limiting: strict (see rate-limit.config.ts)
- Logging: structured JSON, alerts on security events
- CSP: strict, report-only disabled
```

---

## Weekly Security Learning Path

A structured approach to building security knowledge over 8 weeks. Each week builds on the previous.

### Phase 1: Foundation (Weeks 1-2)

**Week 1: Reconnaissance**
- Read: OWASP Testing Guide, chapters 1-3
- Practice: Use Claude Code to enumerate the attack surface of one of your projects
- Tool: Install and run `nmap` against your local dev environment
- Exercise: Document every external input your application accepts

**Week 2: Authentication and Session Management**
- Read: OWASP Authentication Cheat Sheet
- Practice: Audit your project's auth implementation against the cheat sheet
- Tool: Use `hydra` or `burp` to test your login endpoint's brute-force protection
- Exercise: Implement session management improvements identified in audit

### Phase 2: Application Security (Weeks 3-4)

**Week 3: Injection and Input Handling**
- Read: CWE-89 (SQLi), CWE-79 (XSS), CWE-78 (OS Command Injection)
- Practice: Use `sqlmap` against a deliberately vulnerable test app (DVWA)
- Tool: Set up Semgrep with OWASP rules in your CI pipeline
- Exercise: Write Semgrep custom rules for patterns specific to your codebase

**Week 4: Access Control and API Security**
- Read: OWASP API Security Top 10
- Practice: Test your API for IDOR, BOLA, and broken function-level authorization
- Tool: Use Postman or `curl` scripts to systematically test authorization boundaries
- Exercise: Implement row-level security or equivalent for multi-tenant data

### Phase 3: Infrastructure Security (Weeks 5-6)

**Week 5: Container and Cloud Security**
- Read: CIS Benchmarks for Docker, your cloud provider
- Practice: Scan your container images with Trivy, fix all HIGH findings
- Tool: Set up Checkov for IaC scanning
- Exercise: Implement least-privilege IAM for your deployment pipeline

**Week 6: Secrets and Supply Chain**
- Read: SLSA framework (Supply-chain Levels for Software Artifacts)
- Practice: Implement secret rotation for all credentials in one project
- Tool: Set up TruffleHog in pre-commit and CI
- Exercise: Create an SBOM for your project, review all transitive dependencies

### Phase 4: Operations (Weeks 7-8)

**Week 7: Monitoring and Detection**
- Read: MITRE ATT&CK framework, Initial Access and Execution tactics
- Practice: Set up security-relevant logging and alerting
- Tool: Configure log aggregation with security-specific dashboards
- Exercise: Create detection rules for the top 5 threats from your threat model

**Week 8: Incident Response**
- Read: NIST Incident Response Guide (SP 800-61)
- Practice: Run a tabletop exercise using a scenario from your threat model
- Tool: Set up and document your incident response communication channels
- Exercise: Write a runbook for your application's most likely security incident

---

## Integration with Security Tools

### SAST (Static Application Security Testing)

SAST tools analyze source code without running it. They find vulnerability patterns by examining code structure.

**Semgrep** (recommended -- open source, extensible):

```bash
# Install
pip install semgrep

# Run with OWASP rules
semgrep --config p/owasp-top-ten .

# Run with language-specific rules
semgrep --config p/javascript --config p/typescript .

# Run with all security rules
semgrep --config p/security-audit .

# Custom rules in your repo
semgrep --config .semgrep/ .
```

**Claude Code integration**:

```
"Analyze the Semgrep results below and for each finding:
1. Confirm if it's a true positive or false positive with reasoning
2. If true positive, write the fix
3. If false positive, write a Semgrep rule exclusion comment with justification

[paste semgrep output]"
```

### Secret Detection

**TruffleHog**:

```bash
# Scan git history for secrets
trufflehog git file://. --only-verified

# Scan a specific branch
trufflehog git file://. --branch main --only-verified

# Scan in CI (most recent changes only)
trufflehog git file://. --since-commit HEAD~1 --only-verified
```

**detect-secrets** (pre-commit):

```bash
# Create baseline (existing known secrets)
detect-secrets scan > .secrets.baseline

# Audit baseline (mark false positives)
detect-secrets audit .secrets.baseline

# Scan for new secrets
detect-secrets scan --baseline .secrets.baseline
```

### Container Scanning

**Trivy**:

```bash
# Scan image
trivy image --severity HIGH,CRITICAL app:latest

# Scan with fix information
trivy image --severity HIGH,CRITICAL --ignore-unfixed app:latest

# Scan Dockerfile for misconfigurations
trivy config Dockerfile

# Scan filesystem
trivy fs --security-checks vuln,secret,config .

# Generate SBOM
trivy image --format cyclonedx --output sbom.json app:latest
```

### DAST (Dynamic Application Security Testing)

DAST tools test running applications by sending requests and analyzing responses.

**OWASP ZAP** (open source):

```bash
# Quick scan
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t https://staging.example.com

# Full scan
docker run -t owasp/zap2docker-stable zap-full-scan.py \
  -t https://staging.example.com

# API scan (with OpenAPI spec)
docker run -t owasp/zap2docker-stable zap-api-scan.py \
  -t https://staging.example.com/api/openapi.json -f openapi
```

**Nuclei** (template-based scanner):

```bash
# Install
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest

# Scan with all templates
nuclei -u https://staging.example.com

# Scan with specific severity
nuclei -u https://staging.example.com -severity high,critical

# Scan with specific template category
nuclei -u https://staging.example.com -tags cve,owasp
```

---

## Next Steps

After completing this intermediate material:

1. Implement a full security pipeline for one of your projects
2. Conduct a STRIDE threat model and document it in version control
3. Set up a `CLAUDE.md` with security standards for your primary project
4. Complete the 8-week learning path
5. Move to `../advanced/` for automated security operations and red/blue team workflows

---

*Part of [LibreSecOps-Claude-Code](https://github.com/hermeticormus/LibreSecOps-Claude-Code) -- MIT License*
