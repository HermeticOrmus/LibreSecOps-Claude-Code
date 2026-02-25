# Advanced: Automated Security Operations with Claude Code

> At this level, security is no longer a checklist applied to individual code changes. It is an automated, continuous system that detects, responds to, and prevents threats across the entire software lifecycle.

**Prerequisites**: Complete `../intermediate/` or have equivalent experience with threat modeling, CI/CD security pipelines, and security tooling integration.

---

## Table of Contents

1. [MCP Integrations for Security](#mcp-integrations-for-security)
2. [Custom Slash Commands](#custom-slash-commands)
3. [Automated Security Workflows](#automated-security-workflows)
4. [Red Team Simulation Patterns](#red-team-simulation-patterns)
5. [Blue Team Detection Engineering](#blue-team-detection-engineering)
6. [Compliance Automation](#compliance-automation)
7. [Production Security Patterns](#production-security-patterns)
8. [Advanced Use Cases](#advanced-use-cases)
9. [Three-Month Security Learning Path](#three-month-security-learning-path)

---

## MCP Integrations for Security

The Model Context Protocol (MCP) allows Claude Code to interact with external tools directly. For security operations, this means Claude can drive scanners, read results, and act on findings without manual copy-paste.

### Burp Suite Integration

Burp Suite is the industry standard for web application security testing. An MCP server wrapping Burp's REST API lets Claude orchestrate scans and analyze results.

```json
// .mcp.json - Burp Suite MCP configuration
{
  "mcpServers": {
    "burp": {
      "command": "node",
      "args": ["mcp-servers/burp-suite/index.js"],
      "env": {
        "BURP_API_URL": "http://localhost:1337",
        "BURP_API_KEY": "${BURP_API_KEY}"
      }
    }
  }
}
```

**Usage pattern**:

```
"Using the Burp MCP server:
1. Start an active scan against https://staging.example.com
2. Wait for completion
3. Retrieve all findings with severity HIGH or CRITICAL
4. For each finding, analyze exploitability in our application context
5. Generate a prioritized remediation plan with code fixes"
```

### OWASP ZAP Integration

ZAP provides a comprehensive API that maps well to MCP.

```json
{
  "mcpServers": {
    "zap": {
      "command": "python",
      "args": ["mcp-servers/zap/server.py"],
      "env": {
        "ZAP_API_URL": "http://localhost:8080",
        "ZAP_API_KEY": "${ZAP_API_KEY}"
      }
    }
  }
}
```

**Capabilities through MCP**:

- Spider a target to discover endpoints
- Run active scan with specific policy
- Retrieve alerts grouped by risk
- Generate report in multiple formats
- Manage scan policies and contexts

```
"Using ZAP MCP:
1. Spider https://staging.example.com with max depth 5
2. Run active scan using the 'API Security' policy
3. Export findings as JSON
4. Cross-reference findings with our threat model in THREAT_MODEL.md
5. Identify any new threats not covered by the existing model"
```

### Nuclei Integration

Nuclei's template-based approach makes it ideal for automated, repeatable scanning.

```json
{
  "mcpServers": {
    "nuclei": {
      "command": "node",
      "args": ["mcp-servers/nuclei/index.js"],
      "env": {
        "NUCLEI_BINARY": "/usr/local/bin/nuclei",
        "TEMPLATES_DIR": "/opt/nuclei-templates"
      }
    }
  }
}
```

**Custom template generation with Claude**:

```
"We discovered that our application uses a custom header X-Tenant-ID
for tenant identification without server-side validation. Write a
Nuclei template that:
1. Tests if X-Tenant-ID can be spoofed to access other tenants' data
2. Tests with numeric IDs (1, 2, 3...) and UUIDs
3. Checks for IDOR across the /api/projects, /api/users, /api/billing endpoints
4. Reports severity as HIGH if any cross-tenant access is confirmed

Format as a valid Nuclei YAML template with proper metadata."
```

### Building Custom MCP Security Servers

For internal tools or proprietary scanners, build custom MCP servers:

```typescript
// mcp-servers/security-dashboard/index.ts
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new Server({
  name: "security-dashboard",
  version: "1.0.0"
}, {
  capabilities: {
    tools: {}
  }
});

server.setRequestHandler("tools/list", async () => ({
  tools: [
    {
      name: "get_vulnerabilities",
      description: "Retrieve open vulnerabilities with optional severity filter",
      inputSchema: {
        type: "object",
        properties: {
          severity: {
            type: "string",
            enum: ["critical", "high", "medium", "low"],
            description: "Minimum severity to include"
          },
          project: {
            type: "string",
            description: "Project name to filter by"
          },
          status: {
            type: "string",
            enum: ["open", "in-progress", "resolved"],
            description: "Vulnerability status filter"
          }
        }
      }
    },
    {
      name: "get_scan_history",
      description: "Retrieve historical scan results for trend analysis",
      inputSchema: {
        type: "object",
        properties: {
          project: { type: "string" },
          days: { type: "number", description: "Number of days of history" }
        },
        required: ["project"]
      }
    },
    {
      name: "create_security_ticket",
      description: "Create a security finding ticket in the issue tracker",
      inputSchema: {
        type: "object",
        properties: {
          title: { type: "string" },
          severity: { type: "string" },
          description: { type: "string" },
          cwe: { type: "string" },
          affected_component: { type: "string" },
          remediation: { type: "string" }
        },
        required: ["title", "severity", "description"]
      }
    }
  ]
}));

// Tool execution handler
server.setRequestHandler("tools/call", async (request) => {
  const { name, arguments: args } = request.params;

  switch (name) {
    case "get_vulnerabilities":
      return await queryVulnerabilityDatabase(args);
    case "get_scan_history":
      return await queryScanHistory(args);
    case "create_security_ticket":
      return await createTicket(args);
    default:
      throw new Error(`Unknown tool: ${name}`);
  }
});

const transport = new StdioServerTransport();
await server.connect(transport);
```

---

## Custom Slash Commands

Slash commands encode repeatable security workflows into single invocations.

### /sec-audit: Security Audit

```markdown
<!-- .claude/commands/sec-audit.md -->
Perform a comprehensive security audit of this codebase.

Phase 1 - Static Analysis:
1. Identify all external inputs (HTTP endpoints, file uploads, environment
   variables, CLI arguments, database reads from shared tables)
2. Trace each input through the code to all sinks (database queries,
   file system operations, HTML output, command execution, network requests)
3. Check for proper validation and sanitization at each boundary

Phase 2 - Authentication and Authorization:
1. Map all authentication flows
2. Identify every authorization check
3. Find endpoints missing authorization
4. Check session management configuration

Phase 3 - Data Security:
1. Find all locations where sensitive data is stored, logged, or transmitted
2. Verify encryption at rest and in transit
3. Check for PII in logs
4. Verify secrets management (no hardcoded credentials)

Phase 4 - Dependency Analysis:
1. List all direct and transitive dependencies
2. Check for known CVEs
3. Identify abandoned or unmaintained packages
4. Flag overly permissive dependency version ranges

Phase 5 - Configuration:
1. Check security headers
2. Verify CORS configuration
3. Check TLS configuration
4. Review error handling (no information leakage)

Output format:
- Executive summary (3-5 sentences)
- Findings table: ID, Severity (CRITICAL/HIGH/MEDIUM/LOW/INFO), CWE,
  Component, Description, File:Line, Remediation
- Risk score: weighted count of findings
- Priority remediation order with effort estimates
```

### /sec-scan: Quick Security Scan

```markdown
<!-- .claude/commands/sec-scan.md -->
Run a focused security scan on recently changed files.

1. Identify files changed in the last 5 commits (or staged changes if any)
2. For each changed file, check for:
   - New external inputs without validation
   - SQL/NoSQL queries without parameterization
   - HTML output without encoding
   - Hardcoded secrets or credentials
   - New dependencies (check for CVEs)
   - Disabled security controls
   - TODO/FIXME comments related to security
   - Error handling that might leak information
3. Cross-reference changes against the project's CLAUDE.md security requirements
4. Output: pass/fail for each check with file:line references
```

### /sec-harden: Security Hardening

```markdown
<!-- .claude/commands/sec-harden.md -->
Harden the specified component: $ARGUMENTS

1. Identify the component type (API endpoint, database layer, auth system,
   infrastructure config, container image, CI/CD pipeline)

2. Apply hardening based on component type:

   API Endpoint:
   - Add/verify input validation with strict schemas
   - Add/verify rate limiting
   - Add/verify authentication and authorization
   - Add/verify security headers
   - Add/verify error handling (no information leakage)
   - Add/verify request logging (without PII)

   Database Layer:
   - Convert string queries to parameterized
   - Add/verify row-level security for multi-tenant
   - Add/verify encrypted connections
   - Add/verify least-privilege database users
   - Add/verify audit logging for sensitive operations

   Container Image:
   - Switch to minimal base image (distroless/alpine)
   - Run as non-root user
   - Remove unnecessary packages and tools
   - Add health checks
   - Set read-only filesystem where possible
   - Pin base image by digest

   CI/CD Pipeline:
   - Add secret scanning
   - Add SAST scanning
   - Add dependency auditing
   - Add container image scanning
   - Pin action versions by SHA
   - Add required review for security findings

3. Implement all hardening changes
4. Generate before/after comparison
5. Write tests verifying hardening is effective
```

### /sec-incident: Incident Response

```markdown
<!-- .claude/commands/sec-incident.md -->
Initiate security incident response for: $ARGUMENTS

Phase 1 - Triage (immediate):
1. Classify severity: P1 (active exploitation), P2 (confirmed vulnerability,
   not yet exploited), P3 (potential vulnerability, unconfirmed)
2. Identify affected components and blast radius
3. Determine if data was accessed, modified, or exfiltrated
4. Document initial findings with timestamps

Phase 2 - Containment (P1: within minutes, P2: within hours):
1. Generate containment options:
   - Disable affected endpoint/feature
   - Rotate compromised credentials
   - Block attacking IP/range
   - Revoke affected sessions
   - Enable additional logging
2. Recommend least-disruptive effective containment
3. Generate the commands/code for containment actions

Phase 3 - Investigation:
1. Collect relevant logs (application, infrastructure, access)
2. Build timeline of events
3. Identify root cause
4. Determine full scope of impact
5. Document evidence (preserve, do not modify)

Phase 4 - Remediation:
1. Write the fix for the root cause
2. Write tests proving the fix works
3. Identify related code that might have the same vulnerability
4. Update threat model with new finding

Phase 5 - Documentation:
1. Generate incident report: timeline, impact, root cause, remediation,
   lessons learned, action items
2. Update runbooks if this scenario was not covered
3. Create detection rule to catch this in the future
```

---

## Automated Security Workflows

### Vulnerability Triage Pipeline

Automate the process of receiving vulnerability reports, assessing them, and routing them to the right team.

```yaml
# .github/workflows/vuln-triage.yml
name: Vulnerability Triage
on:
  issues:
    types: [opened]
    # Trigger on issues with "security" label

jobs:
  triage:
    if: contains(github.event.issue.labels.*.name, 'security')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Analyze vulnerability report
        uses: anthropic/claude-code-action@v1
        with:
          prompt: |
            Analyze this vulnerability report and provide:
            1. CVSS v3.1 score estimate with vector string
            2. Affected component(s) in the codebase
            3. Reproducibility assessment
            4. Suggested severity label: critical, high, medium, low
            5. Recommended assignee based on CODEOWNERS
            6. Initial remediation approach

            Issue title: ${{ github.event.issue.title }}
            Issue body: ${{ github.event.issue.body }}

      - name: Apply labels and assign
        uses: actions/github-script@v7
        with:
          script: |
            // Parse Claude's analysis and apply labels/assignment
            // (implementation depends on output format)
```

### Automated Dependency Patching

```yaml
# .github/workflows/dependency-patch.yml
name: Security Dependency Patching
on:
  schedule:
    - cron: '0 6 * * 1' # Every Monday at 6 AM
  workflow_dispatch:

jobs:
  audit-and-patch:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run npm audit
        id: audit
        run: |
          npm ci
          npm audit --json > audit-results.json || true

      - name: Analyze and fix vulnerabilities
        uses: anthropic/claude-code-action@v1
        with:
          prompt: |
            Analyze the npm audit results in audit-results.json.
            For each HIGH or CRITICAL vulnerability:
            1. Check if the fix is a semver-compatible update
            2. Check if the fix introduces breaking changes
            3. If safe to update, update package.json
            4. If breaking changes, document what needs manual review
            Create a summary of all changes made.

      - name: Run tests
        run: npm test

      - name: Create PR
        uses: peter-evans/create-pull-request@v5
        with:
          title: "security: automated dependency patching"
          body: |
            Automated security patches for npm dependencies.
            See commit messages for details on each update.
          branch: security/auto-dependency-patch
          labels: security, dependencies
```

### Security Review Pipeline

Integrate Claude Code into the PR review process for security-focused analysis:

```yaml
# .github/workflows/security-review.yml
name: Security Review
on:
  pull_request:
    types: [opened, synchronize]

jobs:
  security-review:
    runs-on: ubuntu-latest
    permissions:
      pull-requests: write
      contents: read
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get changed files
        id: changes
        run: |
          echo "files=$(git diff --name-only origin/${{ github.base_ref }}...HEAD | tr '\n' ' ')" >> $GITHUB_OUTPUT

      - name: Security review
        uses: anthropic/claude-code-action@v1
        with:
          prompt: |
            Perform a security review of the following changed files: ${{ steps.changes.outputs.files }}

            Check for:
            1. New inputs without validation
            2. SQL/command injection risks
            3. Authentication/authorization gaps
            4. Secrets or credentials in code
            5. Dependency changes with security implications
            6. Configuration changes that weaken security
            7. Error handling that leaks information

            Reference the project's CLAUDE.md security requirements.

            Format: For each finding, provide severity, CWE, file:line, and fix.
            If no findings, confirm "No security issues found in this change."
```

---

## Red Team Simulation Patterns

Red teaming uses adversarial thinking to find vulnerabilities before attackers do. Claude Code can simulate attacker methodology to test your defenses.

### Reconnaissance Simulation

```
"Act as a penetration tester performing reconnaissance against our
application. Using only the information available in this codebase:

1. Map the attack surface:
   - All HTTP endpoints with methods and parameters
   - Authentication mechanisms and their configurations
   - External service integrations and their credentials
   - File upload and download functionality
   - WebSocket or real-time endpoints
   - Admin or debug endpoints

2. Identify information leakage:
   - Error messages that reveal implementation details
   - API responses that return more data than needed
   - Comments in code that describe security mechanisms
   - Configuration files with sensitive defaults
   - Package versions that reveal technology stack

3. Prioritize attack vectors:
   - Rank by: ease of exploitation x impact x likelihood
   - For each vector, describe the attack scenario in 2-3 sentences
   - Estimate skill level required: script kiddie, intermediate, advanced

Output a reconnaissance report formatted for the red team lead."
```

### Exploitation Scenario Generation

```
"For the top 5 attack vectors identified in the reconnaissance phase,
develop detailed exploitation scenarios:

For each scenario provide:
1. Attack narrative: step-by-step from attacker's perspective
2. Prerequisites: what the attacker needs (account, network position, etc.)
3. Tools: specific tools and commands the attacker would use
4. Indicators of Compromise (IOCs): what the blue team should detect
5. Proof of Concept: code or commands that demonstrate the vulnerability
   (safe for testing against our staging environment)
6. Impact: exactly what the attacker achieves if successful
7. Detection difficulty: how likely the blue team catches this

DO NOT: attempt actual exploitation, access production systems, or
generate destructive payloads. All PoCs must be safe for staging."
```

### Attack Chain Modeling

Map multi-step attack paths through your system:

```
"Model attack chains for our application. An attack chain is a sequence
of vulnerabilities that, when combined, achieve a higher-impact outcome
than any single vulnerability alone.

Example chain: XSS in comment field -> steal admin session cookie ->
access admin panel -> export all user data

For our codebase:
1. Identify 3-5 possible attack chains
2. For each chain, list:
   - Initial access vector
   - Each escalation step with the vulnerability exploited
   - Final impact
   - Probability of success (considering existing controls)
   - Which link in the chain is easiest to break (best mitigation point)
3. Recommend mitigations that break the most chains simultaneously"
```

### Social Engineering Awareness

```
"Analyze our application for social engineering vulnerabilities:

1. Password reset flow: Can an attacker reset another user's password
   using publicly available information?
2. Account recovery: What information is needed? Is it guessable?
3. Support workflows: Could an attacker impersonate a user to support staff?
4. Phishing surface: What legitimate emails does our system send that
   could be mimicked? Are they DKIM signed?
5. OAuth flows: Could an attacker create a lookalike OAuth application?

For each finding, suggest a technical control (not just training)."
```

---

## Blue Team Detection Engineering

### SIEM Rule Development

Write detection rules for your SIEM (Splunk, Elastic, Sentinel) using Claude Code:

```
"Write Elastic Security detection rules for the following scenarios
in our application:

1. Brute force detection:
   - More than 10 failed login attempts from same IP in 5 minutes
   - More than 5 failed login attempts for same account in 15 minutes
   - Password spray: 1 failed attempt each for > 20 accounts from same IP

2. Privilege escalation:
   - User role changes outside of admin panel
   - Direct database modification of user roles
   - API calls to admin endpoints from non-admin sessions

3. Data exfiltration indicators:
   - API responses larger than 10x the average for that endpoint
   - More than 100 data export requests in 1 hour
   - Access to more than 50 unique user records in 10 minutes

4. Lateral movement:
   - Service-to-service calls from unexpected sources
   - Internal API calls with external IP in X-Forwarded-For
   - New service account usage from previously unseen source

Format as Elastic EQL rules with proper metadata (MITRE ATT&CK mapping,
severity, risk score, false positive guidance)."
```

### Detection-as-Code

Store detection rules in version control, test them, and deploy automatically:

```python
# detections/brute_force.py
"""
title: Brute Force Login Detection
id: SEC-DET-001
mitre_attack:
  - T1110.001  # Brute Force: Password Guessing
  - T1110.003  # Brute Force: Password Spraying
severity: medium
data_sources:
  - authentication_logs
false_positives:
  - Automated testing environments
  - Shared IP addresses (NAT/VPN)
"""

RULE = {
    "name": "brute_force_single_account",
    "description": "Multiple failed login attempts for a single account",
    "query": """
        event.category: "authentication"
        AND event.outcome: "failure"
        | stats count by user.name, source.ip
        | where count > 5
    """,
    "time_window": "15m",
    "severity": "medium",
    "actions": [
        {"type": "alert", "channel": "security-alerts"},
        {"type": "enrich", "source": "threat_intel", "field": "source.ip"},
        {"type": "auto_respond", "condition": "count > 20",
         "action": "block_ip_temporary", "duration": "1h"}
    ]
}

TESTS = [
    {
        "name": "should_trigger_on_6_failures",
        "events": [
            {"user": "alice", "ip": "1.2.3.4", "outcome": "failure"}
        ] * 6,
        "expected": "trigger"
    },
    {
        "name": "should_not_trigger_on_5_failures",
        "events": [
            {"user": "alice", "ip": "1.2.3.4", "outcome": "failure"}
        ] * 5,
        "expected": "no_trigger"
    },
    {
        "name": "should_not_trigger_on_mixed_outcomes",
        "events": [
            {"user": "alice", "ip": "1.2.3.4", "outcome": "failure"},
            {"user": "alice", "ip": "1.2.3.4", "outcome": "success"},
            {"user": "alice", "ip": "1.2.3.4", "outcome": "failure"},
        ] * 2,
        "expected": "no_trigger"
    }
]
```

### Alert Quality Metrics

Track and improve your detection quality:

```
"Analyze our detection rules in the detections/ directory and evaluate:

1. Coverage: Map each rule to MITRE ATT&CK. What techniques are covered?
   What gaps exist for our threat model?
2. Quality: For each rule, estimate:
   - True positive rate (based on rule logic and data quality)
   - False positive rate (how many legitimate events match?)
   - Detection latency (time from event to alert)
3. Redundancy: Are multiple rules detecting the same behavior?
   Should they be consolidated?
4. Testability: Does each rule have test cases? Are edge cases covered?
5. Actionability: When this rule fires, is the response clear?
   Does the alert contain enough context to triage without further investigation?

Output: detection coverage matrix against MITRE ATT&CK with heat map
and prioritized list of gaps to address."
```

---

## Compliance Automation

### SOC 2 Evidence Collection

SOC 2 requires evidence that security controls are operating effectively. Automate evidence collection.

```
"Design an automated SOC 2 evidence collection system for our application.
Map to Trust Services Criteria:

CC6.1 - Logical and Physical Access Controls:
- Generate: list of all user accounts, roles, and last access date
- Generate: access review evidence (accounts with access vs. authorized list)
- Generate: terminated user account disable timestamps
- Source: IAM provider API, HR system API

CC7.1 - System Monitoring:
- Generate: proof that monitoring is active and alerting works
- Generate: sample security alerts and response timestamps
- Generate: uptime and availability metrics
- Source: monitoring system API, incident tracker

CC8.1 - Change Management:
- Generate: list of all changes with approval evidence
- Generate: CI/CD pipeline configuration showing required reviews
- Generate: deployment log with approver and timestamp
- Source: GitHub API (PRs with reviews), deployment system

Implement as a script that runs monthly and generates an evidence
package in a standardized format (JSON + human-readable report).
Store evidence in an append-only, tamper-evident log."
```

### GDPR Data Mapping

```
"Perform automated GDPR data mapping for our codebase:

1. Personal Data Inventory:
   Scan all models, database schemas, and API endpoints to identify
   fields that contain personal data. Classify each as:
   - Identifying (name, email, phone, address, IP, user agent)
   - Sensitive (health, financial, biometric, political, religious)
   - Behavioral (usage data, preferences, analytics)

2. Data Flow Mapping:
   For each personal data field, trace:
   - Collection point (which endpoint/form collects it)
   - Storage location (which database/table/column)
   - Processing operations (what code reads/transforms it)
   - Sharing (which external services receive it)
   - Retention (how long is it kept, is deletion automated)

3. Legal Basis Verification:
   For each data type, verify that the codebase implements:
   - Consent collection (where applicable)
   - Purpose limitation (data used only for stated purpose)
   - Data minimization (no unnecessary data collection)
   - Right to erasure (deletion endpoint exists and works)
   - Right to portability (export endpoint exists)
   - Right to access (user can view their data)

4. Gap Analysis:
   - Personal data without documented legal basis
   - Missing deletion capability for any personal data field
   - Missing export capability
   - Data shared with third parties without consent flow
   - Retention periods not enforced

Output: GDPR data map document suitable for DPO review, with specific
code references for each finding and gap."
```

### PCI-DSS Compliance Checks

```
"Audit this codebase against PCI-DSS v4.0 requirements relevant to
application development:

Requirement 3 - Protect Stored Account Data:
- [ ] 3.3.1: SAD (sensitive authentication data) not stored after authorization
- [ ] 3.4.1: PAN rendered unreadable in storage (encryption or hashing)
- [ ] 3.5.1: PAN secured with strong cryptography

Requirement 4 - Protect Cardholder Data in Transit:
- [ ] 4.2.1: Strong cryptography for transmission (TLS 1.2+)
- [ ] 4.2.1.1: Certificates are valid and not expired

Requirement 6 - Develop Secure Systems:
- [ ] 6.2.1: Custom software developed securely (OWASP guidelines)
- [ ] 6.2.3: Code reviewed for vulnerabilities before production
- [ ] 6.2.4: Common coding vulnerabilities addressed (OWASP Top 10)
- [ ] 6.3.1: Known security vulnerabilities identified and addressed
- [ ] 6.3.2: Software inventory maintained
- [ ] 6.4.1: Public-facing web applications protected (WAF or code review)
- [ ] 6.4.2: Public-facing web applications protected against known attacks

Requirement 7 - Restrict Access:
- [ ] 7.2.1: Access control model defined
- [ ] 7.2.2: Access assigned based on job function

Requirement 8 - Identify Users:
- [ ] 8.2.1: All users assigned unique ID
- [ ] 8.3.1: Authentication factors for all access
- [ ] 8.3.6: Minimum password complexity

Requirement 10 - Log and Monitor:
- [ ] 10.2.1: Audit logs enabled
- [ ] 10.2.1.1: All individual user access to cardholder data logged
- [ ] 10.2.1.2: All actions by individuals with admin access logged

For each requirement: PASS (with evidence), FAIL (with finding and fix),
or N/A (with justification). Include file:line references."
```

---

## Production Security Patterns

### WAF Configuration

```
"Generate an AWS WAF v2 configuration (Terraform) for our API with:

Rate limiting:
- Global: 2000 requests per 5 minutes per IP
- Login endpoint: 10 requests per 5 minutes per IP
- Registration: 5 requests per hour per IP

Managed rule groups:
- AWSManagedRulesCommonRuleSet (core protections)
- AWSManagedRulesKnownBadInputsRuleSet (Log4j, etc.)
- AWSManagedRulesSQLiRuleSet (SQL injection)
- AWSManagedRulesLinuxRuleSet (if Linux backend)

Custom rules:
- Block requests with X-Forwarded-For header from non-CDN sources
- Block requests larger than 5MB (except upload endpoints)
- Block User-Agent strings matching known scanner patterns
- Geo-block countries not in our service area

Logging:
- Log all blocked requests to S3
- Log sampled allowed requests (1%)
- Enable CloudWatch metrics for each rule

Include: rule priority ordering, metric names for monitoring,
and a runbook for when rules block legitimate traffic."
```

### Rate Limiting Architecture

```
"Design a multi-layer rate limiting architecture:

Layer 1 - Edge (CDN/WAF):
- IP-based limits
- Geographic restrictions
- Known-bad source blocking
- DDoS mitigation

Layer 2 - API Gateway:
- Per-route limits
- API key-based limits
- Request size limits
- Concurrent connection limits

Layer 3 - Application:
- Per-user limits (authenticated)
- Per-operation limits (writes vs. reads)
- Resource-specific limits (expensive operations)
- Sliding window with burst allowance

Layer 4 - Database:
- Connection pool limits
- Query timeout enforcement
- Row count limits on responses

Implementation:
- Use Redis for distributed rate limiting state
- Use token bucket algorithm (allows bursts while maintaining average rate)
- Return 429 with Retry-After header
- Include X-RateLimit-Limit, X-RateLimit-Remaining, X-RateLimit-Reset headers
- Log rate limit hits for analysis (detect attacks vs. legitimate growth)

Generate the Express.js middleware, Redis Lua script for atomic
rate limiting, and monitoring configuration."
```

### DDoS Mitigation Patterns

```
"Design DDoS mitigation for our application stack:

Application-layer (L7) mitigation:
- CAPTCHA escalation: serve CAPTCHA after rate limit threshold
- JavaScript challenge: require JS execution to filter basic bots
- Request fingerprinting: identify and block automated request patterns
- Graceful degradation: disable expensive features under load
  (search, reports, file upload) while keeping core functionality

Network-layer (L3/L4) mitigation:
- Anycast routing via CDN (Cloudflare, AWS CloudFront)
- SYN cookie protection
- Connection rate limiting
- Protocol validation

Auto-scaling response:
- Define scale triggers based on request rate and error rate
- Implement circuit breakers for downstream services
- Configure health check endpoints that verify real functionality
  (not just 200 OK on a static route)
- Set maximum scale limits to control cost

Runbook:
- How to identify DDoS vs. legitimate traffic spike
- Escalation path and communication plan
- When to engage CDN provider's DDoS team
- Post-incident analysis procedure"
```

---

## Advanced Use Cases

### Threat Hunting

Proactively search for indicators of compromise that existing detections missed.

```
"Design threat hunting queries for our application logs. The hypothesis
is that an attacker has compromised a regular user account and is
performing slow-and-low data exfiltration.

Hunt 1 - Anomalous access patterns:
- Users accessing resources outside their normal pattern
- Query: compare each user's resource access in the last 7 days against
  their 90-day baseline. Flag users with > 3 standard deviations difference.

Hunt 2 - Low-rate data collection:
- Query: users who accessed incrementing record IDs in sequence
  (user/1, user/2, user/3...) even at slow rates (< 1 req/min)
- This evades rate limiting but indicates automated enumeration

Hunt 3 - Credential stuffing aftermath:
- Query: accounts that were inactive for > 90 days and suddenly active
- Cross-reference with login from new geolocation or device fingerprint

Hunt 4 - API abuse:
- Query: authenticated users calling undocumented or deprecated endpoints
- Query: users with abnormally high ratio of error responses (probing)

For each hunt, provide:
1. The specific log query (Elastic/Splunk syntax)
2. Expected false positive rate and how to triage
3. Escalation criteria (when does a hunt finding become an incident?)
4. Recommended response if the hunt confirms the hypothesis"
```

### Security Chaos Engineering

Deliberately introduce security failures to test detection and response:

```
"Design security chaos experiments for our staging environment.
Each experiment tests whether our defenses detect and respond correctly.

Experiment 1 - Credential Leak Simulation:
- Action: Commit a test credential (clearly marked as test) to a branch
- Expected: Secret scanner blocks the commit or PR
- Measures: Time to detection, was it blocked or just alerted?

Experiment 2 - Dependency Vulnerability:
- Action: Introduce a dependency with a known HIGH CVE
- Expected: CI pipeline blocks the merge
- Measures: Time to detection, severity classification accuracy

Experiment 3 - Authorization Bypass:
- Action: Craft API requests that attempt IDOR (modify user ID parameter)
- Expected: Application returns 403, alert fires in SIEM
- Measures: Was the access blocked? Was it detected? Was it logged?

Experiment 4 - Data Exfiltration:
- Action: Authenticated user downloads > 100 records in rapid succession
- Expected: Rate limiter triggers, anomaly detection alert fires
- Measures: At what threshold was it detected? Response time?

Experiment 5 - Incident Response:
- Action: Trigger a simulated P2 security incident
- Expected: On-call acknowledges within SLA, triage begins
- Measures: Time to acknowledgment, time to containment, communication quality

Safety requirements:
- All experiments in staging only
- Test credentials clearly marked, auto-expire within 1 hour
- Rollback plan for each experiment
- Experiment log documenting what was done and when"
```

### Breach Simulation

Full-scope simulation of a security breach for testing organizational response.

```
"Design a breach simulation exercise for our organization.
This is a tabletop exercise, not a live test.

Scenario: An attacker exploited a deserialization vulnerability in our
API (CVE-2024-XXXX in a dependency we use). They achieved remote code
execution, escalated to database access, and exfiltrated 50,000 user
records including email, hashed passwords, and billing addresses.
The breach occurred 72 hours ago. It was discovered when a user
reported receiving phishing emails referencing data only in our system.

Exercise Timeline (inject events every 15 minutes):

T+0: Report received from user about suspicious email
  - Q: Who is notified first? What's the initial response?

T+15: Investigation confirms email contains data from our database
  - Q: How do we confirm the breach? What logs do we check?

T+30: Forensics identifies the vulnerability and entry point
  - Q: Do we patch immediately or preserve evidence? Both?

T+45: Scope determined: 50K users affected
  - Q: What are our notification obligations? (GDPR: 72 hours,
    state laws vary). Who drafts the notification?

T+60: Media inquiry received
  - Q: Who handles media? What is the communication plan?

T+75: Containment confirmed
  - Q: How do we verify the attacker no longer has access?
    What credentials need rotation?

T+90: Recovery and lessons learned
  - Q: What systemic changes prevent recurrence?
    What detection would have caught this earlier?

For each inject, provide:
1. The scenario development (what new information is revealed)
2. Decision points for the team
3. Expected actions per role (engineering, security, legal, communications)
4. Common mistakes teams make at this stage
5. Reference documents that should exist before this happens"
```

---

## Three-Month Security Learning Path

A structured progression from security practitioner to security engineer, designed for developers using Claude Code.

### Month 1: Offensive Foundations

**Goal**: Understand how attacks work so you can build effective defenses.

**Week 1-2: Web Application Attacks**
- Study: PortSwigger Web Security Academy (free) -- complete SQL injection, XSS, CSRF labs
- Practice: Set up DVWA (Damn Vulnerable Web Application) locally
- Claude Code exercise: Use Claude to explain each vulnerability you exploit, then write the fix
- Milestone: Complete PortSwigger's "Apprentice" level labs for injection and XSS

**Week 3-4: Authentication and Session Attacks**
- Study: PortSwigger authentication labs, OWASP Testing Guide chapter on auth
- Practice: Use Burp Suite to intercept and modify authentication flows
- Claude Code exercise: Audit your own project's auth against OWASP ASVS Level 2
- Milestone: Document all auth weaknesses found and remediation applied

### Month 2: Defensive Engineering

**Goal**: Build detection, monitoring, and automated response capabilities.

**Week 5-6: Detection Engineering**
- Study: MITRE ATT&CK framework -- focus on Initial Access, Execution, Persistence tactics
- Practice: Write 10 detection rules for your application's SIEM
- Claude Code exercise: Use Claude to generate detection rules, then test them with synthetic events
- Tool mastery: Elastic Security or Splunk -- build a security dashboard
- Milestone: Detection rules covering top 10 threats from your threat model, all with test cases

**Week 7-8: Incident Response**
- Study: NIST SP 800-61 (Computer Security Incident Handling Guide)
- Practice: Run 2 tabletop exercises with your team using the breach simulation template above
- Claude Code exercise: Generate incident response runbooks for your 5 most likely incident types
- Tool mastery: Forensic log analysis -- practice reconstructing attack timelines from logs
- Milestone: Incident response plan documented, tested, and published to team

### Month 3: Architecture and Automation

**Goal**: Design systems that are secure by default and automate ongoing security.

**Week 9-10: Secure Architecture**
- Study: NIST SP 800-53 (Security and Privacy Controls), focus on access control and audit families
- Practice: Redesign one subsystem of your application using zero trust principles
- Claude Code exercise: Use Claude for architecture review -- provide your design doc and ask for security analysis
- Tool mastery: Infrastructure as Code security scanning (Checkov, tfsec)
- Milestone: Architecture decision records (ADRs) for 3 security-significant design choices

**Week 11-12: Security Automation**
- Study: DevSecOps maturity models (OWASP DSOMM, BSIMM)
- Practice: Implement the full security pipeline from the intermediate guide
- Claude Code exercise: Build custom MCP integrations for your security tools
- Build: Automated compliance evidence collection for your primary compliance framework
- Milestone: Full security pipeline operational, custom slash commands deployed, compliance evidence automated

### Assessment Checkpoints

**End of Month 1**:
- [ ] Can exploit OWASP Top 10 vulnerabilities in a lab environment
- [ ] Can explain each vulnerability's root cause and remediation
- [ ] Have audited own project's auth and remediated findings

**End of Month 2**:
- [ ] 10+ detection rules deployed with test cases
- [ ] Incident response plan tested via tabletop exercise
- [ ] Security dashboard operational with real-time monitoring

**End of Month 3**:
- [ ] Zero trust architecture documented for at least one subsystem
- [ ] Full security pipeline in CI/CD with < 5% false positive rate
- [ ] Compliance evidence collection automated
- [ ] Custom Claude Code slash commands for security workflows

### Continuing Education

After completing this path:

- **Certifications**: OSCP (offensive), CISSP (management), CKS (Kubernetes security)
- **Community**: Join OWASP local chapter, participate in CTF competitions
- **Research**: Follow security advisories for your tech stack, contribute to open-source security tools
- **Practice**: Bug bounty programs (HackerOne, Bugcrowd) for real-world experience
- **Teach**: The best way to learn is to teach -- write about your security findings, mentor others

---

## Next Steps

This advanced guide provides the frameworks. Execution requires:

1. Choose one automated workflow and implement it this week
2. Set up at least one MCP integration for security tooling
3. Create the four custom slash commands for your project
4. Begin Month 1 of the learning path
5. Contribute improvements back to this guide

Security is an ongoing practice, not a destination. The tools and techniques evolve continuously. The principles -- defense in depth, least privilege, assume breach -- remain constant.

---

*Part of [LibreSecOps-Claude-Code](https://github.com/hermeticormus/LibreSecOps-Claude-Code) -- MIT License*
