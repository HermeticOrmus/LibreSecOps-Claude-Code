# Prompt Template: Build a Secure REST API Endpoint

This document provides a copy-paste-ready prompt for building a secure REST API endpoint with Claude Code. It demonstrates the difference between a vague prompt that produces vulnerable code and a precise prompt that produces defensible code.

---

## The Vague Version (Do Not Use)

```
Build a POST endpoint for creating notes. Use Express and PostgreSQL.
```

**What Claude generates**: A functional endpoint with string-concatenated SQL, no authentication, no input validation, verbose error messages, no rate limiting, and no logging. It works. It is also trivially exploitable.

---

## The Precise Version (Use This)

```
Build a POST /api/v1/notes endpoint in Express.js with TypeScript.
This endpoint is part of a multi-tenant SaaS application handling
business-sensitive data.

## Authentication and Authorization

- Require a valid JWT in the Authorization header (Bearer scheme)
- Extract user_id and tenant_id from the verified JWT payload
- Reject expired tokens with 401 and a generic "Authentication required" message
- The note must be created under the authenticated user's tenant_id
  (server-side enforcement, ignore any tenant_id in the request body)

## Input Validation

Use Zod for schema validation:
- title: string, required, 1-200 characters, trimmed, no control characters
- body: string, required, 1-50000 characters, trimmed
- tags: optional array of strings, max 10 tags, each 1-50 chars, alphanumeric
  and hyphens only
- Reject any additional properties not in the schema (strict mode)
- Return 400 with a generic "Invalid input" message on validation failure
  (do NOT return the Zod error details to the client)

## Database Operation

- Use parameterized queries (pg library with $1, $2 placeholders)
- INSERT into the notes table with: id (UUIDv4, server-generated),
  tenant_id (from JWT), user_id (from JWT), title, body, tags,
  created_at (server timestamp), updated_at (server timestamp)
- Return only: id, title, body, tags, created_at
  (do NOT return tenant_id, user_id, or internal fields)

## Rate Limiting

- 30 requests per minute per authenticated user
- Use a sliding window algorithm backed by Redis
- Return 429 with Retry-After header when limit exceeded
- Include X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset
  response headers on all responses

## Error Handling

- 400: Invalid input (generic message, no schema details)
- 401: Authentication required (no details about why auth failed)
- 403: Forbidden (if user somehow targets wrong tenant)
- 429: Rate limit exceeded (include Retry-After)
- 500: Internal server error (generic message + request ID for support)
- NEVER return: stack traces, SQL errors, internal paths, dependency names,
  or any information about the system's internals

## Logging

- Log every request with: timestamp, request_id (UUID), user_id,
  HTTP method, path, status code, response time in ms
- Log validation failures with: request_id, field that failed (not the value)
- Log database errors with: request_id, error code (not the full message
  if it contains query details)
- NEVER log: request body content, JWT tokens, IP addresses (hash them
  if needed for abuse detection), or any PII

## Security Headers

- Apply Helmet.js defaults
- Content-Type: application/json (prevent MIME sniffing issues)
- X-Content-Type-Options: nosniff
- X-Request-Id: return the request ID for client-side correlation

## Response Format

Success (201):
{
  "data": {
    "id": "uuid",
    "title": "string",
    "body": "string",
    "tags": ["string"],
    "created_at": "ISO 8601"
  }
}

Error (4xx/5xx):
{
  "error": {
    "message": "Human-readable generic message",
    "request_id": "uuid for support reference"
  }
}

## Testing Requirements

Include tests for:
- Successful creation with valid input
- Rejection of missing/invalid fields (each field)
- Rejection of extra properties (schema pollution)
- Rejection of requests without authentication
- Rejection of requests with expired tokens
- Tenant isolation (user cannot create notes under another tenant)
- Rate limiting triggers at correct threshold
- Error responses do not leak internal information
- SQL injection attempt in each string field is safely handled
- XSS payload in title/body is stored literally (not executed)
```

---

## Why This Works

The precise version specifies:

1. **Threat model context**: "multi-tenant SaaS with business-sensitive data" tells Claude the stakes.
2. **Specific algorithms and libraries**: Zod, pg with parameterized queries, bcrypt, Redis sliding window.
3. **Explicit deny patterns**: "NEVER return stack traces," "do NOT return Zod error details."
4. **Exact field constraints**: Character limits, allowed characters, maximum array lengths.
5. **Server-side enforcement**: tenant_id from JWT, not from request body.
6. **Logging boundaries**: What to log AND what never to log.
7. **Test cases**: Including adversarial inputs (SQL injection, XSS payloads).

The vague version leaves all of these decisions to Claude's defaults, which optimize for functionality, not security.

---

## Adapting This Template

To use this template for your own endpoints:

1. Replace the resource type (notes) with your resource
2. Update the Zod schema fields to match your data model
3. Adjust rate limits based on your expected legitimate usage patterns
4. Modify the authorization rules (who can create this resource?)
5. Update the logging fields relevant to your observability stack
6. Add any compliance-specific requirements (PCI-DSS, HIPAA, GDPR)

The structure -- authentication, validation, database, rate limiting, error handling, logging, testing -- applies to every endpoint. Keep it as a checklist.

---

*Part of [LibreSecOps-Claude-Code](https://github.com/hermeticormus/LibreSecOps-Claude-Code) -- MIT License*
