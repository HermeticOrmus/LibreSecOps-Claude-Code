# /mobile-sec-audit

> Structured security audit of a mobile application against OWASP MASVS categories, producing prioritized findings with platform-specific remediation.

## Trigger

Use when you need to assess the security posture of an Android or iOS application. Appropriate for:
- Pre-release security assessment
- Periodic security review of existing apps
- Compliance verification against MASVS
- Due diligence on acquired or third-party applications
- Post-incident review of a mobile application

## Input

Provide as much of the following as available:

- **Platform**: Android, iOS, or cross-platform (React Native, Flutter, Xamarin)
- **Application purpose**: What the app does, what data it handles
- **Risk profile**: Financial, healthcare, general consumer, enterprise
- **Source code** or decompiled code (preferred for deep review)
- **APK/IPA file** information (package name, permissions, manifest)
- **Architecture description**: Backend API, authentication method, third-party services
- **AndroidManifest.xml** or **Info.plist** contents
- **Network Security Config** (Android) or **ATS configuration** (iOS)
- **Previous assessment results** if this is a reassessment

At minimum, provide the platform and application purpose. More context enables more specific findings.

## Process

The audit follows OWASP MASVS v2.0 control groups systematically:

1. **MASVS-STORAGE** -- Data Storage and Privacy
   - Review local storage mechanisms (databases, preferences, files)
   - Check for sensitive data in logs, clipboard, backups, screenshots
   - Verify proper use of platform secure storage (Keystore/Keychain)
   - Test data exposure through IPC mechanisms
   - Assess third-party analytics/crash reporting data leakage

2. **MASVS-CRYPTO** -- Cryptography
   - Verify algorithm selection (no MD5, SHA-1, DES, RC4, ECB mode)
   - Check key generation (proper entropy, platform CSPRNG)
   - Assess key storage (hardware-backed Keystore/Secure Enclave)
   - Review crypto implementation for common pitfalls (static IVs, key reuse)
   - Verify certificate validation in custom TrustManagers/URLSession delegates

3. **MASVS-AUTH** -- Authentication and Authorization
   - Review local authentication (biometric binding to crypto operations)
   - Check session management (token storage, expiry, refresh)
   - Verify server-side enforcement (client checks not bypassable)
   - Test step-up authentication for sensitive operations
   - Assess credential storage and auto-fill behavior

4. **MASVS-NETWORK** -- Network Communication
   - Verify TLS configuration (minimum version, cipher suites)
   - Check certificate pinning implementation and failure behavior
   - Test for cleartext traffic exceptions
   - Review custom certificate validation code
   - Assess WebSocket and other non-HTTP protocol security

5. **MASVS-PLATFORM** -- Platform Interaction
   - Review IPC security (intents, content providers, URL schemes, universal links)
   - Check WebView configuration (JavaScript, file access, mixed content)
   - Assess deep link/URL scheme validation
   - Review permission model (minimum necessary permissions)
   - Test for tapjacking/overlay attack protection (Android)

6. **MASVS-CODE** -- Code Quality
   - Check for debugging features in release builds
   - Review error handling for information disclosure
   - Assess third-party library versions for known CVEs
   - Verify code signing and integrity mechanisms
   - Review for memory safety issues (native code)

7. **MASVS-RESILIENCE** -- Resilience Against Reverse Engineering (if applicable)
   - Assess obfuscation (code, string, control flow)
   - Check root/jailbreak detection and response
   - Review debugger detection mechanisms
   - Test integrity verification (file checksums, signature verification)
   - Evaluate anti-tampering measures

## Output

```
## Mobile Security Audit Report

**Application**: [name]
**Platform**: [Android/iOS/Cross-platform]
**Version**: [version]
**MASVS Level**: [L1/L2/L2+R]
**Date**: [assessment date]

### Executive Summary
[2-3 paragraphs summarizing overall security posture, critical issues, and key recommendations]

### Risk Dashboard
| Category | Controls Tested | Passed | Failed | N/A |
|----------|----------------|--------|--------|-----|
| STORAGE | [n] | [n] | [n] | [n] |
| CRYPTO | [n] | [n] | [n] | [n] |
| AUTH | [n] | [n] | [n] | [n] |
| NETWORK | [n] | [n] | [n] | [n] |
| PLATFORM | [n] | [n] | [n] | [n] |
| CODE | [n] | [n] | [n] | [n] |
| RESILIENCE | [n] | [n] | [n] | [n] |

### Critical and High Findings
[Detailed findings with remediation]

### Medium and Low Findings
[Detailed findings with remediation]

### Positive Observations
[Security controls implemented correctly -- important for balanced reporting]

### Remediation Priority
1. [Most urgent fix with effort estimate]
2. [Second priority]
...

### Appendix: Test Cases Executed
[MASTG test case references for reproducibility]
```
