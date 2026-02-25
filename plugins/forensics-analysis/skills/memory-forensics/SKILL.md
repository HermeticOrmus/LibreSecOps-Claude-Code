# Memory Forensics

> Volatility framework reference, process analysis, memory artifact types, and RAM analysis patterns for incident response.

## Knowledge Base

### Why Memory Forensics

Memory forensics reveals evidence that does not exist on disk:

- **Running malware**: Fileless malware executes entirely in memory. No disk artifact exists.
- **Injected code**: Malware injected into legitimate processes leaves memory artifacts but may not be visible on disk.
- **Decrypted data**: Encrypted files are decrypted in memory when accessed. Memory captures may contain plaintext of encrypted data.
- **Network connections**: Active and recently closed connections exist in kernel memory.
- **Credentials**: Password hashes, Kerberos tickets, and plaintext passwords reside in LSASS memory and other process spaces.
- **Encryption keys**: Full-disk encryption keys exist in memory while the volume is mounted.
- **Rootkit artifacts**: Kernel rootkits that hide from disk-based tools can be detected through memory analysis.
- **Process history**: Terminated processes may leave residual artifacts in memory until the pages are reused.

### Memory Acquisition

**Windows**:
```bash
# WinPMem (Rekall project) -- most reliable
winpmem_mini_x64.exe output.raw

# DumpIt (Comae/Magnet) -- single-click
DumpIt.exe  # Outputs to current directory

# FTK Imager -- GUI-based, widely accepted in legal proceedings
# File > Capture Memory > Select output location
```

**Linux**:
```bash
# LiME (Linux Memory Extractor) -- kernel module
# Must be compiled for the target kernel version
insmod lime.ko "path=/evidence/memory.lime format=lime"

# /proc/kcore (requires root, may not capture all memory)
dd if=/proc/kcore of=/evidence/kcore.raw bs=1M

# AVML (Acquire Volatile Memory for Linux) -- Microsoft, no compilation needed
./avml /evidence/memory.lime
```

**Verification**:
```bash
# Always hash memory images immediately after acquisition
sha256sum memory.raw > memory.raw.sha256
```

### Volatility 3 Architecture

Volatility 3 uses **symbol tables** (ISF -- Intermediate Symbol Format) instead of profiles. Symbol tables are automatically downloaded or can be generated from kernel debug symbols.

```
Volatility 3 Plugin Categories:
  windows.*     -- Windows-specific plugins
  linux.*       -- Linux-specific plugins
  mac.*         -- macOS-specific plugins

Common Plugin Prefixes:
  *.pslist      -- Process listing (from EPROCESS linked list)
  *.psscan      -- Process scanning (finds hidden/unlinked processes)
  *.pstree      -- Process tree (parent-child relationships)
  *.netscan     -- Network connections
  *.cmdline     -- Command-line arguments
  *.dlllist     -- Loaded DLLs
  *.handles     -- Open handles
  *.filescan    -- File objects in memory
  *.malfind     -- Injected code detection
  *.svcscan     -- Windows services
  *.registry.*  -- Registry analysis
```

## Patterns

### Pattern 1: Initial Memory Triage

The standard first-pass analysis of a memory image:

```bash
# Step 1: Identify the OS and build
vol -f memory.raw windows.info

# Step 2: List all processes (linked list traversal)
vol -f memory.raw windows.pslist

# Step 3: Process tree (shows parent-child relationships)
# KEY: Look for unusual parent processes
vol -f memory.raw windows.pstree

# Step 4: Scan for hidden/unlinked processes
# Compares pslist (linked list) vs psscan (pool tag scanning)
# Processes in psscan but NOT in pslist are suspicious (hidden by rootkit)
vol -f memory.raw windows.psscan

# Step 5: Network connections
# Shows active and recently closed connections
vol -f memory.raw windows.netscan

# Step 6: Command-line arguments
# KEY: Look for encoded commands, suspicious arguments
vol -f memory.raw windows.cmdline

# Step 7: Loaded DLLs per process
vol -f memory.raw windows.dlllist --pid [suspicious_pid]

# Step 8: Open handles per process
vol -f memory.raw windows.handles --pid [suspicious_pid]
```

