# Crypto Algorithms

> Algorithm selection guide -- when to use what, key sizes, modes of operation, and the decision tree for cryptographic choices.

## Knowledge Base

### The Algorithm Decision Tree

```
What do you need to do?
|
├── Encrypt data (make it unreadable without a key)
|   ├── Symmetric (same key for encrypt/decrypt, fast)
|   |   ├── Prefer: AES-256-GCM or ChaCha20-Poly1305
|   |   ├── Alternative: XChaCha20-Poly1305 (extended nonce)
|   |   └── Never: ECB mode, DES, 3DES, RC4, Blowfish
|   |
|   └── Asymmetric (different keys, slower, for key exchange)
|       ├── Key exchange: X25519 (ECDH on Curve25519)
|       ├── Encryption: RSA-OAEP (2048+ bits), or hybrid with X25519
|       └── Never: RSA-PKCS1v15 for new systems
|
├── Sign data (prove authenticity and integrity)
|   ├── Prefer: Ed25519 (fast, short signatures, secure)
|   ├── Alternative: ECDSA P-256, RSA-PSS (3072+ bits)
|   └── Never: RSA-PKCS1v15 signatures, DSA
|
├── Hash data (one-way fingerprint)
|   ├── General purpose: SHA-256, SHA-384, SHA-512, BLAKE2b, BLAKE3
|   ├── Short output: SHA-256 truncated, BLAKE2s
|   └── Never for security: MD5, SHA-1 (collision attacks exist)
|
├── Hash passwords (intentionally slow, salt required)
|   ├── Prefer: Argon2id (memory-hard, GPU/ASIC resistant)
|   ├── Alternative: bcrypt (cost >= 12), scrypt
|   ├── Legacy acceptable: PBKDF2-HMAC-SHA256 (iterations >= 600000)
|   └── Never: plain SHA-256, MD5, SHA-1, single-round anything
|
├── Authenticate messages (verify integrity with a key)
|   ├── Prefer: HMAC-SHA-256
|   ├── Within AEAD: Poly1305 (built into ChaCha20-Poly1305, GCM)
|   └── Never: MAC-then-encrypt (use encrypt-then-MAC or AEAD)
|
└── Derive keys (from a master key or password)
    ├── From master key: HKDF-SHA-256 (extract-then-expand)
    ├── From password: Argon2id, scrypt, PBKDF2
    └── Never: Simple hash of password, XOR with constant
```

### Key Size Guidelines (2025+)

| Algorithm | Minimum | Recommended | NIST Post-2030 |
|-----------|---------|-------------|----------------|
| AES | 128 bits | 256 bits | 256 bits |
| RSA | 2048 bits | 3072 bits | 3072+ bits |
| ECDSA/ECDH | P-256 (128-bit security) | P-256 or P-384 | P-256+ |
| Ed25519 | 255 bits (fixed) | 255 bits (fixed) | 255 bits |
| X25519 | 255 bits (fixed) | 255 bits (fixed) | 255 bits |
| HMAC | 256 bits key minimum | 256 bits | 256 bits |

### Modes of Operation (Symmetric Encryption)

| Mode | Authentication | Parallelizable | Nonce Requirement | Verdict |
|------|---------------|----------------|-------------------|---------|
| **GCM** | Yes (AEAD) | Yes (encrypt + decrypt) | 96-bit, MUST be unique per key | Default choice |
| **ChaCha20-Poly1305** | Yes (AEAD) | Encrypt: no, Decrypt: yes | 96-bit, MUST be unique per key | Good for software-only |
| **XChaCha20-Poly1305** | Yes (AEAD) | Same as above | 192-bit (can be random!) | Best for nonce safety |
| **CTR** | No | Yes | Must be unique | Only with separate HMAC |
| **CBC** | No | Decrypt: yes | Random IV per message | Only with HMAC, prefer AEAD |
| **ECB** | No | Yes | None | NEVER USE -- patterns leak |

**Critical**: AES-GCM with a reused nonce reveals the XOR of plaintexts and forges authentication tags. If nonce uniqueness cannot be guaranteed (e.g., multiple writers), use XChaCha20-Poly1305 with random nonces.

## Patterns

### Pattern 1: Authenticated Encryption (libsodium / NaCl)

