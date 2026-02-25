# /api-sec-audit

> Audit API endpoints for security vulnerabilities against the OWASP API Security Top 10.

## Trigger

Use this command when you need to assess the security of an API-exposing application. Appropriate for:
- New API development before deployment
- Security review of existing API services
- Evaluating third-party API integrations
- Compliance requirements for API security (PCI-DSS, SOC 2, HIPAA)

## Input

Operates on the current project. Optionally accepts:
- **API type**: `rest`, `graphql`, `grpc`, `websocket` (auto-detected if not specified)
- **Spec file**: Path to OpenAPI/Swagger spec, GraphQL schema, or protobuf definitions
- **Focus area**: `auth`, `authorization`, `injection`, `data-exposure`, `all` (defaults to `all`)

## Process

### Phase 1: API Discovery

1. Identify the API framework (Express, FastAPI, Django REST Framework, Spring Boot, Rails API, NestJS, Gin, Echo, Fiber)
2. Parse route definitions to enumerate all endpoints with their HTTP methods
3. If OpenAPI/Swagger spec exists, cross-reference with code to find undocumented endpoints
4. For GraphQL, parse the schema (SDL or introspection query) to enumerate all queries, mutations, and subscriptions
5. Map middleware chains for each endpoint (authentication, authorization, validation, rate limiting)

### Phase 2: OWASP API Security Top 10 Assessment

**API1:2023 - Broken Object Level Authorization (BOLA)**
- For every endpoint accepting a resource identifier (path param, query param, body field), verify the handler checks that the authenticated user owns or has access to that resource
- Look for patterns where object IDs from the URL are used directly in database queries without ownership filtering
- Check batch endpoints that accept arrays of IDs

**API2:2023 - Broken Authentication**
- Analyze credential validation logic for timing attacks, enumeration, and brute force susceptibility
- Check token generation for sufficient entropy
- Verify token validation checks signature, expiration, issuer, and audience
- Test password reset and account recovery flows

**API3:2023 - Broken Object Property Level Authorization**
- Examine serializers/schemas for fields that should be read-only (mass assignment)
- Check if API responses include internal fields (password hashes, internal IDs, debug info)
- Verify that PATCH/PUT operations validate which fields a user can modify

**API4:2023 - Unrestricted Resource Consumption**
- Check for rate limiting middleware on all endpoints, especially authentication and data export
- Look for unbounded queries: missing pagination, unlimited file upload size, recursive operations without depth limits
- Check GraphQL query complexity/depth limits

**API5:2023 - Broken Function Level Authorization**
- Verify that admin-only endpoints check for admin role, not just authentication
- Look for API versioning issues where old versions lack authorization checks
- Check for method-based authorization bypass (GET allowed, POST restricted, but PUT not checked)

**API6:2023 - Unrestricted Access to Sensitive Business Flows**
- Identify business-critical flows (purchase, transfer, registration) and verify anti-automation controls
- Check for rate limiting, CAPTCHA, and fraud detection on these flows

**API7:2023 - Server-Side Request Forgery**
- Identify endpoints that accept URLs or hostnames as input and make server-side requests
- Check for URL validation, internal IP blocking, and redirect following

**API8:2023 - Security Misconfiguration**
- Check CORS configuration for overly permissive origins
- Verify error handling doesn't expose stack traces or internal details
- Check for exposed debug endpoints, health checks with sensitive info, or documentation endpoints in production
- Verify TLS configuration

**API9:2023 - Improper Inventory Management**
- Look for deprecated endpoints still accessible
- Check for shadow APIs (undocumented endpoints found in code but not in specs)
- Identify inconsistencies between API documentation and implementation

**API10:2023 - Unsafe Consumption of APIs**
- Check how the application consumes third-party APIs
- Verify response validation from external services
- Check for SSRF via third-party API responses

### Phase 3: Report Generation

1. Compile findings with severity ratings and OWASP category mapping
2. Generate endpoint-level security matrix
3. Provide remediation code for each finding
4. Produce architecture-level recommendations

## Output

```
# API Security Audit Report

**Project**: [name]
**API Framework**: [detected]
**API Type**: REST | GraphQL | gRPC | Mixed
**Endpoints Assessed**: [count]
**Date**: [timestamp]

## Endpoint Inventory
| Method | Path | Auth | AuthZ | Rate Limit | Notes |
|--------|------|------|-------|------------|-------|

## Executive Summary
[Overall security posture, critical findings count, top risks]

## Findings by OWASP API Category
[Findings grouped by API1-API10]

## Remediation Priority
[Ordered list of fixes by impact and effort]

## Architecture Recommendations
[Systemic improvements]
```
