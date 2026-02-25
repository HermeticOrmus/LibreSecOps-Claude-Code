# Forensic Methodology

> Evidence collection, preservation, analysis, and reporting methodology following NIST SP 800-86 and ISO 27037 standards.

## Knowledge Base

### The Forensic Process (NIST SP 800-86)

NIST defines four phases:

**1. Collection**: Identifying and gathering evidence from relevant sources. The priority is to preserve evidence integrity and collect volatile evidence before it is lost.

**2. Examination**: Processing the collected evidence to extract relevant data. This includes disk image mounting, log parsing, artifact extraction, and keyword searching.

**3. Analysis**: Interpreting the extracted data to answer the investigation questions. This includes timeline reconstruction, correlation across sources, and hypothesis testing.

**4. Reporting**: Documenting the findings, methodology, and conclusions in a format appropriate for the audience (technical, management, or legal).

### Order of Volatility (RFC 3227)

Evidence must be collected in order of volatility -- most volatile first:

1. **CPU registers and cache** (nanoseconds -- effectively uncollectable)
2. **Memory (RAM)** (lost on power-off -- collect immediately)
3. **Network state** (connections, routing tables, ARP cache -- changes constantly)
4. **Running processes** (may be terminated or replaced)
5. **Disk** (persists across reboots but can be overwritten)
6. **Remote logging** (SIEM, syslog server -- may be rotated)
7. **Physical configuration** (network topology -- changes infrequently)
8. **Archival media** (backups, tapes -- most durable)

### Evidence Integrity

**Hashing**: Every evidence item is hashed at collection time. SHA-256 is the standard. MD5 is computed as a secondary hash for compatibility but is not sufficient alone (collision vulnerabilities).

**Write-blocking**: Original evidence media must be accessed through write-blockers to prevent any modification. Hardware write-blockers (Tableau, WiebeTech) are preferred; software write-blockers (Linux mount with -o ro,noexec,noatime) are acceptable when hardware is unavailable.

**Forensic imaging**: Bit-for-bit copies that include all sectors (allocated, unallocated, slack space). Formats: raw/dd (simplest, largest), E01 (EnCase, compressed, with metadata), AFF4 (open format, compressed).

### Forensic Soundness Principles (ISO 27037)

1. **Minimize handling**: The less the evidence is handled, the less risk of contamination or alteration.
2. **Account for changes**: Any change to the evidence must be documented and justified. If live response modifies a system, document what was changed and why.
3. **Comply with rules**: Follow applicable legal requirements, organizational policies, and professional standards.
4. **Do not exceed authority**: Stay within the authorized scope of the investigation.

## Patterns

### Pattern 1: Windows Evidence Collection with KAPE

KAPE (Kroll Artifact Parser and Extractor) is the standard tool for rapid evidence collection on Windows systems.

```bash
# Collect critical artifacts using KAPE targets
# Run from USB or network share (do not install on evidence system)
KAPE.exe --tsource C: --tdest D:\Evidence\%m --target KapeTriage

# KapeTriage target collects:
# - Event logs (Security, System, Application, Sysmon, PowerShell)
# - Registry hives (SAM, SECURITY, SOFTWARE, SYSTEM, NTUSER.DAT)
# - Prefetch files
# - Amcache.hve
# - SRUM database
# - $MFT (Master File Table)
# - $UsnJrnl (USN Journal -- file change log)
# - Scheduled Tasks
# - Startup items
# - Browser history and downloads
# - Recent files and Jump Lists

# Process collected artifacts with KAPE modules
KAPE.exe --msource D:\Evidence\%m --mdest D:\Processed\%m --module !EZParser

# EZParser module runs Eric Zimmerman tools:
# - MFTECmd (parse $MFT)
# - PECmd (parse Prefetch)
# - AmcacheParser
# - AppCompatCacheParser (ShimCache)
# - RECmd (Registry explorer)
# - JLECmd (Jump Lists)
# - LECmd (LNK files)
# - SrumECmd (SRUM database)
```

### Pattern 2: Forensic Disk Imaging

```bash
# Linux: Create a forensic image with dc3dd (enhanced dd with hashing)
# ALWAYS use a write-blocker on the source drive

# Raw image with SHA-256 hash
dc3dd if=/dev/sdb of=/evidence/case001/disk.raw hash=sha256 \
  log=/evidence/case001/imaging.log

# Split image into 2GB chunks (for FAT32 compatibility)
dc3dd if=/dev/sdb of=/evidence/case001/disk.raw.000 ofsz=2G \
  hash=sha256 log=/evidence/case001/imaging.log

# E01 format with ewfacquire (compressed, includes case metadata)
ewfacquire /dev/sdb -t /evidence/case001/disk \
  -C "Case 001 - Server disk" \
  -D "Western Digital 1TB SN:WD-XXXXX" \
  -e "J. Smith" \
  -N "Forensic examination of compromised server" \
  -c deflate:best \
  -S 2GiB

# Verify the image hash matches
dc3dd if=/evidence/case001/disk.raw hash=sha256 \
  log=/evidence/case001/verify.log
# Compare hash output against the imaging log

# Mount image read-only for analysis (Linux)
mkdir /mnt/evidence
mount -o ro,noexec,noatime,loop /evidence/case001/disk.raw /mnt/evidence

# For E01 format, use ewfmount first
ewfmount /evidence/case001/disk.E01 /mnt/ewf
mount -o ro,noexec,noatime /mnt/ewf/ewf1 /mnt/evidence
```

