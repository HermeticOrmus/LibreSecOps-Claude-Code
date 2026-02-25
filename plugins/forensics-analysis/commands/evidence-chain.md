# /evidence-chain

> Document a chain of custody record for collected digital evidence, ensuring integrity and admissibility.

## Trigger

Use every time digital evidence is:

- Collected from a system
- Transferred between locations or storage
- Accessed for analysis
- Copied or imaged
- Returned or disposed of

Chain of custody documentation must begin at the moment evidence is identified and continue through final disposition. Gaps in the chain compromise evidence integrity.

## Input

- **Required**: Evidence description (what is it, where does it come from)
- **Required**: Action being performed (collection, transfer, analysis, storage, disposal)
- **Required**: Person performing the action
- **Optional**: Case ID (should be established by /forensic-plan)
- **Optional flag**: `--verify` -- include hash verification step
- **Optional flag**: `--legal` -- use formal legal chain of custody format

## Process

1. **Evidence Identification**: Document what the evidence is:
   - Physical description (device type, serial number, model, capacity)
   - Digital description (disk image, memory dump, log export, network capture)
   - Source system (hostname, IP, location)
   - Relevance (why this evidence matters to the investigation)

2. **Integrity Verification**: Compute and record cryptographic hashes:
   - SHA-256 hash of the evidence file or disk
   - Hash recorded at time of collection
   - Hash verified at every subsequent access
   - Any hash mismatch is a critical event that must be documented and investigated

3. **Chain of Custody Entry**: Record the custody transfer:
   - Date and time (UTC)
   - Person releasing custody (name, role, contact)
   - Person receiving custody (name, role, contact)
   - Purpose of transfer (collection, analysis, storage, legal hold)
   - Storage location (locked cabinet, evidence locker, encrypted storage, forensic workstation)
   - Any changes to evidence packaging or storage conditions

4. **Storage Requirements**: Document storage conditions:
   - Physical security (locked room, access log)
   - Environmental protection (temperature, humidity for hardware)
   - Digital security (encryption at rest, access controls)
   - Retention period (legal hold duration, retention policy)

5. **Access Log**: Every time evidence is accessed for analysis:
   - Who accessed it
   - When (date and time UTC)
   - Why (purpose of access)
   - What tools were used
   - Hash verification before and after
   - Whether any derivative evidence was created (screenshots, exports)

## Output

```
# Chain of Custody Record

## Case Information
- Case ID: [identifier]
- Case name: [descriptive name]
- Investigating agency/team: [name]
- Lead examiner: [name]

## Evidence Item

### Identification
- Evidence ID: [unique identifier, e.g., E001]
- Description: [what it is]
- Source: [where it came from]
  - System: [hostname/IP]
  - Location: [physical location]
  - Owner: [system owner]
- Type: [disk image / memory dump / log export / network capture / physical device]

### Physical Description (if hardware)
- Device type: [laptop, server, USB drive, etc.]
- Make/Model: [manufacturer and model]
- Serial number: [serial]
- Capacity: [storage capacity]
- Condition: [power state at collection, physical condition]

### Digital Description
- Filename: [evidence file name]
- Format: [raw/dd, E01, AFF4, PCAP, EVTX, etc.]
- Size: [file size]
- Hash (SHA-256): [hash computed at collection]
- Hash (MD5): [secondary hash for compatibility]

## Custody Log

| # | Date/Time (UTC) | Action | Released By | Received By | Purpose | Storage Location | Hash Verified |
|---|-----------------|--------|-------------|-------------|---------|-----------------|---------------|
| 1 | 2024-03-15T10:30Z | Collected | N/A (initial) | J. Smith (Examiner) | Initial acquisition | Forensic WS-01, encrypted | SHA-256: MATCH |
| 2 | 2024-03-15T14:00Z | Transferred | J. Smith | Evidence Locker | Secure storage | Evidence Locker B, Shelf 3 | SHA-256: MATCH |
| 3 | 2024-03-16T09:00Z | Accessed | Evidence Locker | J. Smith | Timeline analysis | Forensic WS-01 | SHA-256: MATCH |
| 4 | 2024-03-16T17:00Z | Returned | J. Smith | Evidence Locker | Analysis complete | Evidence Locker B, Shelf 3 | SHA-256: MATCH |

## Integrity Verification Log

| Date/Time (UTC) | Verified By | Expected SHA-256 | Computed SHA-256 | Result |
|-----------------|-------------|-----------------|------------------|--------|
| 2024-03-15T10:30Z | J. Smith | [hash] | [hash] | MATCH |
| 2024-03-16T09:00Z | J. Smith | [hash] | [hash] | MATCH |
| 2024-03-16T17:00Z | J. Smith | [hash] | [hash] | MATCH |

## Notes
[Any relevant observations, anomalies, or special handling requirements]

## Signatures
- Examiner: _________________________ Date: _____________
- Reviewer: _________________________ Date: _____________
```
