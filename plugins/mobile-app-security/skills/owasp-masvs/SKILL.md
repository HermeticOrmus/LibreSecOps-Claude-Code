# OWASP MASVS

> Complete reference for the OWASP Mobile Application Security Verification Standard (MASVS) v2.0 and its relationship to the Mobile Application Security Testing Guide (MASTG).

## Knowledge Base

### MASVS v2.0 Structure

MASVS v2.0 (released 2023) reorganized the standard into security control groups, replacing the previous L1/L2/R verification levels with a more flexible model. Each control group contains specific controls that are either baseline (applicable to all apps) or defense-in-depth (for high-risk apps).

### Control Groups

**MASVS-STORAGE: Data Storage and Privacy**

Controls for protecting sensitive data stored on the device.

| Control | Description | Baseline |
|---------|-------------|----------|
| MASVS-STORAGE-1 | The app securely stores sensitive data | Yes |
| MASVS-STORAGE-2 | The app prevents leakage of sensitive data | Yes |

Key areas tested:
- Local databases (SQLite, Realm, CoreData) -- encrypted vs cleartext
- Shared Preferences (Android) / NSUserDefaults (iOS) -- no sensitive data
- Keystore (Android) / Keychain (iOS) -- proper access control classes
- File system permissions -- no world-readable sensitive files
- System logs -- no sensitive data logged (especially in production)
- Clipboard -- cleared on sensitive field focus loss or app background
- Backups -- sensitive data excluded from iCloud/Android backup
- Screenshots -- prevented on screens displaying sensitive data
- Third-party SDKs -- data shared with analytics/crash reporting reviewed

**MASVS-CRYPTO: Cryptography**

Controls for cryptographic implementations.

| Control | Description | Baseline |
|---------|-------------|----------|
| MASVS-CRYPTO-1 | The app employs current strong cryptography and uses it according to industry best practices | Yes |
| MASVS-CRYPTO-2 | The app performs key management according to industry best practices | Yes |

Approved algorithms (as of MASVS v2.0):
- Symmetric encryption: AES-128/256 in GCM or CBC mode (with HMAC)
- Asymmetric encryption: RSA-2048+, ECDSA with P-256 or higher
- Hashing: SHA-256 or stronger
- Key derivation: PBKDF2 (100,000+ iterations), Argon2, scrypt
- Random number generation: Platform CSPRNG only (SecureRandom on Android, SecRandomCopyBytes on iOS)

Deprecated/prohibited: MD5, SHA-1 (for security), DES, 3DES, RC4, ECB mode, hardcoded keys, static IVs

**MASVS-AUTH: Authentication and Authorization**

Controls for authentication and session management.

| Control | Description | Baseline |
|---------|-------------|----------|
| MASVS-AUTH-1 | The app uses secure authentication and authorization protocols and follows the relevant best practices | Yes |
| MASVS-AUTH-2 | The app performs local authentication securely | Yes |
| MASVS-AUTH-3 | The app secures sensitive operations with additional authentication | Defense-in-depth |

Key requirements:
- Biometric auth must gate a cryptographic operation (not just a boolean check)
- Session tokens stored in secure storage (Keychain/Keystore), not SharedPreferences/NSUserDefaults
- Token refresh mechanisms with proper expiry
- Server-side session validation (client-side checks are supplementary only)
- Step-up authentication for sensitive operations (payments, profile changes)

**Android BiometricPrompt correct pattern**:
```kotlin
val biometricPrompt = BiometricPrompt(this, executor,
    object : BiometricPrompt.AuthenticationCallback() {
        override fun onAuthenticationSucceeded(result: AuthenticationResult) {
            // Use result.cryptoObject to decrypt/sign -- NOT just proceed
            val cipher = result.cryptoObject?.cipher
            val decrypted = cipher?.doFinal(encryptedToken)
        }
    })

val cryptoObject = BiometricPrompt.CryptoObject(cipher)
biometricPrompt.authenticate(promptInfo, cryptoObject) // Crypto-bound
```

**MASVS-NETWORK: Network Communication**

Controls for network communication security.

| Control | Description | Baseline |
|---------|-------------|----------|
| MASVS-NETWORK-1 | The app secures all network traffic according to the current best practices | Yes |
| MASVS-NETWORK-2 | The app performs identity pinning for all remote endpoints under the developer's control | Defense-in-depth |

Key requirements:
- TLS 1.2 minimum, TLS 1.3 preferred
- No cleartext HTTP traffic (enforce via Network Security Config / ATS)
- Certificate pinning with backup pins and rotation strategy
- Proper certificate validation (no blanket trust of all certificates)
- Custom TrustManager/URLSessionDelegate implementations reviewed for bypasses

**Android Network Security Config**:
```xml
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <base-config cleartextTrafficPermitted="false">
        <trust-anchors>
            <certificates src="system" />
        </trust-anchors>
    </base-config>
    <domain-config>
        <domain includeSubdomains="true">api.example.com</domain>
        <pin-set expiration="2025-01-01">
            <pin digest="SHA-256">base64encodedSPKI=</pin>
            <pin digest="SHA-256">backupPinBase64=</pin>
        </pin-set>
    </domain-config>
</network-security-config>
```

**MASVS-PLATFORM: Platform Interaction**

Controls for secure use of platform features.

| Control | Description | Baseline |
|---------|-------------|----------|
| MASVS-PLATFORM-1 | The app uses IPC mechanisms securely | Yes |
| MASVS-PLATFORM-2 | The app uses WebViews securely | Yes |
| MASVS-PLATFORM-3 | The app uses the user interface securely | Yes |

