# STRIDE Methodology

> Detailed STRIDE analysis patterns with threat catalogs for common architectural components including web applications, APIs, databases, message queues, and cloud services.

## Knowledge Base

### STRIDE Overview

STRIDE was developed at Microsoft as a mnemonic for categorizing security threats. Each letter represents a category of threat that violates a specific security property:

| Threat | Violated Property | Question |
|--------|------------------|----------|
| **S**poofing | Authentication | Can someone pretend to be someone/something else? |
| **T**ampering | Integrity | Can someone modify data they shouldn't? |
| **R**epudiation | Non-repudiation | Can someone deny they did something? |
| **I**nformation Disclosure | Confidentiality | Can someone access data they shouldn't? |
| **D**enial of Service | Availability | Can someone prevent legitimate access? |
| **E**levation of Privilege | Authorization | Can someone do something they're not permitted to? |

### STRIDE-per-Element Application

Different DFD element types are susceptible to different STRIDE categories:

| DFD Element | S | T | R | I | D | E |
|-------------|---|---|---|---|---|---|
| **External Entity** | X | | | | | |
| **Process** | X | X | X | X | X | X |
| **Data Flow** | | X | | X | X | |
| **Data Store** | | X | X | X | X | |

This matrix guides the analysis -- you don't need to consider Elevation of Privilege for a data store, but you do for a process.

### Threat Catalogs by Component

#### Web Application (Process)

**Spoofing**:
- Session hijacking via stolen session tokens (XSS, network sniffing)
- Credential stuffing using leaked credential databases
- Cookie theft via subdomain takeover
- CSRF forcing authenticated users to perform unintended actions
- OAuth token theft via redirect URI manipulation

**Tampering**:
- SQL injection modifying database records
- Parameter tampering (hidden fields, cookies, headers)
- Mass assignment modifying protected model attributes
- Request smuggling exploiting parser inconsistencies
- Template injection executing server-side code

**Repudiation**:
- Missing audit logs for administrative actions
- Log injection creating fake log entries
- Actions performed via API not attributed to specific users
- Shared credentials preventing individual attribution

**Information Disclosure**:
- Verbose error messages exposing stack traces, SQL queries, file paths
- Directory listing exposing file structure
- Source code exposure via misconfigured server or .git directory
- Sensitive data in URL parameters (visible in logs, Referer headers)
- API responses returning more data than the client needs

**Denial of Service**:
- Application-level DoS via expensive operations (complex search, large file processing)
- Resource exhaustion via file upload without size limits
- ReDoS (Regular Expression Denial of Service) via crafted input
- Zip bomb or XML bomb via file processing
- Account lockout abuse (locking legitimate users out)

**Elevation of Privilege**:
- Broken access control (IDOR, missing authorization checks)
- JWT claim manipulation (changing role in token)
- Path traversal accessing files outside intended directory
- Insecure deserialization leading to code execution
- Privilege escalation via admin function accessible to regular users

#### API Endpoint (Process)

**Spoofing**:
- API key theft from client-side code, logs, or version control
- JWT token theft from insecure storage (localStorage)
- OAuth bearer token interception on non-TLS connections
- Service-to-service impersonation without mTLS

**Tampering**:
- Request body modification (changing quantities, prices, IDs)
- Replay attacks resending legitimate requests
- Man-in-the-middle modification of API responses
- GraphQL query manipulation (introspection, alias abuse)

**Information Disclosure**:
- Excessive data exposure (returning entire objects instead of needed fields)
- Error messages revealing internal implementation details
- GraphQL introspection exposing schema to unauthorized users
- API documentation accessible without authentication
- Pagination metadata revealing total record counts

**Denial of Service**:
- Missing rate limiting allowing brute force or resource exhaustion
- GraphQL depth/complexity attacks (deeply nested queries)
- Batch API abuse (single request triggering thousands of operations)
- Large request payloads consuming server memory

**Elevation of Privilege**:
- BOLA (Broken Object Level Authorization) -- accessing other users' objects
- BFLA (Broken Function Level Authorization) -- accessing admin endpoints
- Mass assignment setting admin/role fields
- Scope escalation in OAuth tokens

#### Database (Data Store)

**Tampering**:
- SQL injection modifying records
- Direct database access bypassing application authorization
- Backup modification or replacement
- Migration scripts with unintended data changes

**Repudiation**:
- Missing database audit logging
- Shared database credentials preventing attribution
- Audit logs stored in the same database they protect (attacker can modify them)

**Information Disclosure**:
- Unencrypted database connections
- Sensitive data stored in cleartext (passwords, tokens, PII)
- Database backups stored without encryption
- Query logs containing sensitive data values
- Error messages revealing table/column names

