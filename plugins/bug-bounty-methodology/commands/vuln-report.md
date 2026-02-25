# /vuln-report

> Write a professional vulnerability report for bug bounty platform submission with clear reproduction steps, accurate severity assessment, and impact analysis.

## Trigger

Use when you have confirmed a vulnerability and need to write a clear, professional report for submission. Also useful for:
- Reviewing and improving a draft report before submission
- Escalating a finding by demonstrating higher impact
- Writing a retest report after a fix has been deployed
- Documenting a vulnerability chain combining multiple findings

## Input

- **Vulnerability type**: What class of vulnerability (XSS, IDOR, SSRF, SQLi, etc.)
- **Affected asset**: Exact URL, endpoint, or application component
- **Description**: What you found and how it works
- **Reproduction steps**: How you triggered the vulnerability
- **Evidence**: HTTP requests/responses, screenshots, PoC code
- **Impact assessment**: What an attacker could achieve
- **Program context**: Which bug bounty program, any relevant program-specific information
- **Severity estimate**: Your initial assessment of severity

## Process

1. **Title crafting** -- Write a specific, descriptive title that communicates the vulnerability type, location, and impact in one line. Examples:
   - Good: "Stored XSS via SVG upload in profile avatar allows session hijacking on app.example.com"
   - Bad: "XSS found"
   - Good: "IDOR in /api/v2/users/{id}/documents allows any authenticated user to download other users' documents"
   - Bad: "Authorization bypass"

2. **Summary writing** -- 2-3 sentences covering: what the vulnerability is, where it exists, and the maximum impact. This is what the triage analyst reads first.

3. **Reproduction steps** -- Write exact, numbered steps that work on the first attempt:
   - Start with prerequisites (account type, browser, extensions needed)
   - Every step must be specific: exact URLs, exact input values, exact clicks
   - Include the expected vs actual result
   - Provide raw HTTP requests for precision

4. **CVSS scoring** -- Calculate CVSS v3.1 base score accurately:
   - **Attack Vector**: Network (most web vulns), Adjacent, Local, Physical
   - **Attack Complexity**: Low (straightforward) or High (special conditions needed)
   - **Privileges Required**: None, Low (any user), High (admin)
   - **User Interaction**: None or Required
   - **Scope**: Changed (impacts beyond the vulnerable component) or Unchanged
   - **Confidentiality/Integrity/Availability**: None, Low, High for each
   - Provide the vector string: `CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N`

5. **Impact analysis** -- Translate technical impact to business impact:
   - How many users are affected?
   - What data is exposed or at risk?
   - Can this be automated or scaled?
   - What is the worst-case scenario?
   - Does this chain with other findings?

6. **Remediation** -- Suggest a specific fix, not just "fix the vulnerability":
   - Name the exact function, header, configuration, or code pattern to change
   - Provide a code example of the fix if possible
   - Reference OWASP or CWE remediation guidance

## Output

```
## [Specific, Descriptive Vulnerability Title]

**Program**: [program name]
**Asset**: [exact URL/endpoint]
**Severity**: [Critical/High/Medium/Low]
**CVSS v3.1**: [score] (CVSS:3.1/AV:?/AC:?/PR:?/UI:?/S:?/C:?/I:?/A:?)
**CWE**: [CWE-xxx: Name]

---

### Summary

[2-3 sentences: vulnerability, location, maximum impact]

### Steps to Reproduce

**Prerequisites**:
- [Account type needed]
- [Browser/tool requirements]
- [Any setup steps]

1. [Exact first step with URL]
2. [Exact second step with input]
3. [Continue with precise steps]
4. **Result**: [What you observe that demonstrates the vulnerability]
5. **Expected**: [What should happen in a secure implementation]

### HTTP Evidence

**Request**:
```http
POST /api/endpoint HTTP/2
Host: target.example.com
Authorization: Bearer [your_token]
Content-Type: application/json

{"parameter": "malicious_value"}
```

**Response**:
```http
HTTP/2 200 OK
Content-Type: application/json

{"result": "evidence of vulnerability"}
```

### Proof of Concept

[Screenshot with annotation or minimal PoC script]

**Note**: This PoC demonstrates the vulnerability without causing harm. No real user data was accessed.

### Impact

[Detailed impact assessment]:
- **Confidentiality**: [What data is exposed]
- **Integrity**: [What can be modified]
- **Availability**: [Can service be disrupted]
- **Scale**: [How many users affected, can this be automated]
- **Business impact**: [Financial, regulatory, reputational consequences]

### Remediation Recommendation

[Specific fix with code example]:
```[language]
// Secure implementation
```

### References

- [OWASP reference]
- [CWE reference]
- [Related research if applicable]
```