### Pattern 2: Detecting Process Injection

Process injection is one of the most common adversary techniques. Volatility's `malfind` plugin detects it.

```bash
# malfind looks for:
# 1. Memory regions with PAGE_EXECUTE_READWRITE (RWX) protection
# 2. Memory regions that contain executable code (MZ header, shellcode patterns)
# 3. Memory regions not backed by a file on disk (anonymous mappings with code)

vol -f memory.raw windows.malfind

# Output interpretation:
# Process: svchost.exe  PID: 1284
# Address: 0x00400000
# Protection: PAGE_EXECUTE_READWRITE
# Content: MZ header detected
#
# This means: executable code was injected into svchost.exe at 0x00400000
# Normal svchost.exe does NOT have RWX memory with PE headers

# Dump the injected code for further analysis
vol -f memory.raw windows.malfind --pid 1284 --dump

# Common injection techniques and their memory artifacts:
#
# Classic DLL Injection:
#   - New DLL in dlllist that is not expected for the process
#   - DLL loaded from unusual path (Temp, AppData, user directory)
#
# Reflective DLL Injection:
#   - RWX memory region with PE header
#   - NOT in dlllist (loaded without LoadLibrary)
#   - Detected by malfind
#
# Process Hollowing:
#   - Process in pslist with expected name (e.g., svchost.exe)
#   - But memory at base address contains different code
#   - Image path may not match expected path
#   - malfind shows PE header at unexpected location
#
# APC Injection:
#   - Suspicious thread in a legitimate process
#   - Thread start address in RWX region
#   - May be visible in threads plugin
```

### Pattern 3: Suspicious Process Identification

```bash
# Normal Windows process hierarchy (know this to spot anomalies):
#
# System (PID 4)
#   └── smss.exe (Session Manager)
#         └── csrss.exe (Client/Server Runtime)
#         └── wininit.exe (Session 0)
#               └── services.exe
#                     └── svchost.exe (multiple instances)
#                     └── spoolsv.exe
#                     └── [other services]
#               └── lsass.exe (ONE instance only)
#               └── lsaiso.exe (if Credential Guard enabled)
#         └── winlogon.exe (Session 1+)
#               └── dwm.exe (Desktop Window Manager)
# explorer.exe (user shell)
#   └── [user applications]

# RED FLAGS:
# 1. lsass.exe with wrong parent (should be wininit.exe)
# 2. Multiple lsass.exe processes (there should be exactly one)
# 3. svchost.exe not a child of services.exe
# 4. csrss.exe/smss.exe spawned from unexpected parent
# 5. Any process with a misspelled name (svch0st.exe, lsas.exe)
# 6. Processes running from %TEMP%, %APPDATA%, or user directories
# 7. cmd.exe or powershell.exe spawned by Office applications

# Check for process path anomalies
vol -f memory.raw windows.cmdline | grep -i "temp\|appdata\|users\|downloads"

# Check for processes with suspicious parent relationships
vol -f memory.raw windows.pstree | grep -B2 -A2 "powershell\|cmd\|wscript\|mshta"
```

### Pattern 4: Network Connection Analysis

```bash
# Extract all network connections
vol -f memory.raw windows.netscan

# Output columns:
# Offset, Proto, LocalAddr, LocalPort, ForeignAddr, ForeignPort, State, PID, Owner, Created

# Analysis approach:
# 1. Identify all ESTABLISHED connections
# 2. Cross-reference remote IPs against threat intelligence
# 3. Check which process owns each connection
# 4. Flag connections from unexpected processes (why is notepad.exe connecting out?)
# 5. Look for connections on unusual ports (high-numbered, non-standard)
# 6. Check for DNS over unusual ports (not 53)
# 7. Look for connections to known C2 infrastructure

# Filter for established connections
vol -f memory.raw windows.netscan | grep ESTABLISHED

# Focus on connections from a specific suspicious process
vol -f memory.raw windows.netscan | grep "PID: 1284"

# For Linux memory images:
vol -f memory.lime linux.sockstat
```

