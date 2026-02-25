# Cryptography Essentials

> Algorithm selection guidance, key management lifecycle, TLS/SSL configuration, and encryption implementation patterns.

---

## Overview

Cryptography is the mathematical foundation of digital security. Every secure system depends on it -- TLS for transit encryption, AES for data at rest, bcrypt for password hashing, RSA/ECDSA for digital signatures, HMAC for message authentication. But cryptography is also the security domain where implementation errors are most catastrophic: a single wrong choice (ECB mode, MD5 for passwords, reused nonces) can completely invalidate the security guarantee.

This plugin does not teach you to implement cryptographic primitives -- that is a job for vetted libraries (libsodium, OpenSSL, BoringSSL). Instead, it teaches you to CHOOSE correctly: which algorithm for which purpose, which mode of operation, which key size, which library. It also covers key management -- the operational discipline that determines whether your encryption actually protects anything.

The golden rule of cryptography: **Do not invent your own.** Use established algorithms, vetted libraries, and standard protocols. Every "clever" homegrown crypto scheme has been broken.

---

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Crypto Advisor | `agents/crypto-advisor.md` | Guides algorithm selection, reviews cryptographic implementations, advises on key management |
| TLS Specialist | `agents/tls-specialist.md` | Configures and reviews TLS/SSL implementations, cipher suites, and certificate management |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/crypto-audit` | `commands/crypto-audit.md` | Audit cryptographic implementations for algorithm selection, key management, and implementation errors |

### Skills (Knowledge Bases)

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Crypto Algorithms | `skills/crypto-algorithms/` | Algorithm selection guide -- when to use which algorithm, key sizes, modes of operation |
| Key Management | `skills/key-management/` | Key lifecycle management, rotation, storage, and operational security |

---

## Usage

### Algorithm Selection

Activate `crypto-advisor` when choosing cryptographic algorithms for a new system. It guides you through the decision tree: symmetric vs asymmetric, encryption vs signing vs hashing, key sizes, and modes of operation.

### TLS Configuration

Activate `tls-specialist` when configuring TLS for web servers, APIs, or service-to-service communication. It covers cipher suite selection, certificate management, HSTS, and protocol version enforcement.

### Implementation Review

Use `/crypto-audit` to review existing cryptographic implementations for common errors: weak algorithms, insecure modes, improper key storage, or missing authentication.

### Reference

The skills directories contain decision-tree reference material for algorithm selection and key management lifecycle. Consult them when making cryptographic design decisions.

---

## Key Principles

1. **Never roll your own crypto.** Use established libraries (libsodium, OpenSSL, BoringSSL, WebCrypto API). Custom implementations are always weaker.
2. **Encryption without authentication is incomplete.** Use authenticated encryption (AES-GCM, ChaCha20-Poly1305, XChaCha20-Poly1305). AES-CBC without HMAC allows ciphertext manipulation.
3. **Key management is harder than encryption.** The algorithm is the easy part. Generating, storing, distributing, rotating, and revoking keys is where systems fail.
4. **Stronger than necessary is fine.** Using AES-256 when AES-128 would suffice costs almost nothing. Using RSA-4096 when 2048 would suffice costs a bit more. The regret of too-weak encryption is irreversible.
5. **Crypto ages.** Algorithms that are secure today may not be in 10 years. Design for algorithm agility -- the ability to swap algorithms without redesigning the system.

---

## Prerequisites

- Basic understanding of symmetric vs asymmetric cryptography
- Understanding of hashing vs encryption (one-way vs reversible)
- Familiarity with TLS handshake concepts (helpful but not required)

---

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `identity-access-management` | Authentication relies on cryptographic hashing and signing |
| `cloud-security-aws` | AWS KMS, S3 encryption, envelope encryption |
| `cloud-security-gcp` | Cloud KMS, CMEK, Cloud HSM |
| `cloud-security-azure` | Azure Key Vault, customer-managed keys |
| `secrets-management` | Operational management of secrets that include cryptographic keys |
| `web-application-security` | TLS configuration for web applications |

---

## References

- [NIST SP 800-57: Key Management Guidelines](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final)
- [NIST SP 800-131A: Transitioning Algorithms](https://csrc.nist.gov/publications/detail/sp/800-131a/rev-2/final)
- [Latacora: Cryptographic Right Answers](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html)
- [SSL Labs Server Test](https://www.ssllabs.com/ssltest/)
- [Mozilla SSL Configuration Generator](https://ssl-config.mozilla.org/)
- [libsodium Documentation](https://doc.libsodium.org/)
