# /owasp-scan

> Audit source code against the OWASP Top 10 (2021), producing a structured security assessment report.

## Trigger

Use this command when you need a systematic security review of a web application codebase. Appropriate for:
- Pre-deployment security gates
- Code review with a security focus
- Periodic security assessments of existing applications
- Evaluating the security posture of an inherited or third-party codebase

## Input

The command operates on the current project directory. Optionally accepts:
- **Target scope**: Specific directories or files to focus on (defaults to entire project)
- **Framework hint**: If auto-detection fails, specify the framework (e.g., `django`, `rails`, `express`, `nextjs`, `spring`)
- **Severity threshold**: Minimum severity to report (`critical`, `high`, `medium`, `low`, `info`). Defaults to `low`.

## Process

### Phase 1: Reconnaissance (Stack Identification)

1. Identify the programming language(s) and framework(s) from project files (`package.json`, `requirements.txt`, `Gemfile`, `pom.xml`, `go.mod`, config files)
2. Determine the application architecture (monolith, microservices, serverless, static + API)
3. Identify the template engine, ORM, authentication library, and session management approach
4. Note framework version and check for known framework-level CVEs
5. Map entry points: routes, controllers, API endpoints, WebSocket handlers

### Phase 2: Systematic OWASP Top 10 Scan

Walk through each category in order, examining relevant code patterns:

**A01:2021 - Broken Access Control**
- Search for missing authorization checks on routes/endpoints
- Identify IDOR patterns (direct database ID references in URLs without ownership verification)
- Check for directory traversal in file operations
- Verify CORS configuration
- Look for privilege escalation paths (role checks, admin functions)

**A02:2021 - Cryptographic Failures**
- Check for hardcoded secrets, API keys, passwords in source code
- Verify password hashing algorithm (bcrypt/scrypt/argon2 vs MD5/SHA1)
- Check TLS configuration and certificate validation
- Look for sensitive data in URLs, logs, or error messages
- Verify encryption at rest for sensitive fields

**A03:2021 - Injection**
- SQL injection: raw queries, string concatenation in queries, ORM bypass patterns
- NoSQL injection: MongoDB operator injection, query object manipulation
- Command injection: `exec()`, `system()`, `child_process`, subprocess calls with user input
- LDAP injection, XPath injection, expression language injection
- Template injection (SSTI) in server-side template engines

**A04:2021 - Insecure Design**
- Missing rate limiting on authentication and sensitive operations
- Lack of CAPTCHA on public forms
- Missing account lockout mechanisms
- Absence of fraud detection patterns
- Insufficient input validation at the business logic level

**A05:2021 - Security Misconfiguration**
- Debug mode enabled in production configs
- Default credentials in configuration files
- Unnecessary features enabled (directory listing, admin consoles, dev endpoints)
- Missing security headers
- Verbose error messages exposing internals
- Outdated dependencies with known vulnerabilities

**A06:2021 - Vulnerable and Outdated Components**
- Parse dependency manifests and identify known CVEs
- Check for abandoned/unmaintained dependencies
- Identify dependencies with known security issues
- Verify dependency lock files exist and are committed

**A07:2021 - Identification and Authentication Failures**
- Weak password policy enforcement
- Missing multi-factor authentication on sensitive operations
- Session token predictability and entropy
- Session fixation vulnerabilities
- Missing session invalidation on logout/password change
- Credential exposure in logs or responses

**A08:2021 - Software and Data Integrity Failures**
- Insecure deserialization (`pickle.loads`, `unserialize`, `ObjectInputStream`, `JSON.parse` with reviver abuse)
- Missing integrity checks on updates, plugins, or CI/CD pipelines
- Unsigned or unverified data from external sources

**A09:2021 - Security Logging and Monitoring Failures**
- Missing audit logging for authentication events
- Missing logging for access control failures
- Log injection vulnerabilities
- Sensitive data in logs (passwords, tokens, PII)
- Missing alerting for suspicious activity patterns

**A10:2021 - Server-Side Request Forgery (SSRF)**
- URL parameters used in server-side HTTP requests
- Missing URL validation/allowlisting
- DNS rebinding susceptibility
- Internal service exposure through SSRF chains

### Phase 3: Report Generation

1. Deduplicate findings and merge related instances
2. Assign severity using CVSS v3.1 base scoring
3. Prioritize by exploitability and business impact
4. Generate remediation guidance with code examples
5. Produce systemic recommendations for recurring patterns

## Output

```
# OWASP Top 10 Security Audit Report

**Project**: [name]
**Framework**: [detected stack]
**Date**: [timestamp]
**Scope**: [directories/files assessed]

## Executive Summary

[2-3 sentence overview of security posture]
[Critical/High/Medium/Low/Info finding counts]
[Top 3 systemic risks]

## Findings

### Critical Findings
[Findings with CVSS >= 9.0]

### High Findings
[Findings with CVSS 7.0-8.9]

### Medium Findings
[Findings with CVSS 4.0-6.9]

### Low Findings
[Findings with CVSS 0.1-3.9]

### Informational
[Best practice recommendations]

## Systemic Recommendations

[Patterns observed across multiple findings that indicate architectural or process issues]

## Framework-Specific Hardening

[Security configuration checklist specific to the detected framework]
```