Key areas:
- Android: exported components require intent validation, content providers need proper permissions, broadcast receivers filtered
- iOS: URL scheme handlers must validate input, universal links preferred over custom schemes
- WebViews: JavaScript disabled unless required, file access disabled, no JavaScript bridge to sensitive native functions without validation
- UI: FLAG_SECURE on sensitive screens (Android), overlay protection, input validation on all user-facing fields

**MASVS-CODE: Code Quality and Build Settings**

Controls for code quality and secure build configuration.

| Control | Description | Baseline |
|---------|-------------|----------|
| MASVS-CODE-1 | The app requires an up-to-date platform version | Yes |
| MASVS-CODE-2 | The app has a mechanism for enforcing app updates | Defense-in-depth |
| MASVS-CODE-3 | The app only uses software components without known vulnerabilities | Yes |
| MASVS-CODE-4 | The app validates and sanitizes all untrusted inputs | Yes |

**MASVS-RESILIENCE: Resilience Against Reverse Engineering and Tampering**

Controls for apps that need client-side protection (DRM, financial, games with anti-cheat).

| Control | Description | Baseline |
|---------|-------------|----------|
| MASVS-RESILIENCE-1 | The app validates the integrity of the platform | Defense-in-depth |
| MASVS-RESILIENCE-2 | The app implements anti-tampering mechanisms | Defense-in-depth |
| MASVS-RESILIENCE-3 | The app implements anti-static analysis mechanisms | Defense-in-depth |
| MASVS-RESILIENCE-4 | The app implements anti-dynamic analysis mechanisms | Defense-in-depth |

Note: Resilience controls are NOT a substitute for proper server-side security. They raise the bar for attackers but cannot prevent determined reverse engineering.

### MASTG Test Case Mapping

The Mobile Application Security Testing Guide (MASTG) provides specific test cases for each MASVS control. Test case IDs follow the format `MASTG-TEST-xxxx`.

Key test cases by category:
- Storage: Testing local storage, logs, backups, clipboard, third-party data sharing
- Crypto: Testing algorithm strength, key management, random number generation
- Auth: Testing biometric implementation, session handling, 2FA
- Network: Testing TLS configuration, certificate pinning, cleartext traffic
- Platform: Testing IPC, WebViews, deep links
- Code: Testing debug settings, dependency versions, input validation
- Resilience: Testing obfuscation, root detection, anti-debug, integrity checks

## Patterns

### Pattern: Secure Local Storage (Android)
```kotlin
// Use EncryptedSharedPreferences for key-value data
val masterKey = MasterKey.Builder(context)
    .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
    .build()

val securePrefs = EncryptedSharedPreferences.create(
    context, "secure_prefs", masterKey,
    EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
    EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
)

// Use Android Keystore for cryptographic keys
val keyGenerator = KeyGenerator.getInstance(
    KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore"
)
keyGenerator.init(KeyGenParameterSpec.Builder("my_key",
    KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
    .setUserAuthenticationRequired(true) // Require biometric to use key
    .build())
```

### Pattern: Secure Local Storage (iOS)
```swift
// Use Keychain for sensitive data
let query: [String: Any] = [
    kSecClass as String: kSecClassGenericPassword,
    kSecAttrAccount as String: "auth_token",
    kSecValueData as String: tokenData,
    kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
    kSecAttrAccessControl as String: accessControl // Biometric-gated
]
SecItemAdd(query as CFDictionary, nil)

// Use Data Protection for files
try data.write(to: fileURL, options: .completeFileProtection)
```

### Pattern: Certificate Pinning with Rotation
Always include at least two pins (current + backup) and set an expiration date. Have a remote kill-switch mechanism to disable pinning if certificates need emergency rotation.

## Anti-Patterns

- **Boolean biometric gate**: Checking `biometricPrompt.authenticate()` result as true/false without binding to a cryptographic operation. An attacker with Frida can hook and return true.
- **Storing tokens in SharedPreferences/NSUserDefaults**: These are plaintext XML/plist files accessible on rooted/jailbroken devices. Use EncryptedSharedPreferences or Keychain.
- **Trusting all certificates in TrustManager**: Implementing `X509TrustManager.checkServerTrusted()` as a no-op to "fix" development SSL errors, then shipping it to production.
- **Logging sensitive data**: Using `Log.d(TAG, "Token: $token")` during development without removing before release. Use BuildConfig.DEBUG guards.
- **Hardcoding API keys/secrets**: Embedding secrets in strings.xml, BuildConfig, or Info.plist. Use runtime key exchange or secure key management.
- **World-readable files**: Creating files with `MODE_WORLD_READABLE` or permissive file permissions that other apps can read.

## References

- OWASP MASVS v2.0 -- https://mas.owasp.org/MASVS/
- OWASP MASTG -- https://mas.owasp.org/MASTG/
- Android Security Documentation -- https://developer.android.com/topic/security
- Apple Platform Security Guide -- https://support.apple.com/guide/security/
- Android Keystore System -- https://developer.android.com/training/articles/keystore
- iOS Keychain Services -- https://developer.apple.com/documentation/security/keychain_services
- Network Security Config (Android) -- https://developer.android.com/training/articles/security-config
- App Transport Security (iOS) -- https://developer.apple.com/documentation/bundleresources/information_property_list/nsapptransportsecurity
