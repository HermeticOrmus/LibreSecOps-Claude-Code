# Recon Methodology

> Comprehensive reconnaissance methodology for authorized bug bounty programs covering subdomain enumeration, technology fingerprinting, content discovery, and attack surface mapping.

## Knowledge Base

### Recon Philosophy

Reconnaissance is the foundation of bug bounty hunting. The depth and quality of your recon directly determines the uniqueness and impact of your findings. Most hunters run the same automated tools against the same targets. The difference is in methodology -- how you process, correlate, and act on recon data.

The key insight: **the most interesting targets are the ones nobody else is testing** -- forgotten subdomains, old API versions, acquired domains, staging environments, internal tools accidentally exposed. Deep recon reveals these.

### Passive Reconnaissance (No Target Interaction)

**Certificate Transparency**:
```bash
# crt.sh - Query CT logs for all certificates issued to a domain
curl -s "https://crt.sh/?q=%.example.com&output=json" | jq -r '.[].name_value' | sort -u

# CertSpotter
curl -s "https://api.certspotter.com/v1/issuances?domain=example.com&include_subdomains=true" | jq -r '.[].dns_names[]' | sort -u
```

**DNS passive sources**:
- SecurityTrails API: Historical DNS records, subdomains, associated domains
- VirusTotal: Passive DNS, subdomains, related URLs
- AlienVault OTX: Passive DNS, threat context
- RapidDNS: `https://rapiddns.io/subdomain/example.com`
- DNSDumpster: Visual DNS mapping

**Search engine dorking**:
```
# Subdomain discovery
site:example.com -www

# Exposed files
site:example.com filetype:pdf | filetype:doc | filetype:xls
site:example.com filetype:env | filetype:yml | filetype:config

# Admin panels
site:example.com inurl:admin | inurl:panel | inurl:dashboard

# Error messages (technology disclosure)
site:example.com "error" | "exception" | "stack trace" | "debug"

# Login pages
site:example.com inurl:login | inurl:signin | inurl:auth

# API documentation
site:example.com inurl:api | inurl:swagger | inurl:graphql
```

**GitHub/GitLab dorking**:
```
# Search for credentials, internal URLs, configuration
"example.com" password
"example.com" api_key
"example.com" secret
org:targetcompany password
org:targetcompany AWS_SECRET_ACCESS_KEY
```

Tools: truffleHog, git-secrets, gitleaks for automated secret scanning in repositories.

**Wayback Machine / CommonCrawl**:
```bash
# Get historical URLs
waybackurls example.com > wayback_urls.txt

# Filter for interesting patterns
cat wayback_urls.txt | grep -E "\.(json|xml|yml|config|env|bak|sql|log)" | sort -u
cat wayback_urls.txt | grep -E "(api|admin|internal|staging|dev|test)" | sort -u
cat wayback_urls.txt | grep -E "(token|key|secret|password|auth)" | sort -u

# GAU (GetAllUrls) - multiple sources
gau example.com --subs --o allurls.txt
```

**Cloud asset discovery**:
```bash
# S3 bucket patterns
# [company].[region].amazonaws.com
# [company]-backup, [company]-staging, [company]-dev

# Azure Blob: [company].blob.core.windows.net
# GCP Storage: storage.googleapis.com/[company]

# Tools
cloud_enum -k example -k examplecorp
```

### Active Reconnaissance (Within Scope)

**Subdomain brute-forcing**:
```bash
# Amass (comprehensive, multiple sources + brute force)
amass enum -d example.com -passive -o amass_passive.txt
amass enum -d example.com -brute -w /path/to/wordlist -o amass_active.txt

# Subfinder (fast, passive + active)
subfinder -d example.com -all -o subfinder.txt

# Combine and deduplicate
cat amass_*.txt subfinder.txt crtsh.txt | sort -u > all_subdomains.txt
```

**HTTP probing**:
```bash
# Identify live web services
httpx -l all_subdomains.txt -silent -status-code -title -tech-detect -content-length -follow-redirects -o live_hosts.txt

# Filter interesting responses
cat live_hosts.txt | grep -v "404\|301 " | sort
```

