# Security Vocabulary Guide

Essential terminology for working with security in software development. Terms are grouped by category for reference.

---

## Vulnerability Classification

**CVE (Common Vulnerabilities and Exposures)**: A unique identifier for a specific, publicly disclosed vulnerability. Format: CVE-YEAR-NUMBER. Example: CVE-2021-44228 is the Log4Shell vulnerability in Apache Log4j. CVEs are cataloged at [cve.org](https://www.cve.org/).

**CWE (Common Weakness Enumeration)**: A category of vulnerability, not a specific instance. Where CVE identifies "this exact bug in this exact software," CWE identifies the class of bug. Example: CWE-89 is "Improper Neutralization of Special Elements used in an SQL Command (SQL Injection)." A single CWE maps to thousands of CVEs.

**CVSS (Common Vulnerability Scoring System)**: A numerical score (0.0-10.0) rating vulnerability severity. Composed of base, temporal, and environmental metrics. Ranges: None (0.0), Low (0.1-3.9), Medium (4.0-6.9), High (7.0-8.9), Critical (9.0-10.0). CVSS scores help prioritize remediation but should not be the sole factor -- context matters.

**Zero-day**: A vulnerability that is unknown to the vendor and has no patch available. The name refers to the vendor having "zero days" of awareness before exploitation. Once disclosed and patched, it is no longer a zero-day.

**Exploit**: Code or technique that takes advantage of a vulnerability to cause unintended behavior. A vulnerability without a known exploit is less urgent (but not unimportant) than one with a public exploit.

---

## Threat Analysis

**STRIDE**: A threat modeling framework categorizing threats as: Spoofing (faking identity), Tampering (modifying data), Repudiation (denying actions), Information Disclosure (data leaks), Denial of Service (availability attacks), Elevation of Privilege (gaining unauthorized access).

**OWASP (Open Worldwide Application Security Project)**: A nonprofit producing freely available security resources. Best known for the OWASP Top 10 (web application risks), ASVS (Application Security Verification Standard), and tools like ZAP.

**Attack Surface**: The sum of all points where an attacker can interact with a system. Includes: network endpoints, API routes, user input fields, file upload handlers, authentication mechanisms, third-party integrations, and any interface that processes external data. Smaller attack surface means fewer opportunities for exploitation.

**Threat Model**: A structured analysis of: what you are protecting (assets), who might attack it (threat actors), how they might attack (threat vectors), and what controls prevent it (mitigations). A living document, not a one-time exercise.

**Supply Chain Attack**: Compromising a system by attacking its dependencies, build tools, or distribution mechanisms rather than the system itself. Examples: malicious npm packages, compromised build servers, tampered software updates.

**Lateral Movement**: After initial compromise, the attacker's progression through a network to reach higher-value targets. Example: compromising a developer laptop, then using saved credentials to access production servers.

**Privilege Escalation**: Gaining higher access than originally granted. Vertical escalation: regular user gains admin access. Horizontal escalation: user A accesses user B's data at the same privilege level.

---

## Security Testing

**SAST (Static Application Security Testing)**: Analyzing source code without executing it. Finds vulnerability patterns by examining code structure. Tools: Semgrep, CodeQL, SonarQube, Bandit (Python). Runs early in development (shift-left). High false positive rate but catches issues before deployment.

**DAST (Dynamic Application Security Testing)**: Testing a running application by sending requests and analyzing responses. Finds vulnerabilities that only manifest at runtime. Tools: OWASP ZAP, Burp Suite, Nuclei. Runs against staging or production. Lower false positive rate but requires a running environment.

**SCA (Software Composition Analysis)**: Identifying third-party components and their known vulnerabilities. Answers: "What open-source libraries am I using, and do any have known CVEs?" Tools: Snyk, Trivy, npm audit, pip-audit, Dependabot.

**IAST (Interactive Application Security Testing)**: Combines SAST and DAST by instrumenting the application at runtime. Monitors data flow through the application during normal testing. Lower false positive rate than SAST, more context than DAST. Tools: Contrast Security, Hdiv.

**Penetration Testing**: Authorized simulated attack against a system to find vulnerabilities. Goes beyond automated scanning -- a human tester applies creativity and contextual reasoning. Typically scoped (what is in/out of bounds) and time-limited.

---

## Access Control

**RBAC (Role-Based Access Control)**: Assigning permissions to roles, then assigning roles to users. Example: "editor" role can read and write, "viewer" role can only read. Simple to manage but coarse-grained.

**ABAC (Attribute-Based Access Control)**: Granting access based on attributes of the user, resource, action, and environment. Example: "Users in department=engineering can read documents where classification=internal during business_hours=true." More flexible than RBAC but more complex.

**JWT (JSON Web Token)**: A compact, URL-safe token format for transmitting claims between parties. Signed (JWS) to verify integrity, optionally encrypted (JWE) for confidentiality. Common in API authentication. Important: JWTs are not encrypted by default -- anyone can read the payload. They only guarantee the payload has not been tampered with.

**OAuth 2.0**: An authorization framework that allows third-party applications to access resources on behalf of a user without receiving the user's password. Defines flows (authorization code, client credentials, etc.) for different use cases. OAuth is authorization, not authentication -- OpenID Connect adds authentication on top.

---

## Web Security

**CORS (Cross-Origin Resource Sharing)**: A browser mechanism that allows a web page from one origin to request resources from another origin. Controlled via HTTP headers (Access-Control-Allow-Origin, etc.). Misconfigured CORS (allowing all origins) can enable cross-site data theft.

**CSP (Content Security Policy)**: An HTTP header that restricts which resources a page can load (scripts, styles, images, etc.). Mitigates XSS by preventing inline scripts and restricting script sources. Example: `Content-Security-Policy: script-src 'self' https://cdn.example.com`.

**HSTS (HTTP Strict Transport Security)**: An HTTP header that tells browsers to only access the site via HTTPS, even if the user types http://. Prevents SSL stripping attacks. Example: `Strict-Transport-Security: max-age=31536000; includeSubDomains`.

**SRI (Subresource Integrity)**: An HTML attribute that allows browsers to verify that a fetched resource (script, stylesheet) has not been tampered with. Uses a cryptographic hash. Example: `<script src="https://cdn.example.com/lib.js" integrity="sha384-abc123..." crossorigin="anonymous">`.

**XSS (Cross-Site Scripting)**: Injecting malicious scripts into web pages viewed by other users. Stored XSS persists in the database. Reflected XSS is in the URL or request. DOM-based XSS occurs in client-side JavaScript.

**CSRF (Cross-Site Request Forgery)**: Tricking an authenticated user's browser into making unintended requests. Mitigated with anti-CSRF tokens, SameSite cookies, and origin checking.

---

## Infrastructure Security

**WAF (Web Application Firewall)**: A reverse proxy that filters HTTP traffic based on rules. Blocks known attack patterns (SQL injection, XSS payloads, etc.) at the network edge before requests reach the application. Not a replacement for secure code, but an additional defense layer.

**IDS/IPS (Intrusion Detection/Prevention System)**: IDS monitors network traffic for suspicious patterns and generates alerts. IPS does the same but also blocks the traffic. Network-based (NIDS/NIPS) monitors network segments. Host-based (HIDS/HIPS) monitors individual systems.

**SBOM (Software Bill of Materials)**: A complete inventory of all software components, libraries, and dependencies in an application. Required for supply chain security and increasingly for regulatory compliance. Formats: CycloneDX, SPDX.

---

## Further Reading

- [OWASP Cheat Sheet Series](https://cheatsheetseries.owasp.org/) -- practical security guidance for specific topics
- [CWE Top 25](https://cwe.mitre.org/top25/) -- most dangerous software weaknesses
- [MITRE ATT&CK](https://attack.mitre.org/) -- knowledge base of adversary tactics and techniques
- [NIST Cybersecurity Framework](https://www.nist.gov/cyberframework) -- organizational security risk management

---

*Part of [LibreSecOps-Claude-Code](https://github.com/hermeticormus/LibreSecOps-Claude-Code) -- MIT License*