### Pattern 3: Timeline Analysis with Plaso

```bash
# Step 1: Generate a super timeline from disk image
# This parses ALL timestamp sources (file system, event logs, registry, etc.)
log2timeline.py --storage-file timeline.plaso /evidence/case001/disk.raw

# Step 2: Filter the timeline to the relevant time period
psort.py -o l2tcsv -w timeline.csv timeline.plaso \
  "date > '2024-03-14T00:00:00' AND date < '2024-03-16T23:59:59'"

# Step 3: Further filter by keyword or source
psort.py -o l2tcsv -w filtered.csv timeline.plaso \
  "date > '2024-03-14' AND (source_short == 'EVT' OR source_short == 'REG')"

# Step 4: Import into Timesketch for collaborative analysis
timesketch_importer.py --host https://timesketch.local \
  --timeline_name "Case001-Server" \
  --sketch_id 42 \
  timeline.plaso
```

### Pattern 4: Key Windows Artifacts by Investigation Type

**Malware Investigation**:
| Artifact | Location | Tool | What It Shows |
|----------|----------|------|---------------|
| Prefetch | C:\Windows\Prefetch | PECmd | Program execution with timestamps and frequency |
| Amcache | C:\Windows\appcompat\Programs\Amcache.hve | AmcacheParser | Program installation/execution with SHA-1 hashes |
| ShimCache | SYSTEM hive | AppCompatCacheParser | Program execution evidence (even if deleted) |
| SRUM | C:\Windows\System32\sru\SRUDB.dat | SrumECmd | Network usage per application, bytes sent/received |
| MFT | $MFT | MFTECmd | File creation, modification, access times |
| USN Journal | $UsnJrnl:$J | MFTECmd | File change log (create, delete, rename) |

**Account Compromise**:
| Artifact | Location | Tool | What It Shows |
|----------|----------|------|---------------|
| Security Event Log | Security.evtx | EvtxECmd | Logon events (4624), failed logons (4625), account changes |
| RDP Cache | Users\[user]\AppData\Local\Microsoft\Terminal Server Client\Cache | bmc-tools | RDP session screenshots |
| SAM Hive | SAM | RECmd | Local account information |
| NTUSER.DAT | Users\[user]\NTUSER.DAT | RECmd | User-specific registry (MRU, typed URLs, run commands) |
| Browser artifacts | Users\[user]\AppData | Hindsight (Chrome), KAPE | Login activity, downloads, browsing history |

**Data Exfiltration**:
| Artifact | Location | Tool | What It Shows |
|----------|----------|------|---------------|
| USB device history | SYSTEM hive (USBSTOR) | RECmd | USB devices connected with timestamps |
| Jump Lists | Users\[user]\AppData\Roaming\Microsoft\Windows\Recent\AutomaticDestinations | JLECmd | Recent files accessed per application |
| SRUM | SRUDB.dat | SrumECmd | Network data volume per application |
| Shellbags | UsrClass.dat | SBECmd | Folders browsed (including removable media) |
| Cloud storage logs | Various | Application-specific | OneDrive, Dropbox, Google Drive sync activity |

### Pattern 5: Live Response Collection Script

