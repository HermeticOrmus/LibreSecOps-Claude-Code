# OWASP Top 10 (2021)

> Comprehensive knowledge base covering all ten OWASP categories with vulnerability patterns, detection techniques, code examples, and framework-specific mitigations.

## Knowledge Base

### A01:2021 - Broken Access Control

Moved from #5 to #1. 94% of applications tested had some form of broken access control. This category covers failures in enforcing that users cannot act outside their intended permissions.

**Vulnerability Patterns**:
- **IDOR (Insecure Direct Object Reference)**: Accessing resources by manipulating identifiers. `GET /api/users/1234/profile` where changing `1234` to `1235` returns another user's data without ownership check.
- **Missing function-level access control**: Admin endpoints accessible to regular users. No middleware/decorator enforcing role checks on sensitive routes.
- **Path traversal**: `GET /files?name=../../../etc/passwd` -- file operations using user-supplied paths without canonicalization and validation.
- **CORS misconfiguration**: `Access-Control-Allow-Origin: *` with `Access-Control-Allow-Credentials: true`, or reflecting the `Origin` header without validation.
- **JWT manipulation**: Changing `alg` to `none`, substituting HMAC for RSA keys, modifying claims without signature verification.
- **Forced browsing**: Accessing admin pages, backup files, or API documentation that isn't linked but exists on the server.

**Detection in Code**:
```python
# VULNERABLE: No ownership check
@app.route('/api/orders/<order_id>')
def get_order(order_id):
    return Order.query.get(order_id).to_json()

# FIXED: Verify the order belongs to the current user
@app.route('/api/orders/<order_id>')
@login_required
def get_order(order_id):
    order = Order.query.get_or_404(order_id)
    if order.user_id != current_user.id:
        abort(403)
    return order.to_json()
```

### A02:2021 - Cryptographic Failures

Previously "Sensitive Data Exposure." Focuses on failures related to cryptography that lead to exposure of sensitive data.

**Vulnerability Patterns**:
- **Cleartext transmission**: HTTP for login pages, API tokens in URL parameters, sensitive data in unencrypted WebSocket connections
- **Weak hashing**: MD5 or SHA-1 for passwords. Using hashing without salt. Using fast hashes instead of bcrypt/scrypt/argon2id.
- **Hardcoded secrets**: API keys, database passwords, JWT signing keys committed to source code or configuration files
- **Weak random number generation**: Using `Math.random()`, `random.random()`, or `rand()` for security-sensitive values (tokens, nonces, keys)
- **Insufficient key length**: RSA < 2048 bits, AES < 128 bits, ECDSA < 256 bits
- **ECB mode**: Using AES-ECB which preserves plaintext patterns
- **Missing certificate validation**: `verify=False` in HTTP clients, `NODE_TLS_REJECT_UNAUTHORIZED=0`, `rejectUnauthorized: false`

**Detection in Code**:
```javascript
// VULNERABLE: Weak password hashing
const hash = crypto.createHash('md5').update(password).digest('hex');

// FIXED: Use bcrypt with appropriate cost factor
const hash = await bcrypt.hash(password, 12);
```

### A03:2021 - Injection

Injection flaws occur when untrusted data is sent to an interpreter as part of a command or query.

**Vulnerability Patterns**:
- **SQL Injection**: String concatenation in SQL queries. Format strings with user input. Stored procedures called with unparameterized input.
- **NoSQL Injection**: MongoDB `$where`, `$gt`, `$ne` operators from parsed JSON input. `{"username": {"$ne": ""}, "password": {"$ne": ""}}` bypasses authentication.
- **OS Command Injection**: `os.system('ping ' + user_input)`, `exec('nslookup ' + domain)`, backtick interpolation with user data.
- **SSTI (Server-Side Template Injection)**: User input rendered as template code. Jinja2: `{{7*7}}` produces `49`. Freemarker: `<#assign ex="freemarker.template.utility.Execute"?new()>${ex("id")}`.
- **LDAP Injection**: `(&(uid=` + username + `)(password=` + password + `))` allows `*)(uid=*))(|(uid=*` to bypass authentication.
- **XPath Injection**: Similar to SQL injection but against XML data stores.

**Detection in Code**:
```python
# VULNERABLE: SQL injection via string formatting
cursor.execute(f"SELECT * FROM users WHERE username = '{username}'")

# FIXED: Parameterized query
cursor.execute("SELECT * FROM users WHERE username = %s", (username,))
```

### A04:2021 - Insecure Design

A new category in 2021. Focuses on risks related to design and architectural flaws. Cannot be fixed by perfect implementation -- the design itself is flawed.

**Vulnerability Patterns**:
- **Missing rate limiting**: No throttling on login, registration, password reset, or OTP verification allows brute force attacks
- **Unlimited resource consumption**: File upload without size limits, API endpoints returning unbounded result sets, recursive operations without depth limits
- **Missing fraud controls**: No velocity checks on financial transactions, no anomaly detection on account changes
- **Insecure password recovery**: Security questions with guessable answers, password reset links that don't expire, reset tokens sent to unverified email
- **Trust boundary confusion**: Client-side validation relied upon without server-side enforcement. Mobile app business logic enforced only in the client.

