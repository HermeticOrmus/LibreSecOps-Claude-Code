# Beginner — security mindset

You're a developer entering security. The mindset shifts matter more than the tool list.

## The 5 mindset shifts

1. **Trust nothing by default.** Every input is suspect. Every dependency could be compromised. Every user could be malicious.
2. **Define the trust boundaries explicitly.** Most vulnerabilities live at boundaries (user → app, app → DB, internal → external).
3. **Assume breach.** Design assuming the perimeter has been crossed. Defense in depth, not defense at the edge.
4. **Make security verifiable.** "We implement authentication correctly" is unverifiable. "Auth check at line 47, unit test in test_auth.py" is.
5. **Threat-model before coding, not after.** A 2-hour threat model saves 6 months of incidents.

## Your first threat model

Walk the QUICK_START. Pick a real feature. Apply STRIDE. Score with DREAD. Pair each threat with a concrete mitigation.

The output is design decisions, not paperwork.

## OWASP Top 10 to know

1. Broken Access Control
2. Cryptographic Failures
3. Injection (SQL, command, LDAP, etc.)
4. Insecure Design
5. Security Misconfiguration
6. Vulnerable + Outdated Components
7. Identification + Authentication Failures
8. Software + Data Integrity Failures
9. Security Logging + Monitoring Failures
10. Server-Side Request Forgery

Read each in the OWASP cheat sheet. Be able to recognize each in code review.

## Next

- [Intermediate](intermediate.md) — DevSecOps integration, IR
- [Advanced](advanced.md) — red/blue exercises, compliance, zero-trust
