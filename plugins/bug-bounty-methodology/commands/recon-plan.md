# /recon-plan

> Generate a structured reconnaissance plan for an authorized bug bounty target, with passive and active recon phases, tool recommendations, and prioritized attack surface mapping.

## Trigger

Use at the start of a bug bounty engagement after reviewing the program scope. Appropriate when:
- Beginning testing on a new bug bounty program
- Expanding recon on an existing target after initial testing
- Planning recon for a specific asset type (API, mobile, cloud)
- Refreshing recon on a target with updated scope

## Input

- **Program name and platform**: Where the program is hosted (HackerOne, Bugcrowd, etc.)
- **Scope**: In-scope domains, applications, IP ranges, and mobile apps
- **Out of scope**: Explicitly excluded targets and testing techniques
- **Program rules**: Key rules affecting methodology (rate limits, no automated scanning, etc.)
- **Your skills and tools**: What testing capabilities you have (Burp Pro, mobile testing setup, cloud experience)
- **Previous findings** (optional): Known vulnerabilities or areas already tested

## Process

1. **Scope analysis** -- Parse the scope to identify all testable assets and explicit boundaries. Map wildcard scopes (*.example.com) vs specific assets (app.example.com).

2. **Passive reconnaissance** (no direct target interaction):

   **Subdomain enumeration**:
   - Certificate Transparency logs: `crt.sh`, `certspotter`
   - DNS datasets: SecurityTrails, DNSDumpster, RapidDNS
   - Search engines: Google dorks (`site:example.com`), Bing, DuckDuckGo
   - GitHub/GitLab code search: Subdomains, API keys, internal URLs
   - Wayback Machine: Historical subdomains, removed pages, old API endpoints
   - Passive DNS: PassiveTotal, VirusTotal, AlienVault OTX

   **Technology intelligence**:
   - Shodan/Censys: Open ports, services, certificates, technologies
   - BuiltWith/Wappalyzer data: Technology stack information
   - Job postings: Technologies mentioned in hiring (reveals internal stack)

   **Data exposure**:
   - GitHub/GitLab: Code repositories, leaked credentials, configuration files
   - Pastebin/paste sites: Leaked data, credentials, configuration
   - Google dorking: Exposed files, admin panels, error messages
   - Cloud storage: S3 buckets, Azure Blobs, GCP Storage naming patterns

3. **Active reconnaissance** (within scope, respecting rate limits):

   **Subdomain validation and expansion**:
   - DNS brute-forcing: `subfinder`, `amass`, custom wordlists
   - HTTP probing: `httpx` to identify live web services
   - Virtual host discovery: Testing for additional virtual hosts on known IPs
   - Port scanning: `naabu` or `nmap` on confirmed in-scope IPs (if allowed by program rules)

   **Content discovery**:
   - Directory/file brute-forcing: `ffuf`, `feroxbuster` with targeted wordlists
   - API endpoint discovery: Common API paths, Swagger/OpenAPI documentation, GraphQL introspection
   - JavaScript analysis: `LinkFinder`, manual JS review for hidden endpoints, API keys, internal paths
   - robots.txt, sitemap.xml, .well-known paths

   **Technology fingerprinting**:
   - HTTP response analysis: Server headers, cookies, error pages
   - Framework detection: Version-specific behaviors, default files
   - WAF detection: WAF fingerprinting to understand filtering

4. **Attack surface mapping** -- Consolidate findings into a prioritized map of testable assets with technology context.

## Output

```
## Reconnaissance Plan: [Program Name]

### Scope Summary
**In scope**: [parsed scope with asset types]
**Out of scope**: [exclusions]
**Key rules**: [rules affecting methodology]

### Phase 1: Passive Reconnaissance

#### Subdomain Enumeration
```bash
# Certificate Transparency
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sort -u

# Subfinder (passive only)
subfinder -d example.com -silent -o subdomains.txt

# GitHub dorking
# Search: "example.com" in code, looking for subdomains, API keys, config
```

#### Technology Intelligence
```bash
# Shodan
shodan search "ssl.cert.subject.cn:example.com"

# Historical data
waybackurls example.com | sort -u > wayback_urls.txt
```

#### Data Exposure Checks
[Specific Google dorks, GitHub search queries, cloud storage patterns]

### Phase 2: Active Reconnaissance

#### Subdomain Validation
```bash
# Probe live hosts
cat subdomains.txt | httpx -silent -status-code -title -tech-detect -o live_hosts.txt

# Port scan (if allowed)
naabu -list subdomains.txt -p - -silent -o ports.txt
```

#### Content Discovery
```bash
# Directory brute-forcing
ffuf -u https://TARGET/FUZZ -w /path/to/wordlist -mc 200,301,302,403 -o results.json

# API discovery
ffuf -u https://api.TARGET/FUZZ -w /path/to/api-wordlist -mc 200,401,403
```

#### JavaScript Analysis
```bash
# Extract endpoints from JS files
cat js_urls.txt | while read url; do
  python3 linkfinder.py -i "$url" -o cli
done
```

### Phase 3: Attack Surface Map

| Asset | Type | Technology | Open Ports | Priority | Notes |
|-------|------|-----------|-----------|----------|-------|
| [subdomain] | [web/api/admin] | [stack] | [ports] | [P1-P3] | [why interesting] |

### Testing Priority
1. **[Asset]** -- [Rationale: old technology, exposed admin, API without auth, etc.]
2. **[Asset]** -- [Rationale]
3. **[Asset]** -- [Rationale]

### Monitoring Plan
[Set up subdomain monitoring for new assets: subfinder, crt.sh alerts]
```