### A05:2021 - Security Misconfiguration

The most commonly seen issue. Often a result of insecure default configurations, incomplete configurations, or ad hoc configurations.

**Vulnerability Patterns**:
- **Debug mode in production**: `DEBUG=True` in Django, `FLASK_DEBUG=1`, Spring Boot Actuator endpoints exposed, Node.js `--inspect` flag
- **Default credentials**: Database servers, admin panels, API management consoles, message brokers left with factory defaults
- **Unnecessary services**: Open ports, enabled but unused features, sample applications deployed to production
- **Missing security headers**: No `Content-Security-Policy`, `Strict-Transport-Security`, `X-Content-Type-Options`, `X-Frame-Options`
- **Permissive cloud IAM**: S3 buckets with public access, overly broad IAM roles, missing resource policies
- **Verbose error messages**: Stack traces, SQL errors, internal paths exposed to end users

**Detection in Code**:
```python
# VULNERABLE: Django settings.py
DEBUG = True
ALLOWED_HOSTS = ['*']
SECRET_KEY = 'django-insecure-abc123'

# FIXED:
DEBUG = False
ALLOWED_HOSTS = ['myapp.example.com']
SECRET_KEY = os.environ['DJANGO_SECRET_KEY']
```

### A06:2021 - Vulnerable and Outdated Components

Using components with known vulnerabilities. The challenge is knowing what you use and whether it's vulnerable.

**Vulnerability Patterns**:
- **Outdated dependencies**: Not updating packages with known CVEs. Using `lodash` < 4.17.21 (prototype pollution), `log4j` < 2.17.1 (RCE), `jackson-databind` with polymorphic deserialization
- **Unmaintained packages**: Dependencies with no updates for 2+ years, archived repositories, single-maintainer projects
- **Transitive dependencies**: Vulnerable packages pulled in as dependencies of dependencies. Not visible in top-level manifest but present in lock files.
- **Missing lock files**: `package-lock.json`, `yarn.lock`, `Pipfile.lock`, `Gemfile.lock` not committed, allowing version drift

### A07:2021 - Identification and Authentication Failures

Previously "Broken Authentication." Covers failures in confirming user identity, authentication, and session management.

**Vulnerability Patterns**:
- **Credential stuffing susceptibility**: No rate limiting, no account lockout, no CAPTCHA, no breach password checking
- **Weak password policy**: Allowing common passwords, no minimum length, no complexity requirements (or overly rigid ones that drive users to patterns)
- **Session fixation**: Session ID not rotated after authentication. Attacker sets session ID via URL parameter or cookie before victim authenticates.
- **Session token in URL**: `jsessionid` in URL, token in query parameters -- leaks via Referer header, browser history, logs
- **Missing session invalidation**: Logout doesn't destroy server-side session. Password change doesn't invalidate existing sessions.
- **Predictable tokens**: Sequential session IDs, timestamps as tokens, insufficient entropy in random generation

**Detection in Code**:
```javascript
// VULNERABLE: Session not rotated after login
app.post('/login', (req, res) => {
  if (validCredentials(req.body)) {
    req.session.user = req.body.username;  // Same session ID
    res.redirect('/dashboard');
  }
});

// FIXED: Regenerate session after authentication
app.post('/login', (req, res) => {
  if (validCredentials(req.body)) {
    req.session.regenerate((err) => {
      req.session.user = req.body.username;
      res.redirect('/dashboard');
    });
  }
});
```

### A08:2021 - Software and Data Integrity Failures

New category focusing on assumptions about software updates, critical data, and CI/CD pipelines without verifying integrity.

**Vulnerability Patterns**:
- **Insecure deserialization**: `pickle.loads(user_data)` in Python, `unserialize()` in PHP, Java `ObjectInputStream` from untrusted sources, YAML `load()` vs `safe_load()`
- **Unsigned updates**: Auto-update mechanisms that don't verify code signatures. Package managers without integrity checking.
- **CI/CD pipeline poisoning**: Pull request workflows that execute untrusted code, secrets exposed in build logs, compromised build dependencies
- **Missing Subresource Integrity (SRI)**: Loading JavaScript from CDNs without `integrity` attributes

### A09:2021 - Security Logging and Monitoring Failures

Insufficient logging, detection, monitoring, and active response. Without logging, breaches cannot be detected.

**Vulnerability Patterns**:
- **Missing audit events**: No logging of login attempts (success/failure), access control decisions, input validation failures, application errors
- **Log injection**: User input written to logs without sanitization. Attacker injects fake log entries or CRLF sequences.
- **Sensitive data in logs**: Passwords, tokens, credit card numbers, PII written to log files
- **No alerting**: Logs exist but nobody monitors them. No automated alerts for suspicious patterns.
- **Insufficient retention**: Logs deleted before forensic investigation can use them

