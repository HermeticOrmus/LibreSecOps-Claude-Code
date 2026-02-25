# Secure Auth Patterns

> Authentication, session management, and access control implementation patterns with language-specific secure code examples.

## Knowledge Base

### Password Storage

Never store passwords in plaintext, encrypted form, or with weak hashes (MD5, SHA-1, unsalted SHA-256). Use adaptive hashing algorithms designed for password storage.

**Algorithm selection** (OWASP 2023 recommendations):

| Algorithm | Recommended Parameters | Notes |
|-----------|----------------------|-------|
| Argon2id | Memory: 19456 KB, Iterations: 2, Parallelism: 1 | Preferred. Memory-hard, GPU-resistant |
| bcrypt | Cost factor: 12+ | Widely supported, 72-byte input limit |
| scrypt | N: 2^17, r: 8, p: 1 | Memory-hard, less common than Argon2 |
| PBKDF2-SHA256 | 600,000 iterations | Only if above are unavailable (FIPS) |

**Implementation examples**:

```python
# Python - Argon2 (preferred)
from argon2 import PasswordHasher
ph = PasswordHasher(time_cost=2, memory_cost=19456, parallelism=1)
hash = ph.hash(password)
# Verify
try:
    ph.verify(hash, password)
    if ph.check_needs_rehash(hash):  # Upgrade params over time
        new_hash = ph.hash(password)
except VerifyMismatchError:
    # Invalid password

# Python - bcrypt
import bcrypt
hash = bcrypt.hashpw(password.encode(), bcrypt.gensalt(rounds=12))
if bcrypt.checkpw(password.encode(), hash):
    # Valid
```

```javascript
// Node.js - bcrypt
const bcrypt = require('bcrypt');
const hash = await bcrypt.hash(password, 12);
const valid = await bcrypt.compare(password, hash);

// Node.js - Argon2
const argon2 = require('argon2');
const hash = await argon2.hash(password, {
  type: argon2.argon2id,
  memoryCost: 19456,
  timeCost: 2,
  parallelism: 1
});
const valid = await argon2.verify(hash, password);
```

```go
// Go - bcrypt
import "golang.org/x/crypto/bcrypt"
hash, err := bcrypt.GenerateFromPassword([]byte(password), 12)
err = bcrypt.CompareHashAndPassword(hash, []byte(password))

// Go - Argon2
import "golang.org/x/crypto/argon2"
salt := make([]byte, 16)
rand.Read(salt)
hash := argon2.IDKey([]byte(password), salt, 2, 19456, 1, 32)
```

```java
// Java - bcrypt (jBCrypt)
String hash = BCrypt.hashpw(password, BCrypt.gensalt(12));
boolean valid = BCrypt.checkpw(password, hash);

// Java - Argon2 (argon2-jvm)
Argon2 argon2 = Argon2Factory.create(Argon2Factory.Argon2Types.ARGON2id);
String hash = argon2.hash(2, 19456, 1, password.toCharArray());
boolean valid = argon2.verify(hash, password.toCharArray());
```

### Session Management

**Session token requirements**:
- Minimum 128 bits of entropy from a CSPRNG
- Transmitted only over HTTPS
- Cookie attributes: `Secure`, `HttpOnly`, `SameSite=Strict` (or `Lax`)
- Server-side session storage (not just a signed cookie containing all session data)
- Regenerate session ID on privilege level change (login, role change)
- Absolute timeout (max session lifetime) and idle timeout

**Cookie configuration**:
```
Set-Cookie: session=<token>; Secure; HttpOnly; SameSite=Strict; Path=/; Max-Age=3600
```

**Session lifecycle**:
1. **Creation**: Generate new session ID after successful authentication. Invalidate any pre-authentication session.
2. **Validation**: Check session exists, is not expired, belongs to the authenticated user, and has not been revoked.
3. **Renewal**: Regenerate session ID on privilege changes. Maintain session data but change the identifier.
4. **Termination**: Invalidate session server-side on logout. Clear the cookie client-side. Provide "logout everywhere" capability.

### JWT Security

JWTs are frequently misimplemented. Key requirements:

**Algorithm enforcement**:
```javascript
// VULNERABLE - Accepts any algorithm
jwt.verify(token, secret);

// SECURE - Explicitly specify allowed algorithms
jwt.verify(token, secret, { algorithms: ['HS256'] });

// For RS256 (asymmetric)
jwt.verify(token, publicKey, { algorithms: ['RS256'] });
```

**Critical claims to validate**:
- `exp` (expiration) -- always set, always check
- `iss` (issuer) -- verify against expected value
- `aud` (audience) -- verify the token is intended for this service
- `iat` (issued at) -- reject tokens issued in the future
- `nbf` (not before) -- reject tokens not yet valid

**JWT pitfalls**:
- Algorithm confusion: RS256 public key used as HS256 secret
- `alg: "none"` -- some libraries accept unsigned tokens
- Storing sensitive data in payload (JWT payload is base64, not encrypted)
- No revocation mechanism without additional infrastructure (token blacklist)
- Overly long expiration times

