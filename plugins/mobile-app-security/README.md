# Mobile App Security Plugin

> Mobile application security testing and secure development guidance based on OWASP MASVS and MASTG, covering both Android and iOS platforms.

## Overview

The Mobile App Security plugin provides Claude Code with comprehensive expertise in evaluating and improving the security posture of mobile applications. It is grounded in the OWASP Mobile Application Security Verification Standard (MASVS) v2.0 and the Mobile Application Security Testing Guide (MASTG), the industry-standard frameworks for mobile application security.

Mobile applications present a unique attack surface. Unlike web applications where the server controls most logic, mobile apps distribute significant logic, data storage, and cryptographic operations to a device the user (and attacker) physically controls. This creates categories of risk that do not exist in traditional web security: insecure local storage, improper platform API usage, insufficient binary protections, and client-side authentication bypasses.

This plugin addresses both platforms (Android and iOS) and covers the full lifecycle from secure architecture design through code review, testing, and hardening. It is intended for developers building mobile apps, security engineers auditing them, and architects designing secure mobile architectures.

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Mobile Security Tester | `agents/mobile-security-tester.md` | Systematic security testing against OWASP MASVS/MASTG categories. Assesses storage, crypto, authentication, network, platform interaction, code quality, and resilience. |
| Mobile Code Reviewer | `agents/mobile-code-reviewer.md` | Platform-specific secure code review for Android (Kotlin/Java) and iOS (Swift/Objective-C). Identifies insecure API usage, improper data handling, and missing security controls. |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/mobile-sec-audit` | `commands/mobile-sec-audit.md` | Structured security audit of a mobile application against MASVS categories, producing findings with severity ratings and remediation guidance. |
| `/mobile-hardening` | `commands/mobile-hardening.md` | Generate a platform-specific hardening checklist for an Android or iOS application, covering binary protections, data storage, network security, and anti-tampering. |

### Skills

| Skill | Directory | Purpose |
|-------|-----------|---------|
| OWASP MASVS | `skills/owasp-masvs/SKILL.md` | Complete reference for the Mobile Application Security Verification Standard v2.0, including all control groups, verification levels, and testing approaches. |
| Mobile Crypto Patterns | `skills/mobile-crypto-patterns/SKILL.md` | Secure cryptographic implementation patterns for mobile platforms, covering key storage, data-at-rest encryption, transport security, and common crypto pitfalls. |

## Usage

### Security Audit

Run `/mobile-sec-audit` providing details about the mobile application (platform, architecture, key features, authentication model). The command will walk through each MASVS category systematically.

### Code Review

Activate the `mobile-code-reviewer` agent when reviewing Android or iOS source code. Provide code files or snippets, and the agent will identify platform-specific security issues with explanations and fixes.

### Hardening

Use `/mobile-hardening` before release to generate a comprehensive hardening checklist. Specify the platform (Android/iOS) and the application's risk profile (financial, healthcare, general consumer) to get appropriately scoped recommendations.

### Deep Testing Guidance

Activate the `mobile-security-tester` agent for interactive testing sessions. The agent will guide dynamic testing with tools like Frida, objection, and Burp Suite, interpreting results and recommending next steps.

## Key Concepts

- **Client-side trust boundary**: The device is hostile territory. Any data stored, logic executed, or secrets embedded on the device can be extracted by a motivated attacker with physical access or a jailbroken/rooted device.
- **Platform security features**: Both Android and iOS provide security primitives (Keystore/Keychain, certificate pinning APIs, biometric authentication). Using them correctly is the baseline; most vulnerabilities come from not using them or using them incorrectly.
- **MASVS verification levels**: MASVS-L1 is the baseline for all apps. MASVS-L2 adds defense-in-depth for apps handling sensitive data. The resilience controls (anti-tampering, anti-reversing) apply to apps where client-side protection is a business requirement.

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `api-security-testing` | Mobile apps consume APIs. Secure the backend alongside the client. |
| `secure-coding-practices` | General secure coding principles apply to mobile development. |
| `cryptography-essentials` | Deep cryptographic knowledge for implementing mobile crypto correctly. |
| `threat-modeling` | Model mobile-specific threats (device theft, MITM, reverse engineering) before testing. |
| `penetration-testing` | Mobile pentest methodology builds on this plugin's security knowledge. |

## Methodology

Mobile security assessment follows the OWASP MASTG structure:

1. **Architecture and design review** -- Identify sensitive data flows, trust boundaries, third-party dependencies
2. **Data storage testing** -- Local databases, SharedPreferences/NSUserDefaults, file system, clipboard, logs, backups
3. **Cryptography assessment** -- Algorithm selection, key management, random number generation, crypto API usage
4. **Authentication and authorization** -- Local auth, biometric implementation, session handling, server-side validation
5. **Network communication** -- TLS configuration, certificate validation, certificate pinning, cleartext traffic detection
6. **Platform interaction** -- IPC mechanisms, WebView security, deep links/URL schemes, permission model
7. **Code quality and resilience** -- Obfuscation, anti-tampering, root/jailbreak detection, debugger detection
