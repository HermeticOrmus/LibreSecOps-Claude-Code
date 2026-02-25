# /secure-review

> Run a security-focused code review on provided code, identifying vulnerability patterns and producing findings with vulnerable and fixed code side by side.

## Trigger

Use when reviewing code for security vulnerabilities. Appropriate for:
- Pull request security review
- Pre-deployment security checks
- Security audit of existing code
- Learning secure coding patterns by reviewing examples
- Validating that a security fix is correct and complete

## Input

- **Code to review**: Source code files, snippets, or file paths. Can be a single function, a complete file, or multiple related files
- **Language/Framework**: Auto-detected from code, but specify if ambiguous
- **Focus area** (optional): Specific vulnerability class to focus on (e.g., "injection," "authentication," "access control"). If not specified, performs comprehensive review
- **Context** (optional): Application purpose, deployment environment, data sensitivity level

## Process

1. **Language and framework identification** -- Determine the language, framework, and relevant security model (e.g., Django's built-in protections, Spring Security's filter chain)

2. **Trust boundary mapping** -- Identify all points where untrusted data enters the code:
   - HTTP request parameters, headers, body, cookies
   - Database query results (may contain attacker-controlled data)
   - File contents, environment variables
   - Third-party API responses
   - Message queue payloads

3. **Sink analysis** -- Identify security-sensitive operations:
   - Database queries (SQL/NoSQL injection)
   - HTML/template rendering (XSS)
   - Command execution (command injection)
   - File operations (path traversal, arbitrary file access)
   - Deserialization (RCE)
   - Cryptographic operations (weak crypto)
   - Authentication and authorization checks (bypass)

4. **Data flow tracing** -- For each source-sink pair, trace the data flow and check for:
   - Proper validation at the trust boundary
   - Correct encoding/escaping for the output context
   - Parameterization for structured data contexts (SQL, LDAP)
   - Authorization checks before sensitive operations

5. **Configuration review** -- Check security-relevant configurations:
   - Framework security middleware enabled and correctly ordered
   - CORS, CSP, and security headers configured
   - Cookie attributes (Secure, HttpOnly, SameSite)
   - Error handling (no stack traces in production)
   - Logging (no sensitive data in logs)

6. **Finding documentation** -- For each finding, produce the vulnerable code, attack scenario, fixed code, and explanation

## Output

```
## Security Code Review Report

**Language/Framework**: [detected or specified]
**Scope**: [files/functions reviewed]
**Date**: [review date]

### Risk Summary
| Severity | Count | Categories |
|----------|-------|------------|
| Critical | [n] | [categories] |
| High | [n] | [categories] |
| Medium | [n] | [categories] |
| Low | [n] | [categories] |

### Findings

#### [SEV] CWE-xxx: Finding Title
**Location**: [file:line]
**Category**: [OWASP Top 10 category]

**Vulnerable code**:
```[lang]
// highlighted vulnerable pattern
```

**Attack**: [Concrete exploitation scenario]

**Fixed code**:
```[lang]
// secure alternative
```

**Explanation**: [Why the fix works]

---

### Systemic Recommendations
[Patterns observed across findings that suggest architectural improvements]

### Positive Observations
[Security controls correctly implemented -- acknowledge good practices]

### Next Steps
1. [Prioritized remediation actions]
2. [Additional reviews recommended]
```
