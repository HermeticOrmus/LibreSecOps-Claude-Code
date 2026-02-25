# Injection Prevention

> Comprehensive injection prevention patterns for SQL, XSS, command injection, path traversal, LDAP, and template injection across all major languages and frameworks.

## Knowledge Base

### The Fundamental Principle

Injection occurs when untrusted data is interpreted as code or structure by a downstream processor. The universal prevention is to ensure the processor can distinguish data from code. This is achieved through:

1. **Parameterization** -- Sending data through a separate channel from code (prepared statements, argument arrays)
2. **Context-aware encoding** -- Transforming data so it is inert in the target context (HTML encoding, URL encoding)
3. **Allowlist validation** -- Accepting only data that matches a known-safe pattern (enum values, regex matching)

Denylist filtering (blocking known-bad characters) is almost always insufficient because there are too many encoding variations and bypass techniques.

### SQL Injection

**Root cause**: User input concatenated into SQL query strings.

**Prevention by language**:

```python
# VULNERABLE
cursor.execute(f"SELECT * FROM users WHERE name = '{name}'")

# SECURE - Parameterized query
cursor.execute("SELECT * FROM users WHERE name = %s", (name,))

# SECURE - Django ORM (parameterized by default)
User.objects.filter(name=name)

# VULNERABLE - Django raw with string formatting
User.objects.raw(f"SELECT * FROM users WHERE name = '{name}'")

# SECURE - Django raw with params
User.objects.raw("SELECT * FROM users WHERE name = %s", [name])
```

```javascript
// VULNERABLE
db.query(`SELECT * FROM users WHERE name = '${name}'`);

// SECURE - Parameterized (pg library)
db.query('SELECT * FROM users WHERE name = $1', [name]);

// SECURE - Prisma ORM (parameterized by default)
prisma.user.findMany({ where: { name } });

// VULNERABLE - Sequelize literal
sequelize.query(`SELECT * FROM users WHERE name = '${name}'`);

// SECURE - Sequelize parameterized
sequelize.query('SELECT * FROM users WHERE name = :name', {
  replacements: { name }
});
```

```java
// VULNERABLE
Statement stmt = conn.createStatement();
stmt.execute("SELECT * FROM users WHERE name = '" + name + "'");

// SECURE - PreparedStatement
PreparedStatement ps = conn.prepareStatement(
    "SELECT * FROM users WHERE name = ?"
);
ps.setString(1, name);
ResultSet rs = ps.executeQuery();

// SECURE - JPA/Hibernate named parameters
Query q = em.createQuery(
    "SELECT u FROM User u WHERE u.name = :name"
);
q.setParameter("name", name);
```

```go
// VULNERABLE
db.Query("SELECT * FROM users WHERE name = '" + name + "'")

// SECURE - Parameterized
db.Query("SELECT * FROM users WHERE name = $1", name)

// SECURE - GORM (parameterized by default)
db.Where("name = ?", name).Find(&users)
```

**Tricky cases**:
- **ORDER BY**: Cannot be parameterized in most databases. Use allowlist validation: `if column not in ALLOWED_COLUMNS: raise Error`
- **LIKE clauses**: Parameterize the value but escape `%` and `_` within user input: `WHERE name LIKE '%' || $1 || '%'` with `%` and `_` escaped in the parameter
- **IN clauses**: Generate the right number of placeholders: `WHERE id IN ($1, $2, $3)` with one param per value
- **Table/column names**: Cannot be parameterized. Strict allowlist validation required.
- **Second-order injection**: Data stored safely in the database but later retrieved and used in an unsafe query. The fix is to parameterize ALL queries, not just those with direct user input.

### Cross-Site Scripting (XSS)

**Root cause**: Untrusted data rendered in HTML without proper context-aware encoding.

**Context-specific encoding**:

| Context | Encoding | Example |
|---------|----------|---------|
| HTML body | HTML entity encoding | `<` -> `&lt;` |
| HTML attribute | HTML attribute encoding | `"` -> `&quot;` |
| JavaScript | JavaScript encoding | `'` -> `\x27` |
| URL parameter | URL encoding | ` ` -> `%20` |
| CSS | CSS encoding | `(` -> `\28` |

**Framework auto-escaping** (know what your framework does and does not escape):

| Framework | Auto-escapes | Bypass syntax (dangerous) |
|-----------|-------------|---------------------------|
| React JSX | Yes (HTML context) | `dangerouslySetInnerHTML` |
| Angular | Yes (HTML context) | `bypassSecurityTrustHtml()` |
| Vue | Yes (`{{ }}`) | `v-html` directive |
| Django templates | Yes (`{{ }}`) | `|safe` filter, `{% autoescape off %}` |
| Jinja2 | Yes (if configured) | `|safe` filter, `Markup()` |
| Rails ERB | No (`<%= %>`) / Yes (`<%== %>`) | `raw()`, `html_safe` |
| Go html/template | Yes | Using `text/template` instead |

**DOM-based XSS**: The server never sees the payload. It exists entirely in client-side JavaScript.