**Port scanning** (if allowed by program):
```bash
# Fast scan of common ports
naabu -list all_subdomains.txt -top-ports 1000 -silent -o ports.txt

# Service detection on found ports
nmap -sV -p [found_ports] [target_ips] -oN nmap_services.txt
```

**Content discovery**:
```bash
# ffuf - fast web fuzzer
ffuf -u https://target.example.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -mc 200,301,302,403 -o results.json

# API endpoint discovery
ffuf -u https://api.example.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/api/api-endpoints.txt -mc all -fc 404

# Parameter discovery
ffuf -u "https://target.example.com/endpoint?FUZZ=test" -w /usr/share/seclists/Discovery/Web-Content/burp-parameter-names.txt -mc 200 -fs [baseline_size]
```

**JavaScript analysis**:
```bash
# Extract JS file URLs
cat live_hosts.txt | waybackurls | grep "\.js$" | sort -u > js_files.txt

# Extract endpoints from JS
cat js_files.txt | while read url; do
  python3 linkfinder.py -i "$url" -o cli
done | sort -u > js_endpoints.txt

# Search for secrets in JS
cat js_files.txt | while read url; do
  curl -s "$url" | grep -oE "(api[_-]?key|token|secret|password|auth)['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]"
done
```

### Attack Surface Mapping

After recon, consolidate findings into an attack surface map:

| Category | What to Map | Why It Matters |
|----------|-------------|---------------|
| Subdomains | All discovered hosts | Forgotten hosts have outdated software |
| Technologies | Web servers, frameworks, CMS | Known CVEs, framework-specific vulnerabilities |
| Entry points | Login pages, registration, file upload, API endpoints | Each entry point is a testing target |
| APIs | REST, GraphQL, WebSocket endpoints | APIs often have weaker security than web UIs |
| Authentication | OAuth, SAML, JWT, session cookies | Auth implementation flaws are high-impact |
| Third-party | CDNs, SaaS integrations, widgets | Subdomain takeover, data leakage |
| Cloud assets | S3, Blob, GCP Storage, serverless | Misconfiguration, public access |
| Admin panels | CMS admin, database admin, monitoring | Default credentials, exposed management |

## Patterns

### Pattern: Subdomain Monitoring
Set up continuous monitoring for new subdomains on target domains. New subdomains often represent new features or services deployed without full security review.
```bash
# Run daily and diff against previous results
subfinder -d example.com -silent > today.txt
diff yesterday.txt today.txt | grep "^>" | sed 's/^> //'
```

### Pattern: Technology-Specific Testing
After fingerprinting the technology stack, focus testing on known vulnerability patterns for that stack. WordPress sites get WordPress-specific tests; Spring applications get Spring-specific tests.

### Pattern: API Version Discovery
When an API v2 is in use, test for v1, v3, and other versions. Older API versions may lack security controls added in newer versions.
```bash
ffuf -u https://api.example.com/vFUZZ/users -w <(seq 1 10) -mc all -fc 404
```

## Anti-Patterns

- **Scanning without recon**: Running Nuclei or Burp Active Scan against the main domain without first understanding the target. This finds only what automated tools find and misses the unique, high-value targets
- **Ignoring scope**: Testing assets adjacent to but outside the scope. This can result in platform bans and legal consequences
- **Tool-only approach**: Running tools without understanding what they do or how to interpret results. Tools are force multipliers for knowledge, not substitutes for it
- **No organization**: Running recon without organizing results. Use structured directories, consistent naming, and a tracking document
- **Skipping passive recon**: Jumping to active scanning misses historical data, exposed credentials, and intelligence that passive sources provide for free

## References

- Bug Bounty Methodology by @jhaddix -- https://www.bugcrowd.com/resources/webinars/how-to-bug-bounty-methodology-v4/
- The Bug Hunter's Methodology by Jason Haddix -- https://github.com/jhaddix/tbhm
- SecLists (wordlists) -- https://github.com/danielmiessler/SecLists
- Assetnote Wordlists -- https://wordlists.assetnote.io/
- HackerOne Hacktivity (public reports) -- https://hackerone.com/hacktivity
- PortSwigger Web Security Academy -- https://portswigger.net/web-security
- ProjectDiscovery tools -- https://github.com/projectdiscovery
- OWASP Testing Guide v4.2 -- https://owasp.org/www-project-web-security-testing-guide/
