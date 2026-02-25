# API Security Testing Plugin

> Comprehensive API security assessment for REST, GraphQL, gRPC, and WebSocket interfaces, covering authentication flows, authorization bypass, data exposure, and injection attacks.

## Overview

The API Security Testing plugin provides Claude Code with specialized expertise in identifying and remediating security vulnerabilities in application programming interfaces. APIs are the backbone of modern applications -- they handle authentication, data exchange, and business logic. A single API vulnerability can expose entire databases, enable account takeover, or allow unauthorized actions at scale.

This plugin addresses the OWASP API Security Top 10 (2023) while extending coverage to practical attack patterns seen in real-world API penetration tests. It covers REST APIs, GraphQL endpoints, gRPC services, WebSocket connections, and webhook implementations.

The focus is on source-code-level analysis: reviewing route definitions, middleware chains, serializer configurations, authentication implementations, and authorization logic. Every finding includes the vulnerable pattern, an explanation of the risk, and a concrete code-level fix.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| API Security Tester | `agents/api-security-tester.md` | Full-spectrum API security specialist covering REST and GraphQL. Analyzes route definitions, middleware, input validation, serialization, rate limiting, and error handling. |
| Auth Flow Auditor | `agents/auth-flow-auditor.md` | Focused specialist for OAuth 2.0, OpenID Connect, JWT, API keys, and session-based authentication. Traces complete authentication and authorization flows to identify bypass opportunities. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/api-sec-audit` | `commands/api-sec-audit.md` | Structured API security audit producing categorized findings against the OWASP API Security Top 10 with severity ratings and remediation guidance. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| API Auth Patterns | `skills/api-auth-patterns/SKILL.md` | Reference knowledge base for secure authentication and authorization implementation patterns across OAuth 2.0, JWT, API keys, mTLS, and session management. |

## Usage

### Full API Audit

Run `/api-sec-audit` in any project that exposes APIs. The command identifies API frameworks, maps endpoints, and systematically checks each against known vulnerability patterns.

### Authentication Review

Activate the `auth-flow-auditor` agent when you need a focused review of authentication implementation. This agent traces token generation, validation, refresh, and revocation flows end-to-end, identifying weaknesses at each stage.

### Interactive Assessment

Use the `api-security-tester` agent for conversational security review. Describe your API architecture and the agent will guide you through the most relevant attack surface, asking targeted questions and analyzing code as you share it.

## Key Concepts

- **Authentication vs Authorization**: Authentication verifies identity ("who are you?"). Authorization verifies permissions ("are you allowed to do this?"). Most API vulnerabilities are authorization failures -- the user is authenticated but accessing resources they shouldn't.
- **Object-level authorization**: Every API endpoint that accesses a resource by ID must verify the requesting user has permission to access that specific object. This is the most common API vulnerability (BOLA/IDOR).
- **Mass assignment**: APIs that bind request body directly to data models allow attackers to set fields they shouldn't (e.g., `isAdmin: true`). Use explicit allowlists for writable fields.
- **Excessive data exposure**: APIs that return full database objects and rely on the frontend to filter sensitive fields. The API response itself is the attack surface.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `web-application-security` | Web apps consume APIs. Full-stack security requires both plugins. |
| `penetration-testing` | API testing is a major component of penetration test execution. |
| `threat-modeling` | Threat models identify which API endpoints are highest-risk targets. |
| `compliance-frameworks` | APIs handling PII or financial data have compliance requirements for authentication strength, encryption, and audit logging. |
| `secrets-management` | API keys, tokens, and credentials need proper lifecycle management. |

## OWASP API Security Top 10 (2023) Coverage

| # | Category | Coverage |
|---|----------|----------|
| API1 | Broken Object Level Authorization | Agent + Skill |
| API2 | Broken Authentication | Agent + Skill |
| API3 | Broken Object Property Level Authorization | Agent |
| API4 | Unrestricted Resource Consumption | Command |
| API5 | Broken Function Level Authorization | Agent + Command |
| API6 | Unrestricted Access to Sensitive Business Flows | Agent |
| API7 | Server Side Request Forgery | Cross-ref: web-application-security |
| API8 | Security Misconfiguration | Command |
| API9 | Improper Inventory Management | Command |
| API10 | Unsafe Consumption of APIs | Agent |

## Methodology

API security assessments follow this sequence:

1. **API discovery** -- Enumerate all endpoints from route definitions, OpenAPI/Swagger specs, GraphQL introspection, and code analysis
2. **Authentication analysis** -- Map the complete auth flow including token generation, validation, refresh, and revocation
3. **Authorization testing** -- Test object-level and function-level access control on every endpoint
4. **Input validation** -- Check all parameters for injection, type confusion, and boundary violations
5. **Data exposure review** -- Analyze response schemas for sensitive data leakage
6. **Rate limiting and abuse** -- Verify throttling on authentication, data export, and expensive operations
7. **Error handling** -- Check that errors don't leak internal details, stack traces, or query structures
