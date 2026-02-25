# Secret Detection

> Detection patterns, tool configuration, regex patterns for common secret types, and false positive management for secret scanning.

## Knowledge Base

### Detection Approaches

**Pattern-based detection** matches known credential formats using regular expressions. This is the most reliable approach with the lowest false positive rate, but it only catches secrets with known formats.

**Entropy-based detection** identifies strings with unusually high Shannon entropy (randomness). Catches secrets without known formats but produces more false positives on minified code, UUIDs, and encoded data.

**Verification-based detection** takes a detected pattern and attempts to validate it against the issuing service's API. This eliminates false positives completely but requires network access and may trigger rate limits or security alerts.

**Contextual detection** examines variable names, configuration keys, and surrounding code to identify secrets. A random-looking string assigned to `AWS_SECRET_ACCESS_KEY` is more likely a secret than the same string in a UUID field.

### Common Secret Formats

| Secret Type | Pattern / Prefix | Length | Example (MASKED) |
|-------------|-----------------|--------|------------------|
| AWS Access Key ID | `AKIA` | 20 chars | AKIA************XXXX |
| AWS Secret Access Key | Base64-like | 40 chars | ******** (high entropy) |
| GitHub PAT (fine-grained) | `github_pat_` | 82+ chars | github_pat_******* |
| GitHub PAT (classic) | `ghp_` | 40 chars | ghp_**** |
| GitHub OAuth | `gho_` | 40 chars | gho_**** |
| GitHub App Install Token | `ghs_` | 40 chars | ghs_**** |
| GitLab PAT | `glpat-` | 20 chars | glpat-******* |
| Slack Bot Token | `xoxb-` | varies | xoxb-****-**** |
| Slack User Token | `xoxp-` | varies | xoxp-****-**** |
| Stripe Live Secret Key | `sk_live_` | varies | sk_live_******* |
| Stripe Live Publishable | `pk_live_` | varies | pk_live_******* |
| Twilio API Key | `SK` | 32 chars | SK****** |
| SendGrid API Key | `SG.` | varies | SG.******* |
| Google API Key | `AIza` | 39 chars | AIza******* |
| GCP Service Account | JSON with `private_key` | varies | {"type": "service_account", ...} |
| RSA Private Key | `-----BEGIN RSA PRIVATE KEY-----` | varies | PEM format |
| SSH Private Key | `-----BEGIN OPENSSH PRIVATE KEY-----` | varies | OpenSSH format |
| JWT | `eyJ` (Base64 of `{"`) | 3 parts dot-separated | eyJhbGci... |
| Generic password in URL | `://user:pass@host` | varies | postgres://admin:****@db:5432 |

## Patterns

### Pattern 1: gitleaks Configuration

```toml
# .gitleaks.toml -- Custom gitleaks configuration
title = "Custom Secret Detection Rules"

# Extend the default ruleset
[extend]
useDefault = true

# Custom rules for organization-specific secrets
[[rules]]
id = "internal-api-key"
description = "Internal API key pattern"
regex = '''(?i)INTERNAL[-_]?API[-_]?KEY\s*[:=]\s*['"]?([a-zA-Z0-9]{32,64})['"]?'''
entropy = 3.5
secretGroup = 1
tags = ["internal", "api-key"]

[[rules]]
id = "database-url-with-password"
description = "Database connection string with embedded password"
regex = '''(?i)(postgres(?:ql)?|mysql|mongodb(?:\+srv)?|redis|amqp)://[^:]+:([^@\s]{8,})@[^\s]+'''
secretGroup = 2
tags = ["database", "connection-string"]

[[rules]]
id = "private-key-inline"
description = "Private key material in code"
regex = '''-----BEGIN (RSA |EC |OPENSSH |DSA |ED25519 )?PRIVATE KEY-----'''
tags = ["private-key"]

# Allowlist -- known false positives
[allowlist]
description = "Global allowlist"
paths = [
  '''(.*/)?\.gitleaks\.toml$''',
  '''(.*/)?test[s]?/.*''',
  '''(.*/)?__test__/.*''',
  '''(.*/)?fixtures/.*''',
  '''(.*/)?vendor/.*''',
  '''(.*/)?node_modules/.*''',
]
regexTarget = "match"
regexes = [
  '''EXAMPLE[_-]?KEY''',
  '''test[_-]?(key|secret|token|password)''',
  '''(fake|dummy|placeholder|changeme|xxx+)''',
]

# Per-rule allowlists
[[rules]]
id = "generic-api-key"
description = "Generic API Key"
regex = '''(?i)(api[_-]?key|apikey)\s*[:=]\s*['"]?([a-zA-Z0-9]{20,64})['"]?'''
secretGroup = 2
entropy = 3.5
[rules.allowlist]
regexes = [
  '''(?i)example|test|fake|dummy|placeholder''',
]
paths = [
  '''.*\.md$''',
  '''.*\.example$''',
]
```

### Pattern 2: trufflehog with Verification

```bash
# Scan git repository with verification of live secrets
trufflehog git file://. \
  --only-verified \
  --json \
  --concurrency 10 \
  2>/dev/null | jq -r '
    select(.Verified == true) |
    "\(.DetectorName) | \(.SourceMetadata.Data.Git.file):\(.SourceMetadata.Data.Git.line) | \(.SourceMetadata.Data.Git.commit[:8])"
  '

# Scan filesystem (no git history)
trufflehog filesystem /path/to/code --json --only-verified

# Scan a Docker image
trufflehog docker --image nginx:latest --json

# Scan a GitHub organization (all repos)
trufflehog github --org=my-org --token=$GITHUB_TOKEN --json --only-verified
```