```python
from nacl.secret import SecretBox
from nacl.utils import random

# Generate a 256-bit key (store securely!)
key = random(SecretBox.KEY_SIZE)  # 32 bytes = 256 bits

# Encrypt (XSalsa20-Poly1305 -- authenticated encryption)
box = SecretBox(key)
plaintext = b"sensitive data"
encrypted = box.encrypt(plaintext)
# encrypted contains: nonce (24 bytes) + ciphertext + MAC (16 bytes)
# Nonce is generated automatically by libsodium from CSPRNG

# Decrypt (automatically verifies authentication tag)
decrypted = box.decrypt(encrypted)
assert decrypted == plaintext

# If ciphertext is tampered with, decrypt raises CryptoError
```

**Why this works**: libsodium's SecretBox uses XSalsa20-Poly1305, an AEAD cipher. It automatically generates a random nonce (24 bytes -- large enough to be random without collision risk), encrypts, and appends a Poly1305 authentication tag. Decryption verifies the tag before returning plaintext -- if the ciphertext was tampered with, decryption fails entirely. You cannot accidentally forget authentication.

### Pattern 2: Password Hashing (Argon2id)

```python
from argon2 import PasswordHasher

# Configure Argon2id with appropriate parameters
ph = PasswordHasher(
    time_cost=3,        # Number of iterations
    memory_cost=65536,  # 64 MB of memory
    parallelism=4,      # Number of threads
    hash_len=32,        # Output hash length
    salt_len=16,        # Salt length
    type=2,             # Argon2id (hybrid, recommended)
)

# Hash a password (salt is generated automatically)
password_hash = ph.hash("user-password-here")
# Result: $argon2id$v=19$m=65536,t=3,p=4$<salt>$<hash>

# Verify a password
try:
    ph.verify(password_hash, "user-password-here")
    # Password is correct

    # Check if rehashing is needed (parameters changed)
    if ph.check_needs_rehash(password_hash):
        new_hash = ph.hash("user-password-here")
        update_stored_hash(user_id, new_hash)

except argon2.exceptions.VerifyMismatchError:
    # Password is incorrect
    pass
```

**Why this works**: Argon2id is the winner of the Password Hashing Competition. It is memory-hard (requiring 64 MB of RAM makes GPU/ASIC brute-force expensive), time-hard (3 iterations add compute cost), and resistant to side-channel attacks (the "id" variant). The `check_needs_rehash` method enables parameter upgrades without user action -- when the user next logs in, their hash is upgraded to stronger parameters.

### Pattern 3: Digital Signatures (Ed25519)

```python
from nacl.signing import SigningKey, VerifyKey

# Generate signing keypair
signing_key = SigningKey.generate()  # Private key
verify_key = signing_key.verify_key  # Public key

# Sign a message
message = b"deploy version 2.3.1 to production"
signed = signing_key.sign(message)
# signed.signature = 64-byte Ed25519 signature
# signed.message = original message

# Verify the signature (anyone with the public key)
try:
    verify_key.verify(signed.message, signed.signature)
    # Signature is valid -- message was signed by the holder of signing_key
    # and has not been modified since signing
except nacl.exceptions.BadSignatureError:
    # Signature is invalid -- message was tampered with or signed by wrong key
    pass

# Export keys for storage (base64 or hex encoding)
public_key_bytes = verify_key.encode()   # 32 bytes
private_key_bytes = signing_key.encode()  # 32 bytes -- KEEP SECRET
```

**Why this works**: Ed25519 produces 64-byte signatures with 128-bit security using 32-byte keys. It is deterministic (no random nonce needed, eliminating a class of implementation errors), fast (8,000+ signatures per second), and has a simple API that is hard to misuse. It is the default choice for new signing applications.

### Pattern 4: Envelope Encryption

