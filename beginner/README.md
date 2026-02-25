# Beginner: Secure Coding with Claude Code

> Security is risk management, not paranoia. The goal is not to eliminate all risk -- that is impossible -- but to understand what you are protecting, from whom, and to make informed decisions about the tradeoffs.

---

## Table of Contents

1. [The Security Mindset](#the-security-mindset)
2. [OWASP Top 10 in Plain English](#owasp-top-10-in-plain-english)
3. [Three Rules of Security Prompting](#three-rules-of-security-prompting)
4. [Common Vulnerability Patterns Claude Introduces](#common-vulnerability-patterns-claude-introduces)
5. [Quick Reference: Secure Patterns](#quick-reference-secure-patterns)
6. [Practice Exercises](#practice-exercises)
7. [Pre-Request Checklist](#pre-request-checklist)
8. [Security Vocabulary](#security-vocabulary)

---

## The Security Mindset

Every piece of software has two audiences: legitimate users and adversaries. The security mindset means considering both simultaneously.

**Think like an attacker**: For every feature, ask: "How could this be abused?" If your login form accepts a username, an attacker will send SQL. If your API returns error details, an attacker will use them to map your backend. If your file upload accepts any type, an attacker will upload a shell.

**Build like a defender**: Accept that attacks will come. Design so that when a single control fails, the system does not collapse. This is defense in depth -- multiple independent layers, each sufficient to prevent catastrophe on its own.

**Applied to Claude Code**: When you ask Claude to generate code, it optimizes for functionality by default. It will produce working code. But "working" and "secure" are different properties. You must explicitly request security, specify your threat model, and verify the output against known vulnerability patterns.

### The Attacker's Advantage

Defenders must protect every entry point. Attackers only need to find one. This asymmetry means:

- Default-deny is always safer than default-allow
- Allowlists beat blocklists (you cannot enumerate everything that is dangerous)
- Fail closed: when uncertain, reject the request
- Minimize attack surface: every feature, endpoint, and dependency is a potential entry point

---

## OWASP Top 10 in Plain English

The OWASP Top 10 is a consensus list of the most critical web application security risks. Here is each one with a Claude Code example showing both the vulnerable and secure approach.

### A01: Broken Access Control

**What it means**: Users can act outside their intended permissions. View another user's data, modify someone else's records, escalate to admin.

**Claude Code example -- the vulnerable way**:

```
Prompt: "Write an endpoint to get user profile by ID"
```

Claude generates:

```javascript
app.get('/api/users/:id', async (req, res) => {
  const user = await User.findById(req.params.id);
  res.json(user);
});
```

Anyone can view any user's profile by changing the ID.

**The secure way**:

```
Prompt: "Write an endpoint to get user profile by ID. Enforce that
authenticated users can only access their own profile unless they have
admin role. Use middleware for auth. Return 403 for unauthorized access."
```

### A02: Cryptographic Failures

**What it means**: Sensitive data exposed through weak or missing encryption. Passwords stored in plaintext, data transmitted over HTTP, weak hashing algorithms.

**Key rule for Claude Code**: Never ask Claude to implement custom cryptography. Always specify: "Use bcrypt for password hashing," "Use TLS for data in transit," "Use AES-256-GCM for data at rest." Name the specific algorithm. If you say "encrypt this," Claude may choose something outdated.

### A03: Injection

**What it means**: Untrusted data is sent to an interpreter as part of a command or query. SQL injection, command injection, LDAP injection, XSS.

**Claude Code pattern**: If your prompt says "build a search feature," Claude will often concatenate user input directly into queries. Always specify: "Use parameterized queries" or "Use the ORM's built-in query builder."

### A04: Insecure Design

**What it means**: The architecture itself is flawed, not just the implementation. No amount of perfect code fixes a design that lacks rate limiting on password reset, or stores sessions client-side without integrity checks.

**Claude Code approach**: Before asking Claude to implement, ask it to review the design. "What are the security risks in this architecture?" is a powerful prompt.

### A05: Security Misconfiguration

**What it means**: Default credentials, unnecessary features enabled, overly permissive CORS, verbose error messages in production, missing security headers.

**Claude Code pattern**: Claude often generates development-friendly configurations. Debug mode on. CORS allowing all origins. Detailed stack traces in error responses. Always specify the target environment: "Generate production configuration with security headers."

### A06: Vulnerable and Outdated Components

**What it means**: Using libraries with known vulnerabilities. A single outdated dependency can compromise an entire application.

**Claude Code approach**: After Claude suggests dependencies, audit them. Ask: "Check if any of these dependencies have known CVEs" or run `npm audit` / `pip-audit` on the generated code.

### A07: Identification and Authentication Failures

**What it means**: Weak passwords allowed, no brute-force protection, session tokens in URLs, no MFA option.

**Claude Code pattern**: When asking Claude to build auth, be exhaustive: "Implement login with bcrypt password hashing, rate limiting (5 attempts per 15 minutes), secure session management (HttpOnly, Secure, SameSite cookies), and account lockout after 10 failed attempts."

### A08: Software and Data Integrity Failures

**What it means**: Code and infrastructure that does not verify integrity. Unsigned updates, CI/CD pipelines without integrity checks, deserialization of untrusted data.

**Claude Code approach**: When building CI/CD or update mechanisms, specify: "Verify checksums," "Pin dependency versions," "Use signed commits."

### A09: Security Logging and Monitoring Failures

**What it means**: Breaches go undetected because nobody is watching. No logs, insufficient logs, or logs that are never reviewed.

**Claude Code prompt pattern**: "Add structured logging for all authentication events, access control failures, and input validation failures. Log enough to reconstruct what happened but never log passwords, tokens, or PII."

### A10: Server-Side Request Forgery (SSRF)

**What it means**: The application fetches a URL that the attacker controls, allowing them to reach internal services, cloud metadata endpoints, or other protected resources.

**Claude Code pattern**: Any time your code fetches a URL from user input, specify: "Validate the URL against an allowlist of permitted domains. Block requests to private IP ranges (10.x, 172.16-31.x, 192.168.x, 169.254.x). Do not follow redirects to internal addresses."

---

## Three Rules of Security Prompting

### Rule 1: Be Specific About Your Threat Model

A threat model answers: What are you protecting? From whom? What are the consequences of failure?

**Vague** (produces insecure code):

```
"Build a user registration system"
```

**Specific** (produces defensible code):

```
"Build a user registration system for a healthcare SaaS application.
Threat model: external attackers attempting credential stuffing,
internal users who should not access other patients' records, and
compliance with HIPAA requirements for PHI protection. Use bcrypt
with cost factor 12, enforce passwords minimum 12 characters with
zxcvbn strength checking, implement email verification, and log
all registration events without storing PII in logs."
```

### Rule 2: Specify Compliance Requirements

Compliance frameworks encode hard-won security lessons. Reference them explicitly.

```
"This API handles payment card data. Follow PCI-DSS requirements:
never log full card numbers, mask to last 4 digits in any display,
encrypt at rest with AES-256, transmit only over TLS 1.2+, and
implement access logging for all cardholder data access."
```

### Rule 3: Reference Known Vulnerabilities

If you know about a specific vulnerability class, name it. Claude's security output improves dramatically when you reference CWE numbers or specific attack techniques.

```
"Implement file upload handling. Mitigate: CWE-434 (unrestricted
file upload) by validating MIME type AND file magic bytes, CWE-22
(path traversal) by generating random filenames and never using
user-supplied paths, and CWE-400 (resource exhaustion) by enforcing
a 5MB size limit with streaming validation."
```

---

## Common Vulnerability Patterns Claude Introduces

These are patterns that Claude Code generates frequently when security is not explicitly requested. Learn to recognize them.

### SQL Injection via String Concatenation

```javascript
// Claude often generates this when you say "search users"
const query = `SELECT * FROM users WHERE name LIKE '%${searchTerm}%'`;

// What you should get
const query = `SELECT * FROM users WHERE name LIKE $1`;
const params = [`%${searchTerm}%`];
```

### XSS via Unescaped Output

```javascript
// Claude generates this for "display user comments"
element.innerHTML = comment.body;

// What you should get
element.textContent = comment.body;
// Or use a sanitization library like DOMPurify if HTML is needed
element.innerHTML = DOMPurify.sanitize(comment.body);
```

### Hardcoded Secrets

```python
# Claude does this when you say "connect to the database"
db_url = "postgresql://admin:secretpass@db.example.com/mydb"
api_key = "sk-1234567890abcdef"

# What you should get
db_url = os.environ["DATABASE_URL"]
api_key = os.environ["API_KEY"]
```

### Overly Permissive CORS

```javascript
// Claude's default for "enable CORS"
app.use(cors()); // Allows ALL origins

// What you should get
app.use(cors({
  origin: ['https://app.example.com'],
  methods: ['GET', 'POST'],
  credentials: true
}));
```

### Missing Rate Limiting

Claude rarely adds rate limiting unless asked. Every public endpoint -- especially authentication, registration, and password reset -- needs it.

### Verbose Error Messages

```javascript
// Claude generates helpful errors... for attackers
catch (error) {
  res.status(500).json({ error: error.message, stack: error.stack });
}

// What you should get
catch (error) {
  logger.error('Operation failed', { error: error.message, requestId });
  res.status(500).json({ error: 'Internal server error', requestId });
}
```

---

## Quick Reference: Secure Patterns

### Input Validation

```javascript
// Validate type, length, format, and range
// Use allowlists, not blocklists
const schema = Joi.object({
  username: Joi.string().alphanum().min(3).max(30).required(),
  email: Joi.string().email().required(),
  age: Joi.number().integer().min(13).max(120)
});

const { error, value } = schema.validate(req.body);
if (error) {
  return res.status(400).json({ error: 'Invalid input' });
  // Do NOT return: error.details (leaks validation schema)
}
```

### Output Encoding

```javascript
// Context-dependent encoding
// HTML context: escape < > & " '
// URL context: encodeURIComponent()
// JavaScript context: JSON.stringify()
// CSS context: escape or use allowlist

// Use template engines with auto-escaping enabled (Handlebars, Jinja2, EJS with <%=)
// Never use unescaped output (<%- in EJS, |safe in Jinja2) with user data
```

### Authentication

```javascript
// Password hashing: bcrypt with cost factor >= 12
const hash = await bcrypt.hash(password, 12);

// Session management: server-side sessions with secure cookies
app.use(session({
  secret: process.env.SESSION_SECRET,
  cookie: {
    httpOnly: true,     // Blocks JavaScript access
    secure: true,       // HTTPS only
    sameSite: 'strict', // CSRF protection
    maxAge: 3600000     // 1 hour
  },
  resave: false,
  saveUninitialized: false
}));
```

---

## Practice Exercises

### Exercise 1: Fix the Insecure Login Form

This login handler has multiple vulnerabilities. Identify and fix them.

```javascript
app.post('/login', async (req, res) => {
  const { username, password } = req.body;
  const user = await db.query(
    `SELECT * FROM users WHERE username = '${username}'`
  );
  if (user && user.password === password) {
    req.session.userId = user.id;
    res.json({ message: 'Login successful', user: user });
  } else {
    res.json({ message: `Invalid password for user ${username}` });
  }
});
```

**Vulnerabilities to find**: SQL injection, plaintext password comparison, full user object in response (may include password hash), error message reveals whether username exists (user enumeration), no rate limiting, no input validation, no CSRF protection.

### Exercise 2: Spot the Vulnerability

```python
import yaml
import subprocess

def process_config(user_input):
    config = yaml.load(user_input)  # What's wrong here?
    if config.get('backup'):
        subprocess.call(f"tar -czf backup.tar.gz {config['path']}")  # And here?
    return config
```

**Vulnerabilities**: `yaml.load()` without `Loader=SafeLoader` allows arbitrary code execution via YAML deserialization. `subprocess.call()` with string formatting allows command injection. Use `yaml.safe_load()` and `subprocess.call(['tar', '-czf', 'backup.tar.gz', config['path']])` with list arguments.

### Exercise 3: Write a Secure API Endpoint

Using Claude Code, write a `POST /api/notes` endpoint that:

- Requires authentication (JWT)
- Validates input (title: string 1-200 chars, body: string 1-10000 chars)
- Stores in a database using parameterized queries
- Returns only the fields the client needs
- Logs the creation event without PII
- Handles errors without leaking internals
- Includes rate limiting (30 requests per minute per user)

Use the prompt template in `prompts/secure-api-endpoint.md` as your starting point.

---

## Pre-Request Checklist

Before asking Claude Code to write security-sensitive code, verify:

See `checklist.md` for the full pre-request security checklist.

Quick version:

- [ ] Have I specified the threat model?
- [ ] Have I named specific algorithms and protocols (not just "encrypt it")?
- [ ] Have I requested input validation with specific rules?
- [ ] Have I specified error handling that does not leak internals?
- [ ] Have I requested logging without PII?
- [ ] Have I specified the target environment (development vs. production)?
- [ ] Have I asked for rate limiting on public endpoints?
- [ ] Have I specified authentication and authorization requirements?

---

## Security Vocabulary

See `security-vocabulary.md` for a comprehensive glossary of security terms including CVE, CWE, CVSS, STRIDE, OWASP, SAST, DAST, and more.

Quick essentials:

| Term | Meaning |
|------|---------|
| **CVE** | A specific, cataloged vulnerability (e.g., CVE-2021-44228 is Log4Shell) |
| **CWE** | A category of vulnerability (e.g., CWE-89 is SQL Injection) |
| **OWASP** | The organization maintaining the Top 10 and security tooling |
| **Threat Model** | Analysis of what you protect, from whom, and how |
| **Attack Surface** | Every point where an attacker can interact with your system |
| **Defense in Depth** | Multiple independent security layers |

---

## Next Steps

Once you are comfortable with these fundamentals:

1. Complete all three practice exercises
2. Use the `checklist.md` for your next five Claude Code security requests
3. Read the `prompts/secure-api-endpoint.md` to see what a thorough security prompt looks like
4. Move to `../intermediate/` for systematic security workflows

---

*Part of [LibreSecOps-Claude-Code](https://github.com/hermeticormus/LibreSecOps-Claude-Code) -- MIT License*
