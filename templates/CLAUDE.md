# Security Configuration -- CLAUDE.md Template

> Paste this into your project's `CLAUDE.md` file and customize each section for your application.
> Remove sections that do not apply. Fill in every section you keep -- incomplete configuration
> gives incomplete protection.

---

## Project Security Profile

- **Application Name:** [your-app-name]
- **Risk Classification:** [Critical / High / Medium / Low]
- **Data Sensitivity:** [PII / PHI / PCI / Financial / Public / Internal]
- **Deployment Environment:** [Production / Staging / Development]
- **Internet Facing:** [Yes / No]
- **Authentication Required:** [Yes / No]

---

## Secure Coding Standards

### Input Validation

All external input must be validated before processing. This applies to HTTP request parameters,
headers, file uploads, database query results from untrusted sources, and data from third-party APIs.

- **Allowlist over denylist:** Define what is permitted, reject everything else.
- **Type enforcement:** Validate data types, lengths, ranges, and formats at the boundary.
- **Parameterized queries:** Never concatenate user input into SQL, LDAP, or OS commands.
- **File uploads:** Validate file type by content inspection (magic bytes), not extension. Enforce size limits. Store outside the web root. Generate new filenames.

```
# Validation rules for this project:
# - Maximum string length: 10000 characters unless field-specific limit defined
# - Numeric ranges: enforce min/max per field
# - Email: RFC 5322 validation + domain verification for registration
# - URLs: scheme allowlist (https only), no internal/private IP ranges
# - File uploads: [specify allowed MIME types, max size]
```

### Output Encoding

Encode all output based on the rendering context to prevent injection attacks.

- **HTML context:** HTML entity encoding
- **JavaScript context:** JavaScript hex encoding
- **URL context:** Percent encoding
- **CSS context:** CSS hex encoding
- **JSON responses:** Proper JSON serialization with Content-Type: application/json

### Authentication Patterns

- **Password storage:** bcrypt with cost factor >= 12, or Argon2id
- **Session management:** Cryptographically random session IDs, minimum 128 bits of entropy. HttpOnly, Secure, SameSite=Strict cookies.
- **Multi-factor authentication:** Required for administrative access. TOTP or WebAuthn preferred over SMS.
- **Rate limiting:** Maximum 10 failed login attempts per account per 15-minute window. Implement progressive delays.
- **Account lockout:** Temporary lockout after threshold exceeded. Notify account owner via verified channel.

### Authorization Patterns

