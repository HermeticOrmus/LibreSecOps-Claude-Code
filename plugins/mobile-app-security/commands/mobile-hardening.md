# /mobile-hardening

> Generate a platform-specific hardening checklist for an Android or iOS application, covering data storage, network security, binary protections, and anti-tampering.

## Trigger

Use before releasing a mobile application to production, or when preparing a security hardening plan for an existing application. Particularly valuable for:
- Pre-release security hardening pass
- Responding to a penetration test report with hardening recommendations
- Upgrading an application from MASVS-L1 to MASVS-L2
- Adding resilience controls for apps with client-side IP protection needs

## Input

- **Platform**: Android or iOS (required)
- **Language/Framework**: Kotlin, Java, Swift, Objective-C, React Native, Flutter
- **Risk profile**: Financial/banking, healthcare, enterprise, general consumer
- **Current state**: What security controls are already in place (if known)
- **Target MASVS level**: L1 (baseline), L2 (defense-in-depth), L2+R (with resilience)
- **Specific concerns**: Any particular areas of focus

## Process

1. **Determine hardening scope** based on platform, risk profile, and target MASVS level

2. **Generate data storage hardening checklist**:
   - Migrate sensitive data to platform secure storage
   - Configure backup exclusions (android:allowBackup="false", excluded files on iOS)
   - Disable screenshot capture for sensitive screens
   - Clear clipboard on app background/foreground transitions
   - Configure logging to exclude sensitive data in release builds
   - Implement proper file permissions for app-created files

3. **Generate network security hardening checklist**:
   - Configure minimum TLS version (1.2+, prefer 1.3)
   - Implement certificate pinning (with backup pins and rotation plan)
   - Remove cleartext traffic exceptions
   - Configure ATS (iOS) or Network Security Config (Android)
   - Implement proper certificate validation in custom handlers

4. **Generate authentication hardening checklist**:
   - Bind biometric authentication to cryptographic operations
   - Implement secure session management with proper token storage
   - Add step-up authentication for sensitive operations
   - Configure auto-lock timeout for sensitive apps
   - Implement device binding where appropriate

5. **Generate platform-specific hardening**:
   - Android: exported component review, intent validation, content provider permissions, WebView hardening, tapjacking protection
   - iOS: URL scheme validation, universal links, Keychain access groups, data protection classes, ATS configuration

6. **Generate binary protection hardening** (for L2+R):
   - Code obfuscation configuration (ProGuard/R8, Swift symbol stripping)
   - Root/jailbreak detection implementation
   - Debugger detection
   - Integrity verification (checksum, signature)
   - Anti-tampering hooks

7. **Provide implementation code** for each checklist item in the target language

## Output

```
## Mobile Hardening Checklist

**Platform**: [Android/iOS]
**Target MASVS Level**: [L1/L2/L2+R]
**Risk Profile**: [profile]

### Data Storage Hardening
- [ ] **[CRITICAL]** [Item] — [Implementation guidance with code]
- [ ] **[HIGH]** [Item] — [Implementation guidance with code]
...

### Network Security Hardening
- [ ] **[CRITICAL]** [Item] — [Implementation guidance with code]
...

### Authentication Hardening
- [ ] [Items with implementation]

### Platform Interaction Hardening
- [ ] [Items with implementation]

### Binary Protection Hardening (L2+R only)
- [ ] [Items with implementation]

### Configuration Files

**[AndroidManifest.xml / Info.plist] recommended settings**:
[Complete secure configuration block]

**[Network Security Config / ATS] recommended settings**:
[Complete configuration]

**[ProGuard rules / build settings]**:
[Recommended build configuration]

### Verification Steps
[How to verify each hardening measure is effective]
```
