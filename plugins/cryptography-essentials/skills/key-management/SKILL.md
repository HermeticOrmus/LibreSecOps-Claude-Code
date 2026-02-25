# Key Management

> Key lifecycle management, rotation strategies, storage options, and operational security for cryptographic keys.

## Knowledge Base

### Key Lifecycle

Every cryptographic key goes through a lifecycle. Each phase has security requirements:

```
Generation → Distribution → Storage → Use → Rotation → Revocation → Destruction
    |            |             |        |        |           |            |
    v            v             v        v        v           v            v
  CSPRNG    Secure channel  Encrypted  Audit   New key    Notify       Crypto-
  or HSM    or KMS API      at rest    trail   replaces   relying      shred
                                                old       parties
```

### Key Types and Their Roles

| Key Type | Abbreviation | Purpose | Lifecycle |
|----------|-------------|---------|-----------|
| **Master Key** | MK | Protects other keys. Never used for data directly. | Years. Stored in HSM. Rarely rotated. |
| **Key Encryption Key** | KEK | Encrypts Data Encryption Keys (envelope encryption). | Months to years. Stored in KMS. |
| **Data Encryption Key** | DEK | Encrypts actual data. | Per-operation or per-session. Generated and used in memory. |
| **Signing Key** | SK | Creates digital signatures. | Months to years. Private key highly protected. |
| **TLS Private Key** | -- | Authenticates server in TLS handshake. | 1-2 years (certificate lifetime). |
| **API Key** | -- | Authenticates API clients. | 90 days recommended rotation. |
| **Session Key** | -- | Encrypts a single session (TLS, SSH). | Minutes to hours. Ephemeral. |

### Storage Security Hierarchy

Listed from most secure to least secure:

| Storage | Security Level | Use Case | Cost |
|---------|---------------|----------|------|
| **HSM (Hardware Security Module)** | Highest. Key never leaves the HSM boundary. FIPS 140-2/3 Level 3. | Master keys, CA keys, payment processing keys | $$$$ |
| **Cloud KMS** (AWS KMS, GCP KMS, Azure Key Vault) | High. Keys managed by cloud provider in HSMs. API-accessed. | KEKs, signing keys, envelope encryption | $$ |
| **Secrets Manager** (AWS Secrets Manager, HashiCorp Vault) | Medium-High. Encrypted storage with access control, rotation. | API keys, database passwords, service credentials | $$ |
| **Encrypted file on disk** | Medium. Only as secure as the encryption key and file permissions. | Development environments, backup keys | $ |
| **Environment variable** | Low. Visible in process listings, crash dumps, CI logs. | Injection point only (value comes from secrets manager). | Free |
| **Source code / config file** | NONE. Public to anyone with repo access. In git history forever. | NEVER | Free |

## Patterns

### Pattern 1: Key Rotation Strategy

```
Key Rotation Policy:

1. TLS Certificates
   - Rotation: Every 90 days (Let's Encrypt default)
   - Method: Automated via ACME/certbot
   - Verification: Monitor certificate expiry (alert at 30, 14, 7 days)

2. Data Encryption Keys (at-rest encryption)
   - Rotation: Annual, or on suspected compromise
   - Method: Re-encrypt with new key (or re-wrap DEK with new KEK)
   - Backward compatibility: Keep old key for decryption of old data

3. API Keys
   - Rotation: Every 90 days
   - Method: Generate new key, distribute, verify, revoke old key
   - Grace period: 7-day overlap where both old and new keys work

4. Signing Keys
   - Rotation: Annual
   - Method: Generate new keypair, publish new public key, sign with new key
   - Old signatures: Remain valid (verified against old public key)

5. Database Credentials
   - Rotation: Every 90 days
   - Method: Automated via secrets manager (AWS Secrets Manager, Vault)
   - Zero-downtime: Dual-credential support during rotation window
```

**Key rotation implementation (zero-downtime):**