### A10:2021 - Server-Side Request Forgery (SSRF)

New category. Occurs when a web application fetches a remote resource without validating the user-supplied URL.

**Vulnerability Patterns**:
- **Direct SSRF**: `GET /api/fetch?url=http://169.254.169.254/latest/meta-data/` -- accessing cloud metadata endpoints through the application
- **Blind SSRF**: Application makes the request but doesn't return the response. Detected via out-of-band techniques (DNS lookups, time delays)
- **SSRF via URL parsers**: Exploiting parser inconsistencies (`http://evil.com#@expected.com`, `http://127.0.0.1:80\@expected.com`, URL with Unicode characters)
- **DNS rebinding**: URL validation passes against a legitimate domain, but DNS re-resolves to an internal IP between validation and request
- **Protocol smuggling**: Using non-HTTP protocols via SSRF (`gopher://`, `file://`, `dict://`) to interact with internal services

**Detection in Code**:
```python
# VULNERABLE: Unvalidated URL fetch
@app.route('/preview')
def preview():
    url = request.args.get('url')
    response = requests.get(url)
    return response.text

# FIXED: URL validation with allowlist
@app.route('/preview')
def preview():
    url = request.args.get('url')
    parsed = urlparse(url)
    if parsed.scheme not in ('http', 'https'):
        abort(400)
    if not is_allowed_host(parsed.hostname):
        abort(403)
    # Also: resolve DNS and check against internal ranges before fetching
    ip = socket.getaddrinfo(parsed.hostname, None)[0][4][0]
    if ipaddress.ip_address(ip).is_private:
        abort(403)
    response = requests.get(url, allow_redirects=False)
    return response.text
```

## Patterns

### Universal Defense Patterns

1. **Input validation**: Validate all input against expected format, length, type, and range. Use allowlists over denylists.
2. **Output encoding**: Encode output based on the context (HTML, JS, URL, CSS, SQL). Never assume one encoding works for all contexts.
3. **Parameterized queries**: Use prepared statements or ORM query builders for all database interaction. Never concatenate user input into queries.
4. **Principle of least privilege**: Every component operates with minimum required permissions. Database accounts, API keys, file system access.
5. **Defense in depth**: Layer security controls. Don't rely on a single point of enforcement.
6. **Fail secure**: Errors should deny access, not grant it. `if (!authorized) deny` is safer than `if (authorized) allow`.
7. **Security by default**: Secure configuration should be the default. Developers should have to opt out of security, not opt in.

### Framework Security Checklists

**Node.js/Express**: `helmet` for headers, `express-rate-limit`, `csurf` or token-based CSRF, `express-validator`, `hpp` for HTTP parameter pollution, disable `x-powered-by`.

**Python/Django**: `SECURE_SSL_REDIRECT`, `CSRF_COOKIE_HTTPONLY`, `SESSION_COOKIE_SECURE`, `SECURE_HSTS_SECONDS`, `SECURE_CONTENT_TYPE_NOSNIFF`, run `python manage.py check --deploy`.

**Ruby on Rails**: `config.force_ssl`, `protect_from_forgery`, `config.filter_parameters`, strong parameters, `config.action_dispatch.default_headers`.

**Java/Spring**: Spring Security configuration (CSRF, CORS, headers, session management), `@PreAuthorize` annotations, `@Validated` on controllers.

## Anti-Patterns

- **Denylisting dangerous input**: Trying to filter specific attack strings (`<script>`, `DROP TABLE`). Attackers have unlimited bypass variations. Use allowlisting and parameterization instead.
- **Client-side-only validation**: All client-side checks must be replicated server-side. The client is in the attacker's control.
- **Security through obscurity**: Unlinked admin pages, non-standard ports, custom encoding. These delay attackers by minutes, not prevent them.
- **Rolling your own crypto**: Custom encryption, hashing, or token generation. Use established libraries (libsodium, bcrypt, platform-native secure random).
- **Encoding for the wrong context**: Using HTML encoding in a JavaScript context, or URL encoding in an HTML attribute. Each context needs its specific encoder.
- **Catching and swallowing exceptions**: `catch (e) {}` hides errors that could indicate attacks. Log security-relevant exceptions with context.
- **Trusting internal network**: Internal services should still authenticate and authorize. Zero trust applies behind the firewall too.

## References

- [OWASP Top 10 2021](https://owasp.org/Top10/)
- [OWASP Testing Guide v4.2](https://owasp.org/www-project-web-security-testing-guide/)
- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/)
- [CWE/SANS Top 25 Most Dangerous Software Weaknesses](https://cwe.mitre.org/top25/)
- [PortSwigger Web Security Academy](https://portswigger.net/web-security)
- [NIST SP 800-53 Security Controls](https://csf.tools/reference/nist-sp-800-53/)
