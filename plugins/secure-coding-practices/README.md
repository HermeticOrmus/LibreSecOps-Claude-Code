# Secure Coding Practices Plugin

> Language-agnostic secure coding guidance covering injection prevention, authentication patterns, input validation, and security-focused code review methodology.

## Overview

The Secure Coding Practices plugin equips Claude Code with deep expertise in writing and reviewing code that resists common vulnerability classes. Rather than focusing on a single language or framework, this plugin provides security patterns and anti-patterns across the major language ecosystems (Python, JavaScript/TypeScript, Java/Kotlin, Go, Rust, C/C++, Ruby, PHP, C#) while understanding that each language has its own idioms for achieving security.

The core philosophy is that security is a property of the code, not a layer added on top. Secure coding means choosing APIs, data structures, and control flows that make vulnerabilities structurally difficult rather than relying on developer discipline to avoid dangerous patterns.

This plugin covers the OWASP Top 10 vulnerability classes from the developer's perspective: not "how to find vulnerabilities" but "how to write code that does not have them." It is designed for developers writing new code, teams reviewing pull requests, and security engineers providing secure coding guidance.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Secure Code Reviewer | `agents/secure-code-reviewer.md` | Language-agnostic security-focused code review specialist. Reviews code for vulnerability patterns, insecure API usage, and missing security controls across all major languages. |
| Input Validation Specialist | `agents/input-validation-specialist.md` | Injection prevention specialist covering SQL, XSS, command injection, path traversal, and template injection across all major languages and frameworks. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/secure-review` | `commands/secure-review.md` | Run a security-focused code review on provided code, producing findings with vulnerable and fixed code side by side. |
| `/fix-vuln` | `commands/fix-vuln.md` | Fix a specific vulnerability class in provided code, with explanation of the root cause and verification of the fix. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Injection Prevention | `skills/injection-prevention/SKILL.md` | Comprehensive injection prevention patterns for SQL, XSS, command injection, path traversal, LDAP, and template injection across all major languages. |
| Secure Auth Patterns | `skills/secure-auth-patterns/SKILL.md` | Authentication, session management, and access control implementation patterns with platform-specific secure code examples. |

## Usage

### Code Review

Run `/secure-review` on any code snippet, file, or pull request to get a security-focused review. The command identifies vulnerability patterns and provides the fixed version in the same language.

### Fixing Specific Vulnerabilities

Use `/fix-vuln` when you know the vulnerability class (e.g., "SQL injection in the search endpoint") and need a guided fix with explanation. The command traces the data flow, identifies the root cause, applies the fix, and verifies it.

### Interactive Guidance

Activate the `secure-code-reviewer` agent for ongoing security review of a codebase. The agent will review files you provide and also identify systemic patterns that indicate broader security issues.

For input validation questions specifically, use the `input-validation-specialist` agent. It understands the nuances of different injection types and provides framework-specific prevention code.

## Key Concepts

- **Defense in depth**: Multiple layers of validation and encoding. Input validation at the boundary, parameterized queries at the data layer, output encoding at the presentation layer.
- **Secure by default**: Choose APIs and configurations that are secure in their default state. `innerHTML` is insecure by default; `textContent` is secure by default.
- **Fail secure**: When errors occur, the system should deny access rather than grant it. A failed authentication check should result in denial, not a bypass.
- **Least privilege**: Code should run with the minimum permissions needed. Database connections should use accounts with only the required permissions, not admin accounts.
- **Trust boundaries**: Define where untrusted data enters the system and validate/encode at those boundaries. Never trust client-side validation as the sole control.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `web-application-security` | This plugin teaches how to write secure code; web-app-security teaches how to find vulnerabilities in existing code. |
| `mobile-app-security` | Platform-specific secure coding for mobile builds on these general principles. |
| `api-security-testing` | API security testing verifies that secure coding practices are applied to API endpoints. |
| `cryptography-essentials` | Deep crypto knowledge for implementing the cryptographic patterns referenced here. |
| `devsecops-pipelines` | Automated enforcement of secure coding standards in CI/CD. |

## Methodology

Secure code review follows this systematic approach:

1. **Trust boundary identification** -- Where does untrusted data enter? (HTTP parameters, headers, file uploads, database records, environment variables, third-party API responses)
2. **Data flow tracing** -- Follow untrusted data from entry to use. Every transformation, storage, and output point is a potential vulnerability.
3. **Sink analysis** -- Identify dangerous function calls (SQL execution, HTML rendering, command execution, file operations) and verify that data reaching them is properly validated/encoded.
4. **Authentication and authorization** -- Verify that every sensitive operation checks both "who is this user?" and "are they allowed to do this?"
5. **Error handling** -- Verify that errors do not leak sensitive information and that error paths maintain security invariants.
6. **Dependency review** -- Check for known vulnerabilities in third-party libraries and frameworks.
