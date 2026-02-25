# Mobile Crypto Patterns

> Secure cryptographic implementation patterns for Android and iOS, covering key storage, data-at-rest encryption, transport security, and common mobile crypto pitfalls.

## Knowledge Base

### Platform Crypto Primitives

Mobile platforms provide hardware-backed cryptographic capabilities that should always be preferred over software-only implementations.

**Android Keystore System**:
- Hardware-backed key storage (TEE or StrongBox on supported devices)
- Keys never leave the secure hardware in plaintext
- Supports key use restrictions (user authentication required, time-based validity)
- Supports AES, RSA, EC, HMAC operations
- Key attestation for verifying hardware backing

**iOS Secure Enclave**:
- Hardware-backed key storage in dedicated security coprocessor
- Supports P-256 elliptic curve operations natively
- Keys bound to device, cannot be exported
- Biometric-gated key access through LocalAuthentication + Keychain
- CryptoKit provides modern Swift API for crypto operations

### Symmetric Encryption

**Recommended**: AES-256-GCM (authenticated encryption, provides confidentiality + integrity)

**Android implementation**:
```kotlin
// Generate key in Keystore
val keyGenerator = KeyGenerator.getInstance(
    KeyProperties.KEY_ALGORITHM_AES, "AndroidKeyStore"
)
keyGenerator.init(KeyGenParameterSpec.Builder("encryption_key",
    KeyProperties.PURPOSE_ENCRYPT or KeyProperties.PURPOSE_DECRYPT)
    .setBlockModes(KeyProperties.BLOCK_MODE_GCM)
    .setEncryptionPaddings(KeyProperties.ENCRYPTION_PADDING_NONE)
    .setKeySize(256)
    .build())
val secretKey = keyGenerator.generateKey()

// Encrypt
val cipher = Cipher.getInstance("AES/GCM/NoPadding")
cipher.init(Cipher.ENCRYPT_MODE, secretKey)
val iv = cipher.iv // Save this with the ciphertext
val ciphertext = cipher.doFinal(plaintext)

// Decrypt
cipher.init(Cipher.DECRYPT_MODE, secretKey, GCMParameterSpec(128, iv))
val decrypted = cipher.doFinal(ciphertext)
```

**iOS implementation**:
```swift
import CryptoKit

// Generate key (for Keychain storage, wrap in SecKey)
let key = SymmetricKey(size: .bits256)

// Encrypt with AES-GCM
let sealedBox = try AES.GCM.seal(plaintext, using: key)
let combined = sealedBox.combined! // nonce + ciphertext + tag

// Decrypt
let sealedBox = try AES.GCM.SealedBox(combined: combined)
let decrypted = try AES.GCM.open(sealedBox, using: key)
```

### Key Derivation from Passwords

When encrypting with a user-provided password, derive a cryptographic key using a proper KDF.

**Recommended**: Argon2id (preferred), PBKDF2-SHA256 with 600,000+ iterations (OWASP 2023 recommendation)

```kotlin
// Android - PBKDF2
val factory = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA256")
val spec = PBEKeySpec(password, salt, 600_000, 256)
val key = factory.generateSecret(spec)

// Salt: 16+ bytes from SecureRandom, stored alongside ciphertext
val salt = ByteArray(16)
SecureRandom().nextBytes(salt)
```

```swift
// iOS - PBKDF2 via CommonCrypto or use Argon2 library
let password = Array(password.utf8)
let salt = Array(repeating: UInt8(0), count: 16)
// Fill salt from SecRandomCopyBytes
SecRandomCopyBytes(kSecRandomDefault, salt.count, &salt)

var derivedKey = Array(repeating: UInt8(0), count: 32)
CCKeyDerivationPBKDF(
    CCPBKDFAlgorithm(kCCPBKDF2),
    password, password.count,
    salt, salt.count,
    CCPBKDFAlgorithm(kCCPRFHmacAlgSHA256),
    600_000,
    &derivedKey, derivedKey.count
)
```

### Transport Security

**TLS Configuration**:
- Minimum TLS 1.2, prefer TLS 1.3
- Strong cipher suites only (ECDHE key exchange, AES-GCM or ChaCha20-Poly1305)
- Certificate validation enabled (never override to trust all)
- Certificate pinning for first-party APIs

**Certificate Pinning approaches** (in order of preference):
1. Public key pinning (survives certificate renewal)
2. Certificate pinning (requires update on renewal)
3. CA pinning (pins the issuing CA, most flexible)

Always include backup pins and a mechanism to update pins without app update (remote config with its own integrity verification).

### Random Number Generation

