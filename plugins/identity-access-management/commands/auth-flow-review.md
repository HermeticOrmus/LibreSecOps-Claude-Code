# /auth-flow-review

> Review authentication and authorization flows for security issues.

## Trigger

Use when you need to:
- Review an OAuth 2.0/OIDC implementation for security issues
- Audit a login flow (web application, API, mobile app)
- Evaluate session management (token lifecycle, refresh handling)
- Review SAML SSO integration
- Assess JWT implementation for common vulnerabilities
- Evaluate API authentication mechanisms

## Input

One or more of:
- **Application code**: Authentication/authorization implementation code
- **Configuration**: OAuth client configuration, SAML metadata, OIDC discovery documents
- **Architecture diagram**: Authentication flow diagram showing all parties and token exchanges
- **API documentation**: Endpoint authentication requirements, API key/token handling
- **Specific protocol**: Focus on a specific protocol (OAuth, SAML, JWT, session cookies)

## Process

### Phase 1: Authentication Flow

1. **Protocol selection**
   - Which OAuth 2.0 grant type is used? (Authorization Code with PKCE is correct for web/mobile)
   - Is the implicit grant used? (deprecated, token in URL fragment)
   - Is client credentials used for user-facing auth? (wrong -- it is for service-to-service)
   - Are client secrets stored securely? (never in frontend code)

2. **Token handling**
   - Access token lifetime (should be short: 5-15 minutes)
   - Refresh token rotation (each use should issue a new refresh token)
   - Refresh token lifetime (hours to days, not months)
   - Token storage (httpOnly secure cookies, not localStorage)
   - Token revocation mechanism exists and works

3. **Redirect/callback security**
   - Redirect URI validation (exact match, not prefix/substring)
   - State parameter used (CSRF protection)
   - PKCE used for public clients (replaces client secret)
   - Open redirect vulnerabilities in callback handling

### Phase 2: Session Management

4. **Session security**
   - Session ID entropy (cryptographically random, sufficient length)
   - Cookie attributes: `HttpOnly`, `Secure`, `SameSite=Lax` or `Strict`
   - Session fixation prevention (regenerate session ID after login)
   - Idle timeout (15-30 minutes for sensitive applications)
   - Absolute timeout (8-24 hours regardless of activity)
   - Concurrent session limits

5. **Logout**
   - Server-side session invalidation (not just cookie deletion)
   - Token revocation on logout (for JWT-based sessions)
   - SSO single logout (SLO) -- does logging out of one app log out of all?
   - Backchannel logout for OIDC

### Phase 3: JWT Security (if applicable)

6. **JWT implementation**
   - Algorithm: RS256 or ES256 (asymmetric) preferred over HS256 (symmetric)
   - `alg: none` attack -- is it rejected?
   - Key confusion attack -- is HMAC secret separate from RSA public key?
   - Claims validation: `iss`, `aud`, `exp`, `nbf` all verified?
   - Token size (JWTs in cookies have size limits; avoid storing excessive claims)
   - JWKS endpoint (key rotation support)

### Phase 4: Authorization

7. **Authorization enforcement**
   - Where is authorization enforced? (API gateway, middleware, application code)
   - Are authorization checks consistent? (every endpoint, not just some)
   - Can authorization be bypassed by manipulating client-side state?
   - Are there IDOR (Insecure Direct Object Reference) vulnerabilities?
   - Horizontal privilege escalation (accessing other users' resources)
   - Vertical privilege escalation (accessing admin functionality)

8. **API authentication**
   - API key security (transmitted via header, not URL query parameter)
   - API key rotation mechanism
   - Rate limiting per API key
   - Scope restrictions on API keys/tokens

### Phase 5: Password Handling (if applicable)

9. **Password security**
   - Hashing algorithm (bcrypt, scrypt, or Argon2id -- NOT MD5, SHA1, SHA256 plain)
   - Salt: per-user, cryptographically random
   - Work factor appropriate (bcrypt cost >= 12, Argon2id with sufficient memory)
   - Password breach checking (HaveIBeenPwned API)
   - Account lockout or rate limiting on failed attempts
   - Credential stuffing protection

## Output

```
## Authentication Flow Security Review

### Flow Diagram
[ASCII diagram of the authentication/authorization flow]

### Protocol Assessment
- Protocol: [OAuth 2.0 / OIDC / SAML / Custom]
- Grant type: [Authorization Code + PKCE / Client Credentials / etc.]
- Compliance: [OAuth 2.0 Security BCP / OWASP ASVS]

### Summary
| Category | Critical | High | Medium | Low | Pass |
|----------|----------|------|--------|-----|------|
| Authentication |     |      |        |     |      |
| Session        |     |      |        |     |      |
| Token Handling |     |      |        |     |      |
| Authorization  |     |      |        |     |      |

### Findings (by severity)

#### Critical
[Findings with code-level remediation]

#### High
[Findings]

### Token Lifecycle
- Access token: [Lifetime, storage, validation]
- Refresh token: [Lifetime, rotation, revocation]
- Session: [Duration, idle timeout, fixation protection]

### Recommendations
1. [Highest priority fix]
2. [Next priority]
```