**Denial of Service**:
- Connection pool exhaustion
- Long-running queries blocking other operations
- Table locks from bulk operations
- Storage exhaustion from unbounded data growth

#### Message Queue / Event Bus (Data Flow)

**Tampering**:
- Message injection by unauthorized producers
- Message modification in transit (unsigned messages)
- Message replay attacks
- Message ordering manipulation

**Information Disclosure**:
- Unencrypted messages containing sensitive data
- Message content visible to all subscribers in a topic
- Dead letter queues containing sensitive data without access control
- Message metadata (headers, properties) revealing sensitive information

**Denial of Service**:
- Queue flooding with high message volume
- Poison messages causing consumer crashes
- Consumer lag leading to memory exhaustion
- Large message payloads consuming broker resources

#### Cloud Services (External Entity / Process)

**Spoofing**:
- Compromised IAM credentials (long-lived access keys)
- Cross-account access via misconfigured trust policies
- Metadata service access (169.254.169.254) from compromised instances
- Assumed roles with overly broad permissions

**Information Disclosure**:
- Public S3 buckets/blobs/storage containers
- Overly permissive security groups allowing inbound access
- CloudTrail/activity logs not enabled
- Secrets stored in environment variables visible in console
- Snapshot sharing exposing disk contents

**Elevation of Privilege**:
- IAM privilege escalation (iam:PassRole, sts:AssumeRole chains)
- Lambda/function execution role with admin permissions
- Container escape to host node
- SSRF to cloud metadata service for credential harvesting

### STRIDE Mitigation Patterns

| Threat Category | Standard Mitigations |
|----------------|---------------------|
| Spoofing | Authentication (MFA, certificates, tokens), CSRF protection, session management |
| Tampering | Input validation, integrity checks (HMAC, signatures), parameterized queries, immutable infrastructure |
| Repudiation | Audit logging, digital signatures, tamper-evident logs, timestamp services |
| Information Disclosure | Encryption (TLS, at-rest), access control, data minimization, error handling |
| Denial of Service | Rate limiting, input validation, resource quotas, circuit breakers, autoscaling |
| Elevation of Privilege | Authorization (RBAC/ABAC), least privilege, sandboxing, input validation |

## Patterns

### Effective Threat Modeling Process

1. **Start with stakeholders**: Include developers, architects, product owners, and security engineers. Diverse perspectives find more threats.
2. **Time-box sessions**: 60-90 minutes maximum. Focus on one component or feature per session.
3. **Use the DFD as a map**: Walk through the DFD element by element, applying STRIDE to each. This prevents random brainstorming.
4. **Rate immediately**: Assign a rough risk rating during the session. Detailed scoring can happen later.
5. **Track mitigations as issues**: Create tickets for each mitigation in the team's issue tracker. A threat model without follow-through is security theater.
6. **Review regularly**: Revisit the threat model when architecture changes, new features ship, or incidents occur.

### Incremental Threat Modeling

For existing systems or feature additions:
1. Draw the DFD for just the changed/new components
2. Identify new trust boundaries
3. Apply STRIDE only to new or modified elements
4. Check if changes introduce new threats to existing components
5. Update the existing threat model document

## Anti-Patterns

- **Analysis paralysis**: Spending weeks on a threat model that never ships. Time-box and iterate. An 80% threat model delivered today is better than a 100% model delivered never.
- **Threat modeling without a DFD**: Random brainstorming about "what could go wrong" misses systematic coverage. The DFD ensures every component and data flow is analyzed.
- **Treating all threats as equal**: Without risk rating, teams either try to fix everything (impossible) or give up (nothing gets fixed). Prioritize ruthlessly.
- **Security-only participation**: Developers and architects who build the system understand it best. Threat modeling without them produces theoretical threats that miss practical attack vectors.
- **One-time exercise**: A threat model created at design time and never updated becomes inaccurate as the system evolves. Treat it as a living document.
- **Ignoring non-technical threats**: Social engineering, insider threats, supply chain attacks, and physical access are real attack vectors that pure technical analysis misses.

## References

- [Microsoft Threat Modeling (SDL)](https://www.microsoft.com/en-us/securityengineering/sdl/threatmodeling)
- [OWASP Threat Modeling](https://owasp.org/www-community/Threat_Modeling)
- [Adam Shostack - Threat Modeling: Designing for Security](https://shostack.org/books/threat-modeling-book)
- [STRIDE Threat Model (Microsoft)](https://learn.microsoft.com/en-us/azure/security/develop/threat-modeling-tool-threats)
- [PASTA Threat Modeling](https://versprite.com/blog/what-is-pasta-threat-modeling/)
- [MITRE ATT&CK Framework](https://attack.mitre.org/)