- **Principle of least privilege:** Default deny. Grant minimum permissions required.
- **Access control checks:** Enforce on every request, server-side. Never rely on client-side checks.
- **Indirect object references:** Use per-user or per-session indirect references instead of direct database IDs in URLs.
- **Role hierarchy:** [Define your application's roles and permission boundaries here]

### Error Handling

- **Never expose internals:** Stack traces, database errors, file paths, and version numbers must not appear in user-facing responses.
- **Structured error responses:** Return consistent error format with error code (for programmatic handling) and user-safe message.
- **Log the details:** Full error context goes to server-side logs, not to the client.
- **Fail closed:** If a security check encounters an error, deny access rather than allowing it.

### Cryptography

- **TLS:** Minimum TLS 1.2. Prefer TLS 1.3. Disable SSLv3, TLS 1.0, TLS 1.1.
- **Symmetric encryption:** AES-256-GCM for data at rest.
- **Asymmetric encryption:** RSA-4096 or Ed25519 for key pairs.
- **Hashing:** SHA-256 minimum for integrity checks. SHA-3 where available.
- **Random number generation:** Use cryptographically secure PRNG only (crypto.randomBytes, /dev/urandom, secrets module).
- **Key management:** Never hardcode keys. Use a secrets manager. Rotate per policy below.

---

## Security Scanning Configuration

### SAST (Static Application Security Testing)

Run static analysis on every pull request and before every merge to the main branch.

```
# Tool configuration:
# - Primary: Semgrep (https://semgrep.dev) with OWASP rulesets
# - Secondary: CodeQL for language-specific deep analysis
# - Custom rules: [path to custom rule definitions]
#
# Fail conditions:
# - Any HIGH or CRITICAL finding blocks merge
# - MEDIUM findings require reviewer acknowledgment
# - LOW findings tracked as tech debt
#
# Exclusions (justify each):
# - test/ directory: test fixtures contain intentional patterns
# - [add project-specific exclusions with justification]
```

### DAST (Dynamic Application Security Testing)

Run dynamic testing against staging environment before production deployment.

```
# Tool configuration:
# - Primary: OWASP ZAP (https://zaproxy.org) in CI/CD pipeline
# - Scan profile: Full active scan for release candidates, baseline scan for PRs
# - Authentication: Configure ZAP with valid session for authenticated scanning
# - Target: staging environment only, never production
#
# Schedule:
# - Baseline scan: every PR to main
# - Full scan: before each release
# - Comprehensive scan: monthly
```

### SCA (Software Composition Analysis)

Monitor all dependencies for known vulnerabilities continuously.

```
# Tool configuration:
# - Primary: Dependabot or Renovate for automated updates
# - Secondary: Snyk or Trivy for vulnerability database coverage
# - SBOM generation: CycloneDX format, generated on each release
#
# Thresholds:
# - CRITICAL (CVSS >= 9.0): Block deployment. Patch within 24 hours.
# - HIGH (CVSS >= 7.0): Block deployment. Patch within 7 days.
# - MEDIUM (CVSS >= 4.0): Track. Patch within 30 days.
# - LOW (CVSS < 4.0): Track. Patch in next maintenance cycle.
```

### Container Scanning

If the application uses containers, scan images before deployment.

```
# Tool configuration:
# - Primary: Trivy (https://trivy.dev)
# - Scan: base image + application layers
# - Base image policy: use distroless or Alpine minimal images
# - Rebuild schedule: weekly to pick up base image patches
# - Registry scanning: enable continuous monitoring in container registry
```

---

## Dependency Policy

### Allowed Sources

- **Package registries:** npm (npmjs.com), PyPI (pypi.org), crates.io, Maven Central
- **Container images:** Official images only from Docker Hub, or internal registry
- **No vendored forks** without security review and documented justification

### Evaluation Criteria for New Dependencies

Before adding any dependency, evaluate:

1. **Maintenance status:** Last commit within 6 months. Active issue triage.
2. **Security history:** Check Snyk Advisor or Socket.dev for known vulnerabilities and supply chain risks.
3. **Scope:** Does the dependency pull in a large transitive tree? Prefer lightweight alternatives.
4. **License compatibility:** Must be compatible with this project's license.
5. **Alternatives:** Is there a standard library solution or a more established package?

### Update Cadence

- **Security patches:** Apply within 24 hours of advisory publication for CRITICAL, 7 days for HIGH.
- **Minor updates:** Review and apply monthly.
- **Major updates:** Evaluate within 30 days of release. Schedule upgrade with testing.
- **Automated PRs:** Enable Dependabot or Renovate. Do not let automated PRs accumulate.

### Lock Files

- Commit lock files (package-lock.json, yarn.lock, Pipfile.lock, Cargo.lock).
- Verify lock file integrity in CI (npm ci, pip install --require-hashes).
- Investigate any unexpected lock file changes in PRs.

---

## Secret Management

### Rules

1. **No hardcoded secrets.** Not in source code, not in configuration files, not in comments, not in commit messages.
2. **No secrets in environment variable defaults.** `.env.example` files contain placeholder values only.
3. **No secrets in logs.** Implement log sanitization for known secret patterns.
4. **No secrets in error messages.** Strip sensitive data before any user-facing output.

### Secret Storage

```
# Vault configuration:
# - Provider: [HashiCorp Vault / AWS Secrets Manager / GCP Secret Manager / Azure Key Vault / 1Password]
# - Access method: [IAM role / service account / AppRole / Kubernetes auth]
# - Environment injection: secrets injected at runtime, never baked into images
```

### Rotation Policy

| Secret Type | Rotation Frequency | Automated |
|---|---|---|
| API keys | 90 days | Yes |
| Database credentials | 90 days | Yes |
| TLS certificates | Before expiry (auto-renew via ACME/Let's Encrypt) | Yes |
| Signing keys | Annually | No (manual ceremony) |
| Service account tokens | 90 days | Yes |
| User passwords | On compromise or annually (do not force frequent rotation) | No |

### Detection

- **Pre-commit hooks:** Run `gitleaks` or `trufflehog` before every commit.
- **CI scanning:** Run secret detection in CI pipeline as a blocking check.
- **Patterns monitored:** AWS keys, GCP service accounts, private keys, JWTs, database connection strings, API tokens.

---

## Compliance Requirements

Configure the sections below based on your regulatory obligations. Remove sections that do not apply.

### SOC 2 Type II

```
# Controls mapping:
# - CC6.1: Logical access security -- enforce RBAC, MFA for privileged access
# - CC6.2: System access restricted -- network segmentation, firewall rules
# - CC6.3: Access removed on termination -- automated deprovisioning
# - CC7.1: System monitoring -- centralized logging, alerting on anomalies
# - CC7.2: Anomaly detection -- SIEM rules, baseline deviation alerts
# - CC8.1: Change management -- PR reviews, deployment approvals, audit trail
#
# Evidence collection:
# - Access review logs: quarterly
# - Change management records: continuous (git history + deployment logs)
# - Incident response records: per incident
# - Vulnerability scan reports: monthly
```

### ISO 27001

```
# Annex A controls relevant to this application:
# - A.8.9: Configuration management
# - A.8.24: Use of cryptography
# - A.8.25: Secure development lifecycle
# - A.8.26: Application security requirements
# - A.8.28: Secure coding
# - A.8.31: Separation of development, test, production
# - A.8.33: Test information
# - A.8.34: Protection of information during audit testing
#
# ISMS integration:
# - Risk register entry: [reference ID in your risk register]
# - Asset classification: [classification level]
# - Business continuity: [RPO and RTO for this application]
```

### GDPR

```
# Data processing requirements:
# - Lawful basis: [Consent / Contract / Legitimate Interest / Legal Obligation]
# - Data categories processed: [list personal data categories]
# - Data subjects: [EU residents / employees / customers]
# - Retention period: [specify per data category]
# - Right to erasure: [implementation method -- hard delete vs anonymization]
# - Data portability: [export format and API endpoint]
# - Processing records: [location of Article 30 records]
# - DPO contact: [if applicable]
# - Cross-border transfers: [mechanism -- SCCs, adequacy decision, etc.]
```

### PCI DSS (if processing payment data)

```
# Applicable SAQ: [A / A-EP / D]
# Cardholder data flow: [document where card data enters, transits, and exits]
# Tokenization: [provider and integration method]
# Network segmentation: [CDE boundary definition]
# Quarterly ASV scan: [vendor and schedule]
# Annual penetration test: [vendor and schedule]
```

---

## Incident Response

### Contacts

| Role | Name | Contact | Backup |
|---|---|---|---|
| Security Lead | [name] | [email / phone] | [backup contact] |
| Engineering Lead | [name] | [email / phone] | [backup contact] |
| Legal / Privacy | [name] | [email / phone] | [backup contact] |
| Communications | [name] | [email / phone] | [backup contact] |

### Escalation Path

1. **Detection:** Automated alert or human report
2. **Triage (< 15 min):** Security Lead assesses severity and scope
3. **Containment (< 1 hour for CRITICAL):** Isolate affected systems, preserve evidence
4. **Eradication:** Remove threat, patch vulnerability, rotate credentials
5. **Recovery:** Restore from known-good state, verify integrity
6. **Post-incident review:** Blameless retrospective within 72 hours

### Severity Classification

| Severity | Definition | Response Time |
|---|---|---|
| CRITICAL | Active data breach, system compromise, or ransomware | Immediate (< 15 min) |
| HIGH | Vulnerability actively exploited, unauthorized access detected | < 1 hour |
| MEDIUM | Vulnerability discovered, suspicious activity under investigation | < 4 hours |
| LOW | Policy violation, minor misconfiguration, informational finding | < 24 hours |

### Communication Channels

- **Internal:** [Slack channel / Teams group / incident bridge]
- **External (customers):** [status page URL]
- **External (regulators):** [notification process per compliance requirements above]

---

## Security Testing Requirements

### OWASP Top 10 Verification

Every release must be verified against the current OWASP Top 10. Document findings and mitigations.

| # | Risk | Status | Verification Method |
|---|---|---|---|
| A01 | Broken Access Control | [Pass / Fail / N/A] | [Automated test / Manual review / DAST] |
| A02 | Cryptographic Failures | [Pass / Fail / N/A] | [Configuration audit / SAST] |
| A03 | Injection | [Pass / Fail / N/A] | [SAST + DAST / Parameterized queries verified] |
| A04 | Insecure Design | [Pass / Fail / N/A] | [Threat model review] |
| A05 | Security Misconfiguration | [Pass / Fail / N/A] | [Configuration scanning / CIS benchmark] |
| A06 | Vulnerable Components | [Pass / Fail / N/A] | [SCA scan] |
| A07 | Auth Failures | [Pass / Fail / N/A] | [Authentication testing / credential stuffing test] |
| A08 | Data Integrity Failures | [Pass / Fail / N/A] | [CI/CD pipeline review / SBOM verification] |
| A09 | Logging Failures | [Pass / Fail / N/A] | [Log coverage audit] |
| A10 | SSRF | [Pass / Fail / N/A] | [DAST / manual testing] |

### Penetration Testing

```
# Schedule:
# - Full penetration test: annually, or after major architecture changes
# - Focused test: quarterly, targeting recent changes
# - Vendor: [internal team / external firm name]
# - Scope: [full application / API only / infrastructure / all]
# - Methodology: OWASP Testing Guide v4.2, PTES, or NIST SP 800-115
# - Report delivery: within 10 business days of test completion
# - Remediation SLA: CRITICAL 7 days, HIGH 30 days, MEDIUM 90 days
```

### Automated Security Tests

```
# Security tests that run in CI/CD:
# - Unit tests for authentication and authorization logic
# - Integration tests for access control boundaries
# - Regression tests for previously found vulnerabilities (each gets a test)
# - Fuzzing: [specify targets -- parsers, API endpoints, file handlers]
# - Infrastructure as Code scanning: tfsec, checkov, or equivalent
```

---

## Claude Code Security Directives

When working on this project, Claude Code must:

1. **Never suggest disabling security controls** (CORS, CSP, authentication, TLS verification) even in development.
2. **Flag hardcoded secrets** immediately if encountered in code review or generation.
3. **Use parameterized queries** for all database operations. Never string concatenation.
4. **Validate all input** at the trust boundary before processing.
5. **Apply output encoding** appropriate to the rendering context.
6. **Prefer established libraries** over custom cryptography or authentication implementations.
7. **Include security headers** in all HTTP responses (CSP, HSTS, X-Frame-Options, X-Content-Type-Options).
8. **Log security events** (authentication attempts, authorization failures, input validation failures) with sufficient context for investigation but without sensitive data.
9. **Follow the dependency policy** above when suggesting new packages.
10. **Reference this document** when making security-relevant decisions.
