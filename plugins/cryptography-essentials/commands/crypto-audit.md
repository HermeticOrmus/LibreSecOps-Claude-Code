# /crypto-audit

> Audit cryptographic implementations for algorithm selection, key management, and implementation errors.

## Trigger

Use when you need to:
- Review cryptographic algorithm choices in application code
- Audit password hashing implementations
- Evaluate encryption-at-rest or encryption-in-transit configurations
- Check for hardcoded keys, weak algorithms, or insecure modes
- Assess TLS/SSL configuration
- Review JWT token implementation
- Evaluate key management practices

## Input

One or more of:
- **Application code**: Source code using cryptographic libraries
- **Configuration files**: TLS configs (nginx, Apache, HAProxy), encryption configs
- **Architecture documentation**: Data flow diagrams showing where encryption is applied
- **Key management documentation**: Key storage, rotation, and access control policies
- **Specific scope**: Focus area (e.g., "password hashing", "TLS only", "encryption at rest")

## Process

### Phase 1: Algorithm Assessment

1. **Symmetric encryption**
   - Algorithm: AES-128/256 or ChaCha20 (acceptable), DES/3DES/RC4/Blowfish (unacceptable)
   - Mode: GCM or ChaCha20-Poly1305 (AEAD, correct), CBC without HMAC (vulnerable to padding oracle), ECB (broken for all practical purposes)
   - Nonce/IV: Generated with CSPRNG, never reused with the same key (GCM nonce reuse is catastrophic)

2. **Asymmetric encryption and signing**
   - RSA key size: >= 2048 bits (acceptable), >= 3072 bits (recommended for new systems)
   - RSA padding: OAEP for encryption (correct), PKCS#1 v1.5 (vulnerable to Bleichenbacher), PSS for signatures (correct)
   - ECC: P-256 or P-384 (NIST curves), Curve25519/Ed25519 (modern preferred)

3. **Hashing**
   - General purpose: SHA-256 or SHA-3 (correct), MD5 or SHA-1 (broken for collision resistance)
   - Password hashing: Argon2id (best), bcrypt (good), scrypt (good), PBKDF2-SHA256 (acceptable)
   - Password hashing with SHA-256/MD5/SHA-1 alone (CRITICAL -- not a password hash)

4. **Key derivation**
   - HKDF for deriving subkeys from a master key
   - Argon2id or PBKDF2 for password-to-key derivation
   - Custom key derivation (likely insecure)

### Phase 2: Implementation Review

5. **Random number generation**
   - CSPRNG used? (`/dev/urandom`, `crypto.getRandomValues()`, `secrets.token_bytes()`, `crypto/rand`)
   - Weak PRNG used? (`Math.random()`, `random.random()`, `rand()` -- NOT cryptographically secure)

6. **Key handling in code**
   - Hardcoded keys or secrets in source code
   - Keys in environment variables (acceptable for injection, but not for storage)
   - Keys in configuration files without encryption
   - Key material in logs (accidental logging of secrets)

7. **Comparison operations**
   - Timing-safe comparison for authentication tokens, HMAC verification, password hash comparison
   - Regular string comparison (`==`, `===`, `.equals()`) leaks timing information

8. **Error handling**
   - Cryptographic errors revealed to users (padding errors, decryption failures)
   - Different error messages for different failure modes (oracle)

### Phase 3: TLS Assessment

9. **Protocol and cipher configuration**
   - Minimum TLS version (1.2 required, 1.3 preferred)
   - Forward secrecy (ECDHE required)
   - AEAD cipher suites (AES-GCM, ChaCha20-Poly1305)
   - Certificate chain completeness
   - HSTS enabled with appropriate max-age

10. **Certificate management**
    - Certificate expiration monitoring
    - Automated renewal (ACME/certbot)
    - Certificate pinning (if used, has rotation plan?)
    - Private key protection (file permissions, HSM for high-value)

### Phase 4: Key Management

11. **Key lifecycle**
    - Key generation: Hardware RNG, software CSPRNG, or key management service
    - Key storage: HSM, KMS (AWS KMS, GCP KMS, Azure Key Vault), encrypted file, plaintext file (CRITICAL)
    - Key rotation: Policy defined, automated or manual, rotation period
    - Key revocation: Process for compromised keys
    - Key destruction: Secure deletion, crypto-shredding for data disposal

12. **Envelope encryption** (if applicable)
    - Data encrypted with Data Encryption Key (DEK)
    - DEK encrypted with Key Encryption Key (KEK)
    - KEK managed by KMS or HSM
    - Key hierarchy documented

## Output

```
## Cryptographic Audit Results

### Scope
- System: [System/application audited]
- Components: [What was reviewed]
- Date: [Assessment date]

### Summary
| Category | Critical | High | Medium | Low | Pass |
|----------|----------|------|--------|-----|------|
| Algorithms |         |      |        |     |      |
| Implementation |     |      |        |     |      |
| Key Management |     |      |        |     |      |
| TLS        |         |      |        |     |      |

### Algorithm Inventory
| Purpose | Algorithm | Key Size | Mode | Status |
|---------|-----------|----------|------|--------|
| Data encryption | AES | 256 | GCM | OK |
| Password hash | SHA-256 | N/A | N/A | CRITICAL |
| Signing | RSA | 2048 | PKCS#1 v1.5 | HIGH |
| ... | ... | ... | ... | ... |

### Findings (by severity)

#### Critical
[Findings with specific code-level remediation]

#### High
[Findings]

### Key Management Assessment
- Generation: [Method and assessment]
- Storage: [Location and assessment]
- Rotation: [Policy and assessment]
- Access control: [Who can access keys]

### Recommendations
1. [Replace [algorithm] with [algorithm] -- [reason]]
2. [Migrate key storage to [solution]]
3. [Implement [control]]

### Post-Quantum Considerations
[Assessment of long-term data protection needs and PQC readiness]
```