### Pattern 5: YARA Scanning in Memory

```bash
# Scan entire memory image with YARA rules
vol -f memory.raw windows.yarascan --yara-file malware_rules.yar

# Scan specific process memory
vol -f memory.raw windows.yarascan --yara-file malware_rules.yar --pid 1284

# Example YARA rules for memory scanning
# (use simple rules -- memory scanning is resource-intensive)

rule CobaltStrike_Beacon_Memory
{
    meta:
        description = "Detects Cobalt Strike beacon in memory"
        reference = "https://attack.mitre.org/software/S0154/"
    strings:
        $s1 = "%s.4444" ascii
        $s2 = "%s as %s\\%s: %d" ascii
        $s3 = "beacon.dll" ascii
        $s4 = "ReflectiveLoader" ascii
        $config = { 00 01 00 01 00 02 ?? ?? 00 02 00 01 00 02 ?? ?? }
    condition:
        2 of ($s*) or $config
}

rule Mimikatz_Memory
{
    meta:
        description = "Detects Mimikatz strings in process memory"
    strings:
        $s1 = "mimikatz" ascii wide nocase
        $s2 = "sekurlsa" ascii wide
        $s3 = "gentilkiwi" ascii wide
        $s4 = "kiwi" ascii wide
        $s5 = "dpapi" ascii wide
    condition:
        3 of them
}
```

### Pattern 6: Linux Memory Analysis

```bash
# Linux memory analysis with Volatility 3

# System information
vol -f memory.lime linux.bash    # Bash command history from memory
vol -f memory.lime linux.pslist  # Process listing
vol -f memory.lime linux.pstree  # Process tree

# Loaded kernel modules (detect rootkit modules)
vol -f memory.lime linux.lsmod

# Compare loaded modules against expected list
# Hidden modules: in memory but not in lsmod output = rootkit indicator

# Network connections
vol -f memory.lime linux.sockstat

# Open files per process
vol -f memory.lime linux.lsof --pid [pid]

# Environment variables (may contain secrets)
vol -f memory.lime linux.envars --pid [pid]

# Mounted filesystems
vol -f memory.lime linux.mountinfo

# Check for process hiding
# Compare linux.pslist (task list traversal) vs linux.psscan (memory scanning)
# Processes in psscan but not pslist are hidden (DKOM rootkit)
```

## Anti-Patterns

- **Analyzing memory without disk context**: Memory tells you what was running. Disk tells you what was installed and how it got there. Analyze both together for a complete picture.
- **Trusting process names**: A process named svchost.exe is only legitimate if it matches the expected path, parent process, and behavior. Adversaries name their malware after legitimate processes.
- **Skipping psscan**: Relying only on pslist (linked list traversal) misses processes hidden by rootkits that unlink EPROCESS structures. Always compare pslist against psscan.
- **Running Volatility on the wrong symbol table**: Volatility 3 needs the correct symbol table for the OS version. Using the wrong one produces garbage output. Verify with `windows.info` or `linux.banner` first.
- **Acquiring memory after shutting down**: Powering off the system destroys all volatile evidence. Memory acquisition must happen while the system is running (or from a hibernation file/crash dump as a last resort).
- **Not hashing the memory image**: Without a hash at acquisition time, there is no way to prove the memory image was not modified during analysis.

## References

- Volatility 3 Documentation: https://volatility3.readthedocs.io/
- Volatility 3 Source (GitHub): https://github.com/volatilityfoundation/volatility3
- The Art of Memory Forensics (book): Ligh, Case, Levy, Walters -- the definitive reference
- SANS Memory Forensics Cheat Sheet: https://www.sans.org/posters/memory-forensics-cheat-sheet/
- WinPMem: https://github.com/Velocidex/WinPmem
- LiME: https://github.com/504ensicsLabs/LiME
- AVML: https://github.com/microsoft/avml
- YARA Documentation: https://yara.readthedocs.io/
- Volatility Plugin Reference: https://volatility3.readthedocs.io/en/latest/volatility3.plugins.html