```python
# Phase 1: Generate new key, store alongside old key
# Both keys are valid during the transition window
def rotate_encryption_key():
    new_key_id = kms.create_key(description="DEK v2")

    # Phase 2: New writes use new key, old key for reads
    config.set("active_encryption_key", new_key_id)
    config.set("decryption_keys", [new_key_id, old_key_id])

    # Phase 3: Background re-encryption of old data
    for record in get_records_encrypted_with(old_key_id):
        plaintext = decrypt(record.ciphertext, old_key_id)
        record.ciphertext = encrypt(plaintext, new_key_id)
        record.key_id = new_key_id
        record.save()

    # Phase 4: Retire old key (after confirming no data uses it)
    if count_records_encrypted_with(old_key_id) == 0:
        config.set("decryption_keys", [new_key_id])
        kms.schedule_key_deletion(old_key_id, waiting_period_days=30)
```

**Why this works**: Zero-downtime rotation requires a transition period where both keys are valid. New data is encrypted with the new key immediately. Old data is re-encrypted in the background. The old key is only retired after all data has been migrated and a waiting period has passed (in case of issues).

### Pattern 2: Envelope Encryption Architecture

```
┌─────────────────────────────────────────────┐
│                  Application                 │
│                                              │
│   1. Request DEK from KMS                    │
│   2. Encrypt data locally with DEK           │
│   3. Store encrypted data + encrypted DEK    │
│   4. Discard plaintext DEK from memory       │
└─────────────────────┬───────────────────────┘
                      │
                      │ API: Encrypt(DEK) / Decrypt(DEK)
                      │
┌─────────────────────▼───────────────────────┐
│            Key Management Service            │
│                                              │
│   - KEK stored in HSM (never exportable)     │
│   - Access controlled by IAM policies        │
│   - Every Encrypt/Decrypt call is logged     │
│   - Key rotation handled transparently       │
└─────────────────────────────────────────────┘
```

**Why envelope encryption:**
- **Performance**: Data is encrypted locally with symmetric AES (fast). Only the small DEK traverses the network to the KMS.
- **Key hierarchy**: The KEK in the KMS never touches data directly. Compromise of the application does not expose the KEK.
- **Audit trail**: Every DEK encryption/decryption is logged by the KMS, providing visibility into data access.
- **Rotation**: Rotating the KEK only requires re-wrapping the DEKs (small, fast), not re-encrypting all data.

### Pattern 3: Crypto-Shredding (Data Destruction via Key Deletion)

```python
# Crypto-shredding: destroy data by destroying its encryption key
# Used for: GDPR right-to-erasure, data retention compliance, tenant offboarding

def crypto_shred_tenant(tenant_id: str):
    """Destroy all tenant data by deleting their encryption key."""

    # Each tenant has a dedicated KEK
    tenant_key_id = get_tenant_key(tenant_id)

    # 1. Verify: all tenant data is encrypted with this key
    assert all_data_encrypted_with_key(tenant_id, tenant_key_id)

    # 2. Revoke key access immediately (no new decryptions)
    kms.disable_key(tenant_key_id)

    # 3. Log the shredding event for compliance
    audit_log.record({
        "action": "crypto_shred",
        "tenant_id": tenant_id,
        "key_id": tenant_key_id,
        "timestamp": datetime.utcnow().isoformat(),
        "reason": "tenant_offboarding"
    })

    # 4. Schedule key deletion (waiting period for recovery if needed)
    kms.schedule_key_deletion(
        key_id=tenant_key_id,
        waiting_period_days=30  # 7-30 days depending on KMS
    )

    # 5. Optionally: delete encrypted blobs asynchronously
    # (they are unreadable without the key, but deleting saves storage)
    schedule_async_deletion(tenant_id)
```

**Why this works**: If all data is encrypted with a tenant-specific key, deleting the key makes all the data permanently unrecoverable -- even if the encrypted blobs still exist on disk, in backups, or in log files. This satisfies GDPR Article 17 (right to erasure) without needing to hunt down every copy of the data.

