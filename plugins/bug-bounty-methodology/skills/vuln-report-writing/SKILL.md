# Vuln Report Writing

> Guide to writing vulnerability reports that get accepted, triaged quickly, and rewarded fairly, with templates, CVSS guidance, and common pitfalls.

## Knowledge Base

### Why Report Quality Matters

A triage analyst typically handles 50-100+ reports per day. They spend approximately 5 minutes on initial assessment. Your report must communicate the vulnerability's existence, impact, and reproduction method in that time. Reports that require back-and-forth clarification take weeks to resolve instead of days.

Report quality directly affects:
- **Acceptance rate**: Clear reports with reproduction steps get accepted. Vague reports get closed as "informative"
- **Triage speed**: Well-structured reports are triaged in days. Poor reports sit in queues for weeks
- **Bounty amount**: Impact clarity and severity accuracy influence reward decisions
- **Reputation**: Consistent quality builds reputation, leading to private program invitations

### Title Writing

The title is the single most important line. It appears in triage queues, dashboards, and email notifications.

**Formula**: [Vulnerability Type] in [Location/Feature] allows [Impact] on [Asset]

**Good titles**:
- "Stored XSS via Markdown rendering in comment system allows session cookie theft on app.example.com"
- "IDOR in /api/v2/orders/{id} allows any authenticated user to view other users' order details including payment information"
- "SSRF via PDF export feature allows access to internal AWS metadata (169.254.169.254) from pdf.example.com"
- "Race condition in coupon redemption allows unlimited use of single-use promotional codes"

**Bad titles**:
- "XSS" (no location, no impact)
- "Security issue found" (meaningless)
- "Critical vulnerability" (no information)
- "Multiple issues in example.com" (split into separate reports)

### CVSS v3.1 Scoring Guide

**Common web vulnerability scores**:

| Vulnerability | Typical CVSS | Vector | Notes |
|--------------|-------------|--------|-------|
| Unauthenticated RCE | 9.8 | AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H | Network, no auth, no interaction |
| Unauthenticated SQLi (data access) | 9.1 | AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N | Read + write database |
| Stored XSS (admin context) | 8.4 | AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:N | Scope changed, user interaction |
| SSRF to internal services | 7.5-9.1 | Varies | Depends on what is accessible |
| IDOR (read sensitive data) | 6.5 | AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:N/A:N | Auth required, high confidentiality |
| Reflected XSS | 6.1 | AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N | Scope changed, user interaction |
| Open redirect | 4.7 | AV:N/AC:L/PR:N/UI:R/S:C/C:N/I:L/A:N | Low impact alone, chains well |
| Information disclosure (minor) | 4.3 | AV:N/AC:L/PR:L/UI:N/S:U/C:L/I:N/A:N | Low confidentiality impact |
| Missing security header | 0-4.0 | Varies | Usually informational |

**Metric selection guidance**:

- **Scope Changed (S:C)**: Use when the vulnerable component and impacted component are different. XSS in a web app that steals cookies from a different origin is S:C. SQL injection in an app's own database is S:U.
- **Privileges Required**: PR:N (no auth needed), PR:L (any valid user), PR:H (admin/privileged user)
- **User Interaction**: UI:R if a victim must click a link or visit a page. UI:N if the attack works without victim action
- **Confidentiality High (C:H)**: Attacker can read all data within the component. Not just "some" data.

### Reproduction Steps Best Practices

**The golden rule**: A triage analyst who has never seen the application should reproduce the issue on their first attempt using only your steps.

**Structure**:
```
Prerequisites:
- Create a free account at https://example.com/register
- Browser: Chrome (latest) with no extensions
- Burp Suite Community for request interception (optional)

Steps:
1. Log in to https://example.com/login with your test account
2. Navigate to https://example.com/profile/settings
3. In the "Display Name" field, enter: `"><img src=x onerror=alert(document.domain)>`
4. Click "Save Changes"
5. Navigate to https://example.com/users (public user listing)
6. Observe: Your display name renders the injected HTML, executing JavaScript
   - The alert box shows "example.com", confirming XSS execution
   - Expected: The input should be HTML-encoded in the output