```python
# Envelope encryption: encrypt data with a random DEK,
# encrypt the DEK with a KEK stored in a KMS

import os
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

def encrypt_with_envelope(plaintext: bytes, kms_key_id: str) -> dict:
    """Encrypt data using envelope encryption pattern."""
    # 1. Generate a random Data Encryption Key (DEK)
    dek = os.urandom(32)  # 256-bit AES key

    # 2. Encrypt the data with the DEK (local, fast)
    nonce = os.urandom(12)  # 96-bit nonce for AES-GCM
    aesgcm = AESGCM(dek)
    ciphertext = aesgcm.encrypt(nonce, plaintext, None)

    # 3. Encrypt the DEK with the KEK via KMS (remote, slow, audited)
    encrypted_dek = kms_client.encrypt(
        KeyId=kms_key_id,
        Plaintext=dek
    )['CiphertextBlob']

    # 4. Securely erase the plaintext DEK from memory
    dek = b'\x00' * 32  # Overwrite (best effort in managed languages)

    # 5. Return the encrypted data and encrypted DEK
    return {
        'encrypted_dek': encrypted_dek,
        'nonce': nonce,
        'ciphertext': ciphertext,
    }

def decrypt_with_envelope(envelope: dict, kms_key_id: str) -> bytes:
    """Decrypt envelope-encrypted data."""
    # 1. Decrypt the DEK via KMS
    dek = kms_client.decrypt(
        KeyId=kms_key_id,
        CiphertextBlob=envelope['encrypted_dek']
    )['Plaintext']

    # 2. Decrypt the data with the DEK (local, fast)
    aesgcm = AESGCM(dek)
    plaintext = aesgcm.decrypt(
        envelope['nonce'],
        envelope['ciphertext'],
        None
    )

    return plaintext
```

**Why this works**: The data is encrypted locally with a random key (fast, no data leaves the system). Only the small DEK is encrypted by the KMS (slow, but the KMS never sees the data). The KEK never leaves the KMS boundary. This pattern is how AWS S3, Google Cloud Storage, and Azure Blob Storage implement server-side encryption.

## Anti-Patterns

### Anti-Pattern 1: ECB Mode

```python
# NEVER DO THIS
cipher = AES.new(key, AES.MODE_ECB)
ciphertext = cipher.encrypt(plaintext)
```

ECB encrypts each block independently. Identical plaintext blocks produce identical ciphertext blocks, revealing patterns. The famous "ECB penguin" image demonstrates this: the penguin is clearly visible in the ciphertext because large areas of identical pixels produce identical ciphertext blocks.

### Anti-Pattern 2: Using Encryption Without Authentication

```python
# BAD -- CBC without HMAC
cipher = AES.new(key, AES.MODE_CBC, iv)
ciphertext = cipher.encrypt(plaintext)
# An attacker can modify the ciphertext and it will decrypt to different plaintext
# (padding oracle attacks, bit flipping)
```

**Fix**: Always use AEAD modes (AES-GCM, ChaCha20-Poly1305) or encrypt-then-HMAC.

### Anti-Pattern 3: Reusing AES-GCM Nonces

GCM nonce reuse with the same key reveals the XOR of two plaintexts and allows authentication tag forgery. This is not a theoretical attack -- it is trivially exploitable. If you cannot guarantee nonce uniqueness (e.g., distributed systems), use XChaCha20-Poly1305 with random 192-bit nonces.

### Anti-Pattern 4: Using SHA-256 for Password Hashing

SHA-256 is fast by design -- billions of hashes per second on a GPU. This makes brute-force attacks trivial. Password hashing algorithms (Argon2id, bcrypt, scrypt) are intentionally slow and memory-intensive to make brute-force economically infeasible.

### Anti-Pattern 5: Storing Keys Next to Encrypted Data

Encrypting a database but storing the key in the same database (or the same server, or the same repo) provides no security. If the attacker gets the ciphertext, they get the key too. Keys must be stored in a separate system (KMS, HSM, Vault) with independent access controls.

## References

- [Latacora: Cryptographic Right Answers (2018)](https://latacora.micro.blog/2018/04/03/cryptographic-right-answers.html)
- [NIST SP 800-131A: Transitioning Algorithms](https://csrc.nist.gov/publications/detail/sp/800-131a/rev-2/final)
- [libsodium Documentation](https://doc.libsodium.org/)
- [Python cryptography Library](https://cryptography.io/en/latest/)
- [NIST Post-Quantum Cryptography](https://csrc.nist.gov/projects/post-quantum-cryptography)
- [Serious Cryptography (Book by Jean-Philippe Aumasson)](https://nostarch.com/seriouscrypto)
- [Crypto101 (Free Book)](https://www.crypto101.io/)