### Multi-Factor Authentication (MFA)

**TOTP implementation requirements** (RFC 6238):
- Secret: 160+ bits, generated server-side
- Time step: 30 seconds
- Allow clock skew: +/- 1 time step
- Rate limit verification attempts (prevent brute force)
- Provide backup codes (one-time use, stored hashed)
- Validate TOTP token before enabling MFA (user proves they set up authenticator correctly)

**MFA bypass prevention**:
- Do not issue session tokens until MFA is verified
- Do not reveal whether username/password was correct before MFA
- Implement step-up authentication for sensitive operations even within authenticated sessions
- Log MFA failures for anomaly detection

### Access Control (Authorization)

**Principles**:
- Deny by default: If no rule explicitly grants access, deny
- Check on every request: Do not rely on UI hiding features
- Server-side enforcement: Client-side checks are supplementary
- Resource-level checks: Verify the user can access THIS specific resource, not just this type of resource

**IDOR prevention**:
```python
# VULNERABLE - No ownership check
@app.route('/api/documents/<doc_id>')
def get_document(doc_id):
    return Document.query.get(doc_id)

# SECURE - Ownership verification
@app.route('/api/documents/<doc_id>')
@login_required
def get_document(doc_id):
    doc = Document.query.filter_by(
        id=doc_id,
        owner_id=current_user.id  # Scoped to user
    ).first_or_404()
    return doc
```

**Role-based access control (RBAC) pattern**:
```python
# Decorator-based authorization
def requires_role(role):
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            if not current_user.has_role(role):
                abort(403)
            return f(*args, **kwargs)
        return wrapper
    return decorator

@app.route('/admin/users')
@login_required
@requires_role('admin')
def manage_users():
    ...
```

### CSRF Protection

**Token-based CSRF protection**:
- Generate a cryptographically random token per session
- Include in forms as a hidden field and validate on every state-changing request
- Use `SameSite=Strict` or `SameSite=Lax` cookies as defense-in-depth
- For APIs: Use custom request headers (e.g., `X-CSRF-Token`) that cannot be set by cross-origin requests

**Framework CSRF protection** (use it, do not disable it):
- Django: `{% csrf_token %}` in forms, `@csrf_protect` decorator
- Rails: `protect_from_forgery with: :exception`
- Spring: `CsrfFilter` (enabled by default in Spring Security)
- Express: `csurf` middleware (or custom double-submit cookie)

## Patterns

### Pattern: Authentication Service Isolation
Centralize authentication logic in a single service/module. All authentication decisions flow through this module. This prevents inconsistent authentication checks across endpoints and makes auditing straightforward.

### Pattern: Fail-Secure Authentication
On any error during authentication (database timeout, MFA service unavailable, token parsing failure), deny access. Never let an exception propagate to an implicit "allow."

### Pattern: Constant-Time Comparison
Use constant-time comparison for all security-sensitive string comparisons (tokens, hashes, API keys) to prevent timing attacks.
```python
import hmac
hmac.compare_digest(provided_token, stored_token)
```
```javascript
const crypto = require('crypto');
crypto.timingSafeEqual(Buffer.from(a), Buffer.from(b));
```

### Pattern: Account Lockout with Progressive Delay
After N failed attempts, implement progressive delays rather than permanent lockout (which enables denial of service). Combine with CAPTCHA and IP-based rate limiting.

## Anti-Patterns

- **Rolling your own auth**: Writing custom password hashing, session management, or token generation instead of using established libraries and frameworks
- **Plaintext password logging**: Logging authentication attempts with the password included, even in "debug" mode
- **Client-side authorization**: Hiding UI elements but not enforcing access control server-side. Attackers do not use your UI
- **Sequential/predictable session IDs**: Using auto-incrementing integers, timestamps, or low-entropy values as session tokens
- **Password length limits**: Capping password length at 8-20 characters. Allow at least 128 characters (bcrypt's 72-byte limit is handled by pre-hashing with SHA-256)
- **Security questions as authentication factors**: "Mother's maiden name" is knowledge, not a factor. It is publicly discoverable and not resettable
- **JWT for sessions**: JWTs as session tokens add complexity (no server-side revocation) without clear benefit for most applications. Server-side sessions with opaque tokens are simpler and more secure
- **Shared secrets across services**: Each service should have its own API key/secret. Compromising one service should not compromise all

## References

- OWASP Authentication Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html
- OWASP Session Management Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html
- OWASP Password Storage Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
- OWASP CSRF Prevention Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Request_Forgery_Prevention_Cheat_Sheet.html
- OWASP JWT Security Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/JSON_Web_Token_for_Java_Cheat_Sheet.html
- NIST SP 800-63B: Digital Identity Guidelines (Authentication) -- https://pages.nist.gov/800-63-3/sp800-63b.html
- RFC 6238: TOTP Algorithm -- https://tools.ietf.org/html/rfc6238
- CWE-287: Improper Authentication -- https://cwe.mitre.org/data/definitions/287.html
- CWE-284: Improper Access Control -- https://cwe.mitre.org/data/definitions/284.html
