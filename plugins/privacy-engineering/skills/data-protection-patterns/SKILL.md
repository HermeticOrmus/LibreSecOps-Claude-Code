# Data Protection Patterns

> Technical patterns for anonymization, pseudonymization, encryption, data minimization, and consent management in software systems.

## Knowledge Base

### Anonymization vs Pseudonymization

This distinction has significant regulatory consequences. Truly anonymous data is outside the scope of GDPR. Pseudonymous data remains personal data under GDPR, just with reduced risk.

**Anonymization** (irreversible -- removes data from regulation scope):
- No one, including the data controller, can re-identify individuals
- Must resist: singling out, linkability, and inference attacks
- Techniques: aggregation, generalization, suppression, noise addition
- Test: Could this data be combined with any other reasonably available dataset to identify an individual?

**Pseudonymization** (reversible -- reduces risk but remains personal data):
- The data controller can re-identify using a separately stored key/mapping
- Reduces risk of unauthorized re-identification
- Techniques: tokenization, hashing with salt, encryption
- Benefit: Reduced obligations in some GDPR contexts (Article 6(4)(e), Article 32, Recital 29)

### Anonymization Techniques

**k-Anonymity**: Each record is indistinguishable from at least k-1 other records with respect to quasi-identifiers.

```
# Before (k=1, each record unique on age+zip)
| Age | Zip   | Diagnosis |
|-----|-------|-----------|
| 28  | 10001 | Flu       |
| 29  | 10002 | Diabetes  |
| 35  | 10005 | Flu       |

# After k-anonymity (k=2, generalize age and zip)
| Age   | Zip   | Diagnosis |
|-------|-------|-----------|
| 25-30 | 1000* | Flu       |
| 25-30 | 1000* | Diabetes  |
| 35-40 | 1000* | Flu       |
```

Limitation: k-anonymity does not protect against attribute disclosure if all records in a group share the same sensitive value.

**l-Diversity**: Extends k-anonymity by requiring that each equivalence class has at least l well-represented values for the sensitive attribute.

**t-Closeness**: Extends l-diversity by requiring that the distribution of the sensitive attribute within each equivalence class is close to the distribution in the overall dataset.

**Differential Privacy**: Adds calibrated noise to query results or data so that the presence or absence of any individual record does not significantly affect the output.

```python
# Simplified differential privacy for count queries
import numpy as np

def dp_count(true_count, epsilon=1.0):
    """Add Laplace noise to a count query for differential privacy."""
    noise = np.random.laplace(0, 1/epsilon)
    return max(0, int(true_count + noise))

# epsilon controls privacy/utility tradeoff:
# Lower epsilon = more privacy, more noise
# Higher epsilon = less privacy, more accurate
```

**Data masking**: Replacing identifying portions of data with realistic but non-identifying values.

```python
# Email masking: j***@example.com
def mask_email(email):
    local, domain = email.split('@')
    return f"{local[0]}{'*' * (len(local)-1)}@{domain}"

# Phone masking: ***-***-1234
def mask_phone(phone):
    return f"***-***-{phone[-4:]}"

# Name masking: J*** D**
def mask_name(name):
    parts = name.split()
    return ' '.join(f"{p[0]}{'*' * (len(p)-1)}" for p in parts)
```

### Pseudonymization Techniques

**Tokenization**: Replace identifiers with random tokens. Store the mapping separately.

```python
import secrets

class Tokenizer:
    def __init__(self):
        self.token_map = {}  # Stored separately from tokenized data
        self.reverse_map = {}

    def tokenize(self, identifier):
        if identifier not in self.token_map:
            token = secrets.token_hex(16)
            self.token_map[identifier] = token
            self.reverse_map[token] = identifier
        return self.token_map[identifier]

    def detokenize(self, token):
        return self.reverse_map.get(token)
```

**Format-preserving encryption (FPE)**: Encrypt data while maintaining the original format (useful for systems that validate format).

```python
# Concept: SSN 123-45-6789 encrypts to 987-65-4321
# Same format, but the value is encrypted
# Use FF1 or FF3-1 algorithms (NIST SP 800-38G)
```

**Keyed hashing (HMAC)**: One-way pseudonymization using HMAC. Cannot be reversed without brute-forcing the input space.

```python
import hmac
import hashlib

def pseudonymize(identifier, key):
    """One-way pseudonymization using HMAC-SHA256."""
    return hmac.new(key, identifier.encode(), hashlib.sha256).hexdigest()

# Same identifier always maps to same pseudonym (with same key)
# Different key produces different pseudonyms
# Cannot reverse without the original identifier
```

### Encryption Patterns

**Field-level encryption**: Encrypt individual fields containing sensitive personal data rather than (or in addition to) full database encryption.

```python
from cryptography.fernet import Fernet

class FieldEncryptor:
    def __init__(self, key):
        self.cipher = Fernet(key)

    def encrypt_field(self, plaintext):
        return self.cipher.encrypt(plaintext.encode()).decode()

    def decrypt_field(self, ciphertext):
        return self.cipher.decrypt(ciphertext.encode()).decode()

# Usage in ORM
class User(Model):
    id = Column(UUID, primary_key=True)
    email_encrypted = Column(Text)      # Encrypted
    name_encrypted = Column(Text)       # Encrypted
    email_hash = Column(Text, index=True)  # For lookups (HMAC)
    created_at = Column(DateTime)       # Not encrypted (not PII)
```