**Critical rule**: Always use the platform CSPRNG. Never use `java.util.Random`, `Math.random()`, `rand()`, or `arc4random()` (deprecated) for security-sensitive values.

**Android**: `java.security.SecureRandom` (backed by `/dev/urandom`)
**iOS**: `SecRandomCopyBytes` or `CryptoKit`'s built-in random generation

```kotlin
// Android
val random = SecureRandom()
val nonce = ByteArray(12)
random.nextBytes(nonce)
```

```swift
// iOS
var nonce = [UInt8](repeating: 0, count: 12)
let status = SecRandomCopyBytes(kSecRandomDefault, nonce.count, &nonce)
guard status == errSecSuccess else { /* handle error */ }
```

## Patterns

### Pattern: Encrypted Database (Android with SQLCipher)
```kotlin
// SQLCipher provides transparent AES-256 encryption for SQLite
val passphrase = getOrCreateDatabaseKey() // From Android Keystore
val database = SQLiteDatabase.openOrCreateDatabase(
    databaseFile, passphrase, null, null
)
// Key stored in Keystore, never hardcoded
// Database file encrypted at rest, decrypted in memory during use
```

### Pattern: Encrypted Database (iOS with SQLCipher)
```swift
// Or use Core Data with NSPersistentStoreDescription options
let options = [
    NSPersistentStoreFileProtectionKey: FileProtectionType.complete
]
// For SQLCipher, set the key via PRAGMA
sqlite3_exec(db, "PRAGMA key = '\(retrieveKeyFromKeychain())'", nil, nil, nil)
```

### Pattern: Secure Token Storage
Store authentication tokens in the most secure available mechanism, not in general-purpose storage.

**Android priority**: AndroidKeystore-encrypted storage > EncryptedSharedPreferences > (never) SharedPreferences
**iOS priority**: Keychain with kSecAttrAccessibleWhenUnlockedThisDeviceOnly > (never) NSUserDefaults

### Pattern: Biometric-Gated Decryption
The correct pattern binds biometric authentication to a cryptographic key operation, making it impossible to bypass biometric checks by hooking the result.

1. Generate AES key in Keystore/Secure Enclave with `setUserAuthenticationRequired(true)`
2. Encrypt sensitive data with this key
3. When decryption needed, create cipher and pass to BiometricPrompt
4. On success, receive unlocked cipher in callback
5. Use unlocked cipher to decrypt data

The key cannot be used without biometric authentication at the hardware level.

## Anti-Patterns

- **ECB mode**: Using AES in ECB mode. ECB encrypts identical plaintext blocks to identical ciphertext blocks, leaking patterns. Always use GCM (preferred) or CBC with HMAC.
- **Static IV/nonce**: Reusing the same initialization vector across encryptions with the same key. In GCM mode, nonce reuse is catastrophic (enables key recovery). Generate a fresh random nonce for every encryption operation.
- **Hardcoded encryption keys**: Embedding keys as string constants in source code. These are trivially extracted from decompiled APKs/IPAs. Use Android Keystore or iOS Keychain for key storage.
- **Custom crypto implementations**: Writing custom encryption, hashing, or key derivation algorithms instead of using platform-provided, audited implementations. Custom crypto is almost always broken.
- **MD5 or SHA-1 for integrity**: Using deprecated hash functions for data integrity or password hashing. Use SHA-256+ for integrity and Argon2/PBKDF2/bcrypt for passwords.
- **Ignoring crypto errors**: Catching and swallowing exceptions from cryptographic operations. Crypto failures indicate something is wrong (tampered data, wrong key, corrupted ciphertext). Handle them explicitly.
- **Storing derived keys**: Deriving a key from a password and then storing the derived key. This defeats the purpose of key derivation -- re-derive from the password each time.
- **Platform.random() for crypto**: Using non-cryptographic random number generators for IVs, nonces, tokens, or keys. Always use SecureRandom (Android) or SecRandomCopyBytes (iOS).

## References

- OWASP MASVS - CRYPTO controls -- https://mas.owasp.org/MASVS/05-MASVS-CRYPTO/
- OWASP Cryptographic Storage Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Cryptographic_Storage_Cheat_Sheet.html
- Android Keystore documentation -- https://developer.android.com/training/articles/keystore
- Apple CryptoKit documentation -- https://developer.apple.com/documentation/cryptokit
- Apple Keychain Services -- https://developer.apple.com/documentation/security/keychain_services
- NIST SP 800-132: Password-Based Key Derivation -- https://csrc.nist.gov/publications/detail/sp/800-132/final
- OWASP Password Storage Cheat Sheet -- https://cheatsheetseries.owasp.org/cheatsheets/Password_Storage_Cheat_Sheet.html
