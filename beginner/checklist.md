# Pre-Request Security Checklist

Before asking Claude Code to write security-sensitive code, verify these considerations. Copy this checklist into your prompt or review it mentally before each request.

---

## Context

- [ ] **Threat model stated**: Have I described what I am protecting, from whom, and the consequences of failure?
- [ ] **Environment specified**: Is this for development, staging, or production? (Claude defaults to dev-friendly, not production-hardened.)
- [ ] **Compliance requirements named**: Does this code fall under PCI-DSS, HIPAA, GDPR, SOC 2, or other frameworks? Name them explicitly.
- [ ] **Technology stack specified**: Have I named exact libraries and versions? (Avoids Claude choosing outdated or insecure defaults.)

## Input and Output

- [ ] **Input validation defined**: Have I specified type, length, format, and allowed character sets for every input field?
- [ ] **Output encoding specified**: Have I specified the output context (HTML, JSON, URL, SQL) and required encoding?
- [ ] **Error messages reviewed**: Have I requested generic client-facing errors with internal-only detail logging?
- [ ] **File handling secured**: If accepting file uploads, have I specified allowed types, size limits, and storage path handling?

## Authentication and Authorization

- [ ] **Auth mechanism named**: Have I specified the exact authentication method (JWT, session, OAuth, API key)?
- [ ] **Authorization checks requested**: Have I defined who can access this resource and at what level?
- [ ] **Tenant isolation enforced**: For multi-tenant systems, have I specified how tenant boundaries are enforced server-side?
- [ ] **Rate limiting specified**: Have I defined limits for this endpoint (requests per time window, per user or per IP)?

## Data Security

- [ ] **Secrets externalized**: Have I specified that credentials, API keys, and connection strings come from environment variables or a secrets manager?
- [ ] **Encryption specified**: Have I named specific algorithms (AES-256-GCM, bcrypt cost 12, TLS 1.2+) rather than saying "encrypt it"?
- [ ] **PII handling defined**: Have I identified which fields contain personal data and specified their handling rules?
- [ ] **Logging boundaries set**: Have I specified what to log (security events, request metadata) and what never to log (passwords, tokens, PII)?

## Dependencies and Infrastructure

- [ ] **Dependencies justified**: Have I reviewed whether new dependencies are necessary, maintained, and free of known CVEs?
- [ ] **Least privilege applied**: Have I specified minimum required permissions for database users, API keys, and IAM roles?
- [ ] **Security headers included**: Have I requested Helmet.js or equivalent security headers for HTTP responses?

## Verification

- [ ] **Tests requested**: Have I asked for tests covering valid input, invalid input, malicious input, and authorization boundaries?
- [ ] **Review planned**: Will I review the generated code for the vulnerability patterns listed in the beginner guide before deploying?

---

## Quick Copy-Paste Suffix

Append this to any Claude Code prompt for security-sensitive work:

```
Security requirements:
- Use parameterized queries for all database operations
- Validate all input with strict schemas (reject unknown fields)
- Return generic error messages to clients (log details server-side only)
- Never log PII, passwords, or tokens
- Use environment variables for all secrets
- Include rate limiting on this endpoint
- Add security headers (Helmet.js or equivalent)
- Write tests for valid, invalid, and malicious inputs
```

---

*Part of [LibreSecOps-Claude-Code](https://github.com/hermeticormus/LibreSecOps-Claude-Code) -- MIT License*
