# API Authentication Patterns

> Secure authentication and authorization implementation patterns for APIs, covering OAuth 2.0, JWT, API keys, mTLS, and session management.

## Knowledge Base

### OAuth 2.0 Flows

**Authorization Code with PKCE (Recommended for most applications)**

The most secure flow for applications that interact with users. PKCE (Proof Key for Code Exchange, RFC 7636) prevents authorization code interception attacks and is required for public clients and recommended for all clients.

Flow:
1. Client generates random `code_verifier` (43-128 characters, unreserved URI characters)
2. Client computes `code_challenge = BASE64URL(SHA256(code_verifier))`
3. Client redirects user to authorization endpoint with `code_challenge` and `code_challenge_method=S256`
4. User authenticates and consents
5. Authorization server redirects back with `code`
6. Client exchanges `code` + `code_verifier` at token endpoint
7. Authorization server verifies `SHA256(code_verifier) == code_challenge` and issues tokens

Security requirements:
- State parameter: Cryptographically random, bound to user session, verified on callback
- Redirect URI: Exact match validation (no wildcards, no path traversal)
- PKCE: S256 method only (plain method provides no security)
- Token endpoint: Authenticated with client_secret (confidential clients) or PKCE only (public clients)

**Client Credentials (Machine-to-machine)**

For service-to-service communication where no user is involved.

Security requirements:
- Client secrets rotated regularly and stored securely (not in code)
- Scope limited to minimum required permissions
- Short token lifetimes (5-15 minutes)
- mTLS client certificate binding for high-security environments

### JWT Best Practices

**Token Structure and Signing**:
```json
// Header
{
  "alg": "RS256",   // Use asymmetric algorithms for distributed validation
  "typ": "JWT",
  "kid": "key-2024-01"  // Key ID for rotation support
}

// Payload
{
  "iss": "https://auth.example.com",   // Issuer - validate this
  "sub": "user-uuid-here",             // Subject - the user identifier
  "aud": "https://api.example.com",    // Audience - validate this
  "exp": 1700000000,                   // Expiration - short-lived (15-60 min)
  "nbf": 1699999000,                   // Not before
  "iat": 1699999000,                   // Issued at
  "jti": "unique-token-id",            // JWT ID - for revocation tracking
  "scope": "read:users write:orders"   // Scopes/permissions
}
```

**Validation checklist** (every check is mandatory):
1. Verify signature using the correct key (matched via `kid`)
2. Verify `alg` matches expected algorithm (reject `none`, reject unexpected algorithms)
3. Verify `exp` (token not expired, with small clock skew tolerance of 30-60 seconds max)
4. Verify `nbf` (token is active)
5. Verify `iss` (matches your authorization server)
6. Verify `aud` (includes your service identifier)
7. For revocation: check `jti` against revocation list or token introspection endpoint

**Algorithm Selection**:
| Algorithm | Use Case | Key Management |
|-----------|----------|---------------|
| RS256 | Distributed systems, multiple validators | Public key distribution via JWKS |
| ES256 | Same as RS256, smaller tokens | ECDSA keys, same JWKS distribution |
| EdDSA | Modern systems, best performance | Ed25519 keys |
| HS256 | Single service validates its own tokens only | Shared secret, 256+ bits |

Never use: `none` algorithm, RSA with key < 2048 bits, HMAC with weak secrets

**Token Storage**:
| Storage | XSS Safe | CSRF Safe | Recommendation |
|---------|----------|-----------|----------------|
| HttpOnly cookie | Yes | No (needs CSRF token) | Best for web apps with same-origin API |
| localStorage | No | Yes | Avoid for sensitive tokens |
| sessionStorage | No | Yes | Avoid for sensitive tokens |
| Memory (variable) | Yes | Yes | Best for SPAs, lost on refresh |
| HttpOnly cookie + refresh token | Yes | Use SameSite=Strict | Best overall for web apps |

### API Key Security

**Generation**:
- Minimum 256 bits of entropy from cryptographically secure random source
- Prefix keys with service identifier for identification: `sk_live_`, `pk_test_`
- Hash keys before storage (SHA-256 or bcrypt). Store only the hash. Display the full key only once at creation.

**Implementation**:
```python
# GOOD: Constant-time comparison
import hmac

def validate_api_key(provided_key: str) -> bool:
    key_hash = hashlib.sha256(provided_key.encode()).hexdigest()
    stored_hash = db.get_api_key_hash(key_hash[:8])  # Prefix lookup
    if stored_hash is None:
        return False
    return hmac.compare_digest(key_hash, stored_hash)

# BAD: Timing attack vulnerable
def validate_api_key(provided_key: str) -> bool:
    return provided_key == db.get_api_key()  # == is not constant-time
```

**Lifecycle**:
- Enforce expiration dates on all keys
- Support multiple active keys per client for rotation
- Log all key usage for auditing
- Implement rate limiting per key
- Provide immediate revocation capability

