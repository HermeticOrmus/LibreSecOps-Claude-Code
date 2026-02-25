# /fix-vuln

> Fix a specific vulnerability class in provided code, with root cause analysis, the corrected implementation, and verification guidance.

## Trigger

Use when you have identified (or suspect) a specific vulnerability in code and need to fix it correctly. Appropriate for:
- Remediating findings from a security audit or penetration test
- Fixing a vulnerability reported through a bug bounty program
- Correcting a pattern flagged by a SAST tool
- Learning the proper fix for a specific vulnerability class
- Verifying that a proposed fix actually resolves the vulnerability

## Input

- **Code containing the vulnerability**: The specific code to fix
- **Vulnerability class**: What type of vulnerability to fix. Examples:
  - "SQL injection in the search function"
  - "XSS in the comment display"
  - "Path traversal in the file download endpoint"
  - "Insecure deserialization in the session handler"
  - "Hardcoded credentials in the database config"
  - "Missing authorization check on the admin endpoint"
  - "Weak password hashing with MD5"
- **Additional context** (optional): Framework, deployment environment, constraints on the fix

## Process

1. **Vulnerability confirmation** -- Analyze the provided code to confirm the vulnerability exists and understand its exact nature. If the code is not actually vulnerable, explain why.

2. **Root cause identification** -- Determine the fundamental cause:
   - Is it a missing control? (no authorization check)
   - Is it a wrong API choice? (string concatenation instead of parameterized query)
   - Is it a configuration issue? (security feature disabled)
   - Is it a logic flaw? (checking condition incorrectly)
   - Is it a design issue? (architecture that makes security hard)

3. **Impact assessment** -- Explain what an attacker can achieve by exploiting this vulnerability:
   - Data theft, modification, or destruction
   - Authentication bypass or privilege escalation
   - Remote code execution
   - Denial of service
   - Information disclosure

4. **Fix implementation** -- Apply the minimum change that correctly fixes the vulnerability:
   - Use the framework's recommended secure pattern
   - Prefer built-in security features over custom implementations
   - Maintain code style and readability
   - Do not introduce new issues while fixing the original

5. **Fix verification** -- Provide concrete verification steps:
   - Test cases that confirm the vulnerability is fixed
   - Payloads that should now be blocked
   - Regression tests to prevent reintroduction
   - Edge cases to verify

6. **Defense-in-depth recommendations** -- Suggest additional layers of protection beyond the immediate fix

## Output

```
## Vulnerability Fix Report

### Vulnerability Details
**Class**: [vulnerability type]
**CWE**: [CWE-xxx: name]
**Severity**: [Critical/High/Medium/Low]
**Location**: [file:line]

### Root Cause
[Why this vulnerability exists -- the fundamental issue, not just the symptom]

### Impact
[What an attacker can do if this is exploited]

### Original Vulnerable Code
```[language]
// The vulnerable code with the dangerous pattern highlighted
```

**Attack example**:
```
[Concrete malicious input and what it does]
```

### Fixed Code
```[language]
// The corrected code
```

### Why This Fix Works
[Explanation of the security mechanism -- not just "it escapes the input" but why parameterization separates code from data at the protocol level]

### Verification
**Test case 1**: [Input that previously exploited the vulnerability]
**Expected result**: [How the fixed code handles it safely]

**Test case 2**: [Edge case]
**Expected result**: [Correct behavior]

**Regression test**:
```[language]
// Automated test to prevent reintroduction
```

### Defense-in-Depth
[Additional protective measures beyond the immediate fix]

### Related Code to Check
[Other locations in the codebase that may have the same pattern]
```