**Envelope encryption**: Use a data encryption key (DEK) to encrypt data, then encrypt the DEK with a key encryption key (KEK) stored in a key management service (AWS KMS, Azure Key Vault, GCP KMS).

**Cryptographic erasure**: Instead of finding and deleting every copy of a user's data (which is hard with backups, caches, logs), destroy the encryption key. All encrypted data becomes permanently unreadable.

### Consent Management

**Technical implementation**:

```python
class ConsentRecord:
    user_id: str
    purpose: str           # Specific processing purpose
    granted: bool
    granted_at: datetime
    withdrawn_at: datetime | None
    method: str            # "web_form", "api", "verbal"
    version: str           # Consent text version
    evidence: str          # Proof of consent (form snapshot, recording ID)

class ConsentManager:
    def check_consent(self, user_id, purpose):
        """Check if user has active consent for a specific purpose."""
        record = get_latest_consent(user_id, purpose)
        return record and record.granted and not record.withdrawn_at

    def grant_consent(self, user_id, purpose, method, version):
        """Record consent grant with full audit trail."""
        store_consent(ConsentRecord(
            user_id=user_id,
            purpose=purpose,
            granted=True,
            granted_at=now(),
            method=method,
            version=version
        ))

    def withdraw_consent(self, user_id, purpose):
        """Record consent withdrawal. Must be as easy as granting."""
        record = get_latest_consent(user_id, purpose)
        record.withdrawn_at = now()
        update_consent(record)
        # Trigger downstream: stop processing, queue data deletion
        trigger_consent_withdrawal_workflow(user_id, purpose)
```

**Consent receipts** (Kantara Initiative):
Machine-readable records of consent that can be verified by both parties.

### Data Subject Request Automation

**Right to Access (Article 15)**:
```python
def handle_access_request(user_id):
    """Generate a data export for DSAR."""
    data = {
        'personal_data': get_all_user_data(user_id),
        'purposes': get_processing_purposes(user_id),
        'recipients': get_data_sharing_partners(user_id),
        'retention': get_retention_periods(user_id),
        'source': get_data_sources(user_id),
        'automated_decisions': get_automated_decisions(user_id),
        'generated_at': datetime.utcnow().isoformat()
    }
    return export_as_json(data)  # Machine-readable format
```

**Right to Erasure (Article 17)**:
```python
def handle_erasure_request(user_id):
    """Delete all personal data for a user."""
    # Check for legal retention obligations first
    if has_legal_retention_obligation(user_id):
        return restrict_processing(user_id)  # Restrict instead of delete

    # Delete from all storage locations
    delete_from_primary_database(user_id)
    delete_from_search_index(user_id)
    delete_from_cache(user_id)
    delete_from_file_storage(user_id)
    anonymize_in_analytics(user_id)
    notify_processors_to_delete(user_id)  # Third-party processors

    # Cryptographic erasure for encrypted data in backups
    destroy_user_encryption_key(user_id)

    # Audit trail (record that deletion occurred, not what was deleted)
    log_erasure_completed(user_id)
```

## Patterns

### Pattern: Data Minimization by Architecture
Design systems so that components only have access to the personal data they need. The analytics service receives pseudonymous IDs, not names. The email service receives email addresses but not browsing history. This is structural data minimization.

### Pattern: Retention by Design
Implement automatic retention enforcement in the data layer, not as a manual process. Use TTL (time-to-live) fields, scheduled cleanup jobs, and cryptographic erasure so that data expires automatically.

### Pattern: Privacy-Preserving Analytics
Use aggregated, anonymized, or differentially private analytics instead of individual-level tracking. Most business questions ("How many users completed onboarding?") do not require individual-level data.

## Anti-Patterns

- **Anonymization that is not anonymous**: Removing names and emails but leaving IP addresses, timestamps, and behavioral patterns that enable re-identification through linkage
- **Consent dark patterns**: Making "Accept All" prominent and colorful while hiding "Manage Preferences" in small gray text
- **Backup blind spot**: Deleting data from production but leaving it indefinitely in backups, defeating the purpose of erasure
- **Encryption key shared across all users**: Using one encryption key for all user data means you cannot cryptographically erase one user's data without destroying everyone's
- **Logging personal data**: Writing personal data to application logs, which are then stored for months in log aggregators without encryption or retention controls

## References

- GDPR Full Text -- https://gdpr-info.eu/
- Article 29 Working Party -- Opinion on Anonymisation Techniques (WP216)
- ENISA -- Pseudonymisation techniques and best practices -- https://www.enisa.europa.eu/publications/pseudonymisation-techniques-and-best-practices
- NIST Privacy Framework -- https://www.nist.gov/privacy-framework
- Differential Privacy by Cynthia Dwork -- foundational research
- Kantara Initiative Consent Receipt Specification -- https://kantarainitiative.org/
- ICO Anonymisation Code of Practice -- https://ico.org.uk/media/for-organisations/documents/1061/anonymisation-code.pdf
- CNIL DPIA Guidelines -- https://www.cnil.fr/en/guidelines-dpia