### Pattern 4: Key Access Control (AWS KMS Example)

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AdminCanManageKey",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/KeyAdmin"
      },
      "Action": [
        "kms:Create*",
        "kms:Describe*",
        "kms:Enable*",
        "kms:List*",
        "kms:Put*",
        "kms:Update*",
        "kms:Revoke*",
        "kms:Disable*",
        "kms:Get*",
        "kms:Delete*",
        "kms:ScheduleKeyDeletion",
        "kms:CancelKeyDeletion"
      ],
      "Resource": "*"
    },
    {
      "Sid": "AppCanUseKey",
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::123456789012:role/ApplicationRole"
      },
      "Action": [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey"
      ],
      "Resource": "*"
    },
    {
      "Sid": "DenyDeleteWithoutApproval",
      "Effect": "Deny",
      "Principal": "*",
      "Action": "kms:ScheduleKeyDeletion",
      "Resource": "*",
      "Condition": {
        "NumericLessThan": {
          "kms:ScheduleKeyDeletionPendingWindowInDays": "30"
        }
      }
    }
  ]
}
```

**Why this works**: Separation of duties -- the KeyAdmin can manage key lifecycle but cannot use keys for encryption/decryption. The ApplicationRole can encrypt/decrypt but cannot manage or delete keys. The deny statement prevents scheduling key deletion with less than 30 days waiting period, providing a safety net against accidental or malicious key destruction.

## Anti-Patterns

### Anti-Pattern 1: Keys in Source Code

```python
# NEVER DO THIS
API_KEY = "sk-live-abc123def456ghi789"
ENCRYPTION_KEY = bytes.fromhex("deadbeefcafebabe...")
```

Keys in source code end up in git history (permanent), in logs, in backups, and in every developer's machine. Even if deleted, `git log -p` reveals them forever.

**Fix**: Use environment variables for injection, secrets managers for storage. Scan repos with tools like `trufflehog`, `gitleaks`, or `detect-secrets`.

### Anti-Pattern 2: No Key Rotation

Keys that never rotate accumulate risk over time: more data encrypted under the same key, more time for an attacker to compromise the key, and no practice/automation for the rotation process (so when you MUST rotate, it is an emergency).

### Anti-Pattern 3: Same Key for Everything

Using one key for encryption, signing, and authentication across all applications. A compromise anywhere exposes everything.

**Fix**: Separate keys per purpose (encryption vs signing), per environment (prod vs staging), and per application. Use a key hierarchy with a KMS.

### Anti-Pattern 4: Manual Key Management

Generating keys locally, distributing via email or Slack, storing in spreadsheets or wiki pages. This guarantees key exposure and provides no audit trail.

**Fix**: Automated key management via KMS with IAM-controlled access, audit logging, and automated rotation.

### Anti-Pattern 5: No Backup or Escrow

If the only copy of an encryption key is lost (server failure, employee departure), the encrypted data is permanently inaccessible. This is effectively data destruction.

**Fix**: Key escrow in HSM or KMS with documented recovery procedures. Multiple key administrators required for key recovery (M-of-N threshold).

## References

- [NIST SP 800-57: Key Management Guidelines](https://csrc.nist.gov/publications/detail/sp/800-57-part-1/rev-5/final)
- [NIST SP 800-57 Part 2: Best Practices for Key Management Organizations](https://csrc.nist.gov/publications/detail/sp/800-57-part-2/rev-1/final)
- [AWS KMS Best Practices](https://docs.aws.amazon.com/kms/latest/developerguide/best-practices.html)
- [HashiCorp Vault Documentation](https://developer.hashicorp.com/vault/docs)
- [OWASP Key Management Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Key_Management_Cheat_Sheet.html)
- [Cloud KMS Comparison (AWS vs GCP vs Azure)](https://cloud.google.com/docs/compare/aws/security)