```javascript
// VULNERABLE - DOM XSS
document.getElementById('output').innerHTML = location.hash.substring(1);

// SECURE - Use textContent for text
document.getElementById('output').textContent = location.hash.substring(1);

// SECURE - Use DOMPurify for HTML that must be rendered
import DOMPurify from 'dompurify';
document.getElementById('output').innerHTML = DOMPurify.sanitize(userHtml);
```

**Content Security Policy** (defense-in-depth):
```
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; object-src 'none'; base-uri 'self'; form-action 'self'; frame-ancestors 'none';
```

### Command Injection

**Root cause**: User input passed to shell interpreters.

**Prevention**: Use argument arrays, never shell strings.

```python
# VULNERABLE
os.system(f"convert {filename} output.png")
subprocess.call(f"convert {filename} output.png", shell=True)

# SECURE - Argument array, no shell
subprocess.run(["convert", filename, "output.png"], shell=False)
```

```javascript
// VULNERABLE
exec(`convert ${filename} output.png`);

// SECURE - execFile with argument array
execFile("convert", [filename, "output.png"]);
```

```go
// VULNERABLE
exec.Command("sh", "-c", "convert " + filename + " output.png")

// SECURE - Direct command with argument array
exec.Command("convert", filename, "output.png")
```

**Additional safeguards**: Validate filename against allowlist pattern (`[a-zA-Z0-9._-]+`), use full path for command (`/usr/bin/convert`), drop privileges if possible.

### Path Traversal

**Root cause**: User input used to construct file paths without canonicalization and boundary checking.

```python
# VULNERABLE
filepath = os.path.join(UPLOAD_DIR, user_filename)
with open(filepath) as f: return f.read()

# SECURE - Canonical path validation
filepath = os.path.join(UPLOAD_DIR, user_filename)
canonical = os.path.realpath(filepath)
if not canonical.startswith(os.path.realpath(UPLOAD_DIR)):
    raise SecurityError("Path traversal attempt")
with open(canonical) as f: return f.read()
```

```go
// SECURE - filepath.Clean + prefix check
cleaned := filepath.Clean(filepath.Join(uploadDir, userFilename))
if !strings.HasPrefix(cleaned, filepath.Clean(uploadDir)) {
    return errors.New("path traversal attempt")
}
```

**Bypass awareness**: `../`, `..%2f`, `..%252f` (double encoding), `....//` (filter bypass), null bytes (`%00` in older systems), symlink following.

### Template Injection (SSTI)

**Root cause**: User input inserted into template code rather than template data.

```python
# VULNERABLE - User input in template string
template = Template(f"Hello {user_input}")
template.render()

# SECURE - User input as template variable
template = Template("Hello {{ name }}")
template.render(name=user_input)
```

If users must provide template-like input, use a sandboxed template engine (Jinja2 SandboxedEnvironment) and validate against dangerous constructs.

## Patterns

### Pattern: Input Validation Layer
Create a validation layer at the application boundary that rejects invalid input before it reaches business logic. Use schema validation libraries (Joi, Zod, Pydantic, marshmallow) with strict type definitions.

### Pattern: Output Encoding Layer
Centralize output encoding in template helpers or middleware rather than relying on individual developers to encode at each output point. Choose frameworks with auto-escaping enabled by default.

### Pattern: Parameterized Everywhere
Use parameterized interfaces for all structured data contexts (SQL, LDAP, XPath), not just the ones you think receive user input. Data flows change; parameterized queries are safe regardless of data source.

## Anti-Patterns

- **Denylist filtering**: Blocking `<script>` does not prevent `<img onerror=>`, `<svg onload=>`, or hundreds of other XSS vectors
- **Escaping for SQL instead of parameterizing**: Manual escaping is error-prone and database-specific. Parameterized queries are universally correct
- **Client-side-only validation**: Any validation in JavaScript can be bypassed by sending requests directly. Server-side validation is mandatory
- **WAF as the sole defense**: WAFs are bypassable. They are a useful layer but not a substitute for secure code
- **Double encoding to "fix" display issues**: If output encoding breaks your display, you are encoding at the wrong layer, not "too much"
- **Stripping instead of rejecting**: Silently removing dangerous characters changes user input in unexpected ways and may be bypassed. Reject invalid input with a clear error

## References

- OWASP Injection Prevention Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Injection_Prevention_Cheat_Sheet.html
- OWASP XSS Prevention Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Cross-Site_Scripting_Prevention_Cheat_Sheet.html
- OWASP SQL Injection Prevention -- https://cheatsheetseries.owasp.org/cheatsheets/SQL_Injection_Prevention_Cheat_Sheet.html
- OWASP OS Command Injection Defense -- https://cheatsheetseries.owasp.org/cheatsheets/OS_Command_Injection_Defense_Cheat_Sheet.html
- OWASP Input Validation Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Input_Validation_Cheat_Sheet.html
- CWE-89: SQL Injection -- https://cwe.mitre.org/data/definitions/89.html
- CWE-79: Cross-site Scripting -- https://cwe.mitre.org/data/definitions/79.html
- CWE-78: OS Command Injection -- https://cwe.mitre.org/data/definitions/78.html
- CWE-22: Path Traversal -- https://cwe.mitre.org/data/definitions/22.html