```

**Common mistakes**:
- Skipping the "create an account" step (triage analyst may not have one)
- Using "go to the page" without specifying the exact URL
- Using browser-specific payloads without specifying the browser
- Assuming the analyst knows what to observe (always state the expected vs actual result)
- Not specifying which HTTP method, content type, and parameters

### Impact Writing

Translate technical findings to business consequences:

| Technical Finding | Business Impact |
|------------------|----------------|
| SQL injection | Complete database compromise: all user credentials, PII, financial data |
| Stored XSS | Account takeover of any user who views the infected content |
| IDOR on user data | Privacy violation affecting all users; potential regulatory fines (GDPR) |
| SSRF to AWS metadata | AWS credential theft leading to full cloud infrastructure compromise |
| Race condition on payments | Financial loss through duplicate transactions |
| Open redirect | Phishing enablement using the trusted domain's reputation |

### Report Lifecycle

1. **Submission**: Report submitted via platform
2. **Triage**: Analyst reviews, attempts reproduction (hours to days)
3. **Clarification**: Analyst may request additional information (respond promptly)
4. **Validation**: Security team confirms the finding
5. **Severity assessment**: Team assigns severity (may differ from your assessment)
6. **Remediation**: Development team fixes the issue
7. **Verification**: Fix is verified (you may be asked to retest)
8. **Reward**: Bounty awarded based on severity and impact
9. **Disclosure**: Report may be disclosed publicly (after fix, per program policy)

## Patterns

### Pattern: Vulnerability Chaining
When individual findings are low-severity but combine to create higher impact, write a chain report. Document each individual finding separately, then demonstrate the chain.

Example: Open redirect (low) + OAuth state fixation (low) = account takeover (critical)

### Pattern: Visual Evidence
For findings that are hard to describe in text, create annotated screenshots or short screen recordings. Annotate with arrows and text callouts. Keep recordings under 60 seconds focused on the exact vulnerability.

### Pattern: Minimal PoC Script
For findings that require specific timing or automation, provide a minimal proof-of-concept script. Include comments explaining each step. Use common languages (Python, curl, JavaScript).

```python
#!/usr/bin/env python3
"""PoC: IDOR in /api/v2/orders - reads other users' orders
NOTE: Uses only the researcher's own account and a second test account.
No real user data was accessed."""
import requests

# Authenticate as User A
session = requests.Session()
session.post('https://example.com/api/auth', json={
    'email': 'researcher@example.com',
    'password': 'test_password'
})

# Access User B's order (should return 403, returns 200)
response = session.get('https://example.com/api/v2/orders/ORDER_ID_OF_USER_B')
print(f"Status: {response.status_code}")  # Expected: 403, Actual: 200
print(f"Data: {response.json()}")  # Contains User B's order details
```

## Anti-Patterns

- **Submitting without reproduction steps**: "I found XSS" without showing where and how is not a valid report
- **Inflated severity**: Claiming a reflected XSS is "Critical" damages credibility. Score honestly
- **Duplicate carpet bombing**: Submitting the same vulnerability class on every endpoint as separate reports. Consolidate into one report with all affected endpoints listed
- **Report-then-investigate**: Submitting immediately upon finding something suspicious, then investigating further. Validate fully before reporting
- **Threatening disclosure**: Pressuring the company with public disclosure threats. This violates program rules and may result in bans
- **Real user data in PoC**: Including actual user data (even accidentally discovered) in screenshots or reports. Use your own test data only
- **No remediation suggestion**: Reports that only describe the problem without suggesting a fix are less valuable. Include at least a general remediation direction

## References

- HackerOne Report Writing Guidelines -- https://docs.hackerone.com/hackers/quality-reports.html
- Bugcrowd Researcher Resources -- https://www.bugcrowd.com/hackers/
- CVSS v3.1 Calculator -- https://www.first.org/cvss/calculator/3.1
- CVSS v3.1 Specification -- https://www.first.org/cvss/specification-document
- CWE Database -- https://cwe.mitre.org/
- HackerOne Hacktivity (public reports for reference) -- https://hackerone.com/hacktivity
- Pentester Land: List of Public Bug Bounty Reports -- https://pentester.land/list-of-bug-bounty-writeups.html