### Mutual TLS (mTLS)

For high-security service-to-service authentication:
- Both client and server present certificates
- Certificates tied to service identity
- Certificate pinning for known internal services
- CRL or OCSP for certificate revocation checking
- Short-lived certificates (hours to days) with automated rotation

### Session Management

**Secure Session Configuration**:
```javascript
// Express session configuration
app.use(session({
  secret: process.env.SESSION_SECRET,  // High-entropy secret from env
  name: '__Host-sid',                  // __Host- prefix enforces Secure + no Domain
  resave: false,
  saveUninitialized: false,
  cookie: {
    secure: true,        // HTTPS only
    httpOnly: true,       // No JavaScript access
    sameSite: 'strict',   // No cross-site sending
    maxAge: 3600000,      // 1 hour absolute timeout
    path: '/'
  },
  store: new RedisStore({ client: redisClient })  // Server-side storage
}));
```

**Session lifecycle events requiring action**:
| Event | Required Action |
|-------|----------------|
| Successful login | Regenerate session ID (prevent fixation) |
| Privilege escalation | Regenerate session ID |
| Password change | Invalidate ALL other sessions |
| MFA enrollment/change | Invalidate ALL other sessions |
| Account deactivation | Invalidate ALL sessions immediately |
| Logout | Destroy server-side session data |
| Idle timeout | Destroy session after inactivity period |

## Patterns

### Authorization Middleware Pattern
```python
# Layered authorization: authenticate -> authorize -> handle
@app.route('/api/orders/<order_id>', methods=['GET'])
@require_auth          # Layer 1: Verify identity (token/session valid)
@require_scope('read:orders')  # Layer 2: Verify permission (scope/role)
def get_order(order_id):
    order = Order.query.get_or_404(order_id)
    if order.user_id != g.current_user.id:  # Layer 3: Object-level authorization
        abort(403)
    return OrderSchema(exclude=['internal_notes']).dump(order)  # Layer 4: Response filtering
```

### Token Refresh Pattern
```
Access Token: Short-lived (15 minutes)
Refresh Token: Long-lived (7 days), single-use, rotated on every use

1. Client sends access token with each request
2. When access token expires (401), client sends refresh token to /token/refresh
3. Server validates refresh token, issues NEW access token + NEW refresh token
4. Server invalidates the OLD refresh token
5. If an already-invalidated refresh token is presented, revoke ALL tokens for that user (compromise detected)
```

### Rate Limiting Pattern
```
Authentication endpoints:
  - Login: 5 attempts per account per 15 minutes (exponential backoff)
  - Password reset: 3 requests per email per hour
  - OTP verification: 5 attempts per code per 10 minutes
  - Token refresh: 10 requests per token per hour

General API:
  - Per-user: 1000 requests per minute
  - Per-IP (unauthenticated): 100 requests per minute
  - Expensive operations: 10 requests per minute per user
```

## Anti-Patterns

- **JWT as session replacement without revocation**: JWTs cannot be revoked without additional infrastructure (blocklist, token introspection). If you need immediate revocation, use server-side sessions or add a token blocklist.
- **Storing sensitive data in JWT payload**: JWT payloads are base64-encoded, not encrypted. Anyone with the token can read the claims. Never put passwords, full credit card numbers, or PII in JWTs.
- **Symmetric JWT signing in distributed systems**: If multiple services need to validate tokens, HS256 requires sharing the secret with all of them. One compromised service compromises all services. Use asymmetric algorithms (RS256/ES256) with JWKS.
- **Long-lived access tokens**: Access tokens that last days or weeks mean a stolen token provides extended access. Keep access tokens short (15-60 minutes) and use refresh tokens for longevity.
- **API keys in URLs**: `GET /api/data?api_key=secret` leaks via browser history, server logs, Referer headers, and proxy logs. Send API keys in headers (`Authorization` or custom header).
- **Client-side token validation only**: Never validate JWT signatures only on the client. The server must validate every token on every request.
- **Password comparison without constant-time function**: String comparison (`==`) returns early on first mismatch, leaking password length. Use `hmac.compare_digest()` or equivalent.

## References

- [RFC 6749 - OAuth 2.0 Authorization Framework](https://datatracker.ietf.org/doc/html/rfc6749)
- [RFC 7519 - JSON Web Token (JWT)](https://datatracker.ietf.org/doc/html/rfc7519)
- [RFC 7636 - PKCE for OAuth](https://datatracker.ietf.org/doc/html/rfc7636)
- [OWASP API Security Top 10 2023](https://owasp.org/API-Security/)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [OWASP Session Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html)
- [JWT Best Current Practices (RFC 8725)](https://datatracker.ietf.org/doc/html/rfc8725)
- [OAuth 2.0 Security Best Current Practice (RFC 9700)](https://datatracker.ietf.org/doc/html/rfc9700)