### Pattern 3: Pre-commit Secret Prevention

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.18.4
    hooks:
      - id: gitleaks
        # Use custom config if it exists
        args: ['--config=.gitleaks.toml']

  # Backup: detect-secrets as a second layer
  - repo: https://github.com/Yelp/detect-secrets
    rev: v1.4.0
    hooks:
      - id: detect-secrets
        args: ['--baseline', '.secrets.baseline']
        exclude: package-lock\.json|yarn\.lock|go\.sum
```

```bash
# Initialize detect-secrets baseline (mark existing findings as reviewed)
detect-secrets scan --all-files \
  --exclude-files 'package-lock\.json|yarn\.lock|\.min\.js' \
  > .secrets.baseline

# Audit the baseline (interactive review of each finding)
detect-secrets audit .secrets.baseline
```

### Pattern 4: CI/CD Secret Scanning Pipeline Stage

```yaml
# GitHub Actions -- Secret scanning as first pipeline stage
secret-scan:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
      with:
        fetch-depth: 0  # Full history for comprehensive scan

    # Layer 1: gitleaks (fast, pattern-based)
    - name: gitleaks scan
      uses: gitleaks/gitleaks-action@v2
      env:
        GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}

    # Layer 2: trufflehog (verification-based, catches what gitleaks misses)
    - name: trufflehog scan
      uses: trufflesecurity/trufflehog@v3
      with:
        extra_args: --only-verified --results=verified
```

### Pattern 5: Regex Patterns for Manual Scanning

When tools are not available, these patterns catch common secrets:

```python
# Python regex patterns for common secret types
SECRET_PATTERNS = {
    'aws_access_key': r'(?<![A-Z0-9])(AKIA[0-9A-Z]{16})(?![A-Z0-9])',
    'aws_secret_key': r'(?i)aws[_\-\.]?secret[_\-\.]?access[_\-\.]?key\s*[:=]\s*[\'"]?([A-Za-z0-9/+=]{40})[\'"]?',
    'github_pat': r'ghp_[0-9a-zA-Z]{36}',
    'github_fine_grained': r'github_pat_[0-9a-zA-Z]{22}_[0-9a-zA-Z]{59}',
    'gitlab_pat': r'glpat-[0-9a-zA-Z\-_]{20}',
    'slack_token': r'xox[bpors]-[0-9a-zA-Z\-]{10,}',
    'stripe_live': r'sk_live_[0-9a-zA-Z]{24,}',
    'sendgrid': r'SG\.[0-9A-Za-z\-_]{22}\.[0-9A-Za-z\-_]{43}',
    'twilio': r'SK[0-9a-fA-F]{32}',
    'google_api': r'AIza[0-9A-Za-z\-_]{35}',
    'private_key': r'-----BEGIN (RSA |EC |OPENSSH |DSA |ED25519 )?PRIVATE KEY-----',
    'generic_secret': r'(?i)(password|secret|token|api[_-]?key|credential)\s*[:=]\s*[\'"]([^\'"]{8,})[\'"]',
    'connection_string': r'(?i)(postgres(?:ql)?|mysql|mongodb(?:\+srv)?|redis)://[^:]+:[^@\s]+@[^\s]+',
    'jwt': r'eyJ[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}\.[A-Za-z0-9_-]{10,}',
}
```

## Anti-Patterns

- **Relying solely on entropy detection**: High entropy catches random-looking strings but also matches minified JavaScript, UUID fields, base64-encoded non-secret data, and cryptographic hashes. Always combine with pattern-based detection.
- **No allowlist management**: Without a maintained allowlist, teams either ignore all findings (too many false positives) or waste time reviewing the same false positives repeatedly. Maintain `.gitleaks.toml` and `.secrets.baseline` as part of the codebase.
- **Scanning only HEAD, not history**: `git rm secret.env` does not remove the secret from history. Always scan with `--all` or `--depth 0` for comprehensive coverage.
- **Excluding test directories from scanning**: Test fixtures sometimes contain real credentials copied from production for debugging. Exclude known-fake patterns, not entire directories.
- **Not verifying before alerting**: Unverified findings require human investigation. Verified findings require immediate rotation. The distinction matters for triage speed. Use trufflehog's `--only-verified` for the most actionable results.
- **Scanning only at commit time**: Pre-commit hooks are a prevention layer. They can be bypassed with `--no-verify`. CI/CD scanning is the enforcement layer that catches what pre-commit missed.

## References

- gitleaks: https://github.com/gitleaks/gitleaks
- trufflehog: https://github.com/trufflesecurity/trufflehog
- detect-secrets: https://github.com/Yelp/detect-secrets
- GitGuardian (research reports): https://www.gitguardian.com/state-of-secrets-sprawl
- OWASP Secrets Management Cheat Sheet: https://cheatsheetseries.owasp.org/cheatsheets/Secrets_Management_Cheat_Sheet.html
- CIS Software Supply Chain Security Guide: https://www.cisecurity.org/insights/white-papers/cis-software-supply-chain-security-guide