```bash
#!/bin/bash
# Linux live response collection script
# Run as root on the evidence system
# Output to a mounted external drive or network share

EVIDENCE_DIR="/mnt/evidence/$(hostname)_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$EVIDENCE_DIR"

echo "=== Live Response Collection: $(hostname) ===" | tee "$EVIDENCE_DIR/collection.log"
echo "Start time: $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$EVIDENCE_DIR/collection.log"

# Volatile: Process information
ps auxwwf > "$EVIDENCE_DIR/processes.txt" 2>&1
ls -la /proc/*/exe 2>/dev/null > "$EVIDENCE_DIR/proc_exe_links.txt" 2>&1
cat /proc/*/cmdline 2>/dev/null | tr '\0' ' ' > "$EVIDENCE_DIR/proc_cmdline.txt" 2>&1

# Volatile: Network connections
ss -tulnp > "$EVIDENCE_DIR/network_listening.txt" 2>&1
ss -tnp > "$EVIDENCE_DIR/network_established.txt" 2>&1
ip addr > "$EVIDENCE_DIR/ip_addresses.txt" 2>&1
ip route > "$EVIDENCE_DIR/routes.txt" 2>&1
arp -a > "$EVIDENCE_DIR/arp_cache.txt" 2>&1
cat /etc/resolv.conf > "$EVIDENCE_DIR/dns_config.txt" 2>&1
iptables -L -n -v > "$EVIDENCE_DIR/firewall_rules.txt" 2>&1

# Volatile: Logged-in users
w > "$EVIDENCE_DIR/logged_in_users.txt" 2>&1
last -50 > "$EVIDENCE_DIR/last_logins.txt" 2>&1
lastlog > "$EVIDENCE_DIR/lastlog.txt" 2>&1

# Semi-volatile: System logs
cp -r /var/log "$EVIDENCE_DIR/var_log/" 2>&1
journalctl --since "7 days ago" > "$EVIDENCE_DIR/journal_7days.txt" 2>&1

# Semi-volatile: Crontabs and scheduled tasks
crontab -l > "$EVIDENCE_DIR/root_crontab.txt" 2>&1
for user in $(cut -d: -f1 /etc/passwd); do
    crontab -u "$user" -l > "$EVIDENCE_DIR/crontab_${user}.txt" 2>/dev/null
done
ls -la /etc/cron.* > "$EVIDENCE_DIR/cron_dirs.txt" 2>&1
systemctl list-timers > "$EVIDENCE_DIR/systemd_timers.txt" 2>&1

# Semi-volatile: Persistence mechanisms
systemctl list-unit-files --type=service > "$EVIDENCE_DIR/services.txt" 2>&1
ls -la /etc/init.d/ > "$EVIDENCE_DIR/initd.txt" 2>&1
cat /etc/rc.local > "$EVIDENCE_DIR/rc_local.txt" 2>&1

# User artifacts
for user_dir in /home/*; do
    user=$(basename "$user_dir")
    mkdir -p "$EVIDENCE_DIR/users/$user"
    cp "$user_dir/.bash_history" "$EVIDENCE_DIR/users/$user/" 2>/dev/null
    cp "$user_dir/.zsh_history" "$EVIDENCE_DIR/users/$user/" 2>/dev/null
    ls -la "$user_dir/.ssh/" > "$EVIDENCE_DIR/users/$user/ssh_keys.txt" 2>/dev/null
done

# Hash all collected evidence
find "$EVIDENCE_DIR" -type f -exec sha256sum {} \; > "$EVIDENCE_DIR/evidence_hashes.txt"

echo "End time: $(date -u +%Y-%m-%dT%H:%M:%SZ)" | tee -a "$EVIDENCE_DIR/collection.log"
echo "Collection complete. Evidence at: $EVIDENCE_DIR"
```

## Anti-Patterns

- **Analyzing original evidence directly**: Never run forensic tools against the original disk or device. Always work on a forensic image (bit-for-bit copy). The original is preserved as evidence.
- **Collecting evidence without write-blocking**: Mounting a drive without write-blocking (even briefly) alters file system metadata (access times, journal). This can be challenged in legal proceedings.
- **Incomplete chain of custody**: Every custody transfer must be documented. A gap in the chain -- even a brief one -- creates reasonable doubt about evidence integrity.
- **Single hash algorithm**: SHA-256 is the standard, but computing both SHA-256 and MD5 provides defense against hash collision claims and compatibility with legacy tools.
- **Failing to capture volatile evidence first**: Shutting down a system to image the disk loses everything in RAM: running processes, network connections, encryption keys, and injected code. Capture memory first.
- **Timeline analysis without timezone awareness**: Logs from different sources may use different timezones. Normalize everything to UTC before correlating. NTFS timestamps are UTC; event logs may use local time.
- **Confirmation bias**: Looking only for evidence that supports the initial theory. Forensic examination must be objective -- look for evidence that both supports and contradicts the hypothesis.

## References

- NIST SP 800-86 (Guide to Integrating Forensic Techniques): https://csrc.nist.gov/publications/detail/sp/800-86/final
- ISO/IEC 27037 (Digital Evidence -- Identification, Collection, Acquisition, Preservation): https://www.iso.org/standard/44381.html
- RFC 3227 (Guidelines for Evidence Collection and Archiving): https://www.rfc-editor.org/rfc/rfc3227
- KAPE Documentation: https://ericzimmerman.github.io/KapeDocs/
- Eric Zimmerman Tools: https://ericzimmerman.github.io/
- Plaso/log2timeline: https://plaso.readthedocs.io/
- Autopsy Digital Forensic Platform: https://www.autopsy.com/
- Sleuth Kit: https://www.sleuthkit.org/
- SANS DFIR Resources: https://www.sans.org/digital-forensics-incident-response/
