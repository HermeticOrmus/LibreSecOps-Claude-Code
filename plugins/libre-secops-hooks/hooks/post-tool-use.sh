#!/usr/bin/env bash
# =============================================================================
# LibreSecOps PostToolUse hook
# =============================================================================
# Runs after Edit, Write, and MultiEdit.
#
# Claude Code sends the hook input as JSON on stdin; this hook reads
# tool_name, tool_input.file_path, and cwd with jq, then scans the edited file
# with local pattern matching (no network calls, no files written):
#
#  1. SQL injection (string building in queries, raw query APIs)
#  2. XSS sinks (innerHTML, dangerouslySetInnerHTML, v-html, {@html}, ...)
#  3. Hardcoded secrets (API keys, AWS keys, tokens, private keys, DSNs)
#  4. Insecure cryptography (MD5/SHA1 for passwords, weak TLS, ECB, weak RNG)
#  5. Command injection (eval, child_process, os.system, shell=True, ...)
#  6. Path traversal (file access built from request input)
#  7. CORS misconfiguration (wildcards, origin reflection, credentials)
#  8. Missing input validation on request data
#  9. Insecure deserialization (pickle, yaml.load, unserialize, ...)
# 10. Auth endpoints without visible rate limiting
# 11. Dockerfile issues (root user, unpinned images, copied secrets)
#
# It also adds a short checklist for security-sensitive file types (auth,
# database, API routes, CORS and header config, containers, Kubernetes,
# Terraform, CI/CD), which the PreToolUse hook used to print before the edit.
#
# Output: only when there is something to say, a JSON object with
# hookSpecificOutput.additionalContext for Claude, plus a one-line
# systemMessage for the person when a finding is CRITICAL. Pattern matching
# gives false positives; treat findings as prompts to look, not verdicts.
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat)"
TOOL_NAME="$(jq -r '.tool_name // empty' <<<"$INPUT" 2>/dev/null || true)"
FILE_PATH="$(jq -r '.tool_input.file_path // empty' <<<"$INPUT" 2>/dev/null || true)"
CWD="$(jq -r '.cwd // empty' <<<"$INPUT" 2>/dev/null || true)"
CWD="${CWD:-$PWD}"

case "$TOOL_NAME" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac
[[ -n "$FILE_PATH" && -f "$FILE_PATH" ]] || exit 0

FILE_NAME="$(basename "$FILE_PATH")"
FILE_DIR="$(dirname "$FILE_PATH")"
FILE_NAME_LOWER="$(tr '[:upper:]' '[:lower:]' <<<"$FILE_NAME")"
FILE_PATH_LOWER="$(tr '[:upper:]' '[:lower:]' <<<"$FILE_PATH")"
FILE_EXT=""
[[ "$FILE_NAME" == *.* ]] && FILE_EXT="$(tr '[:upper:]' '[:lower:]' <<<"${FILE_NAME##*.}")"
REL_PATH="${FILE_PATH#"$CWD"/}"

# Skip binary and media files.
case "$FILE_EXT" in
  png|jpg|jpeg|gif|svg|ico|webp|woff|woff2|ttf|eot|mp4|mp3|pdf|zip|tar|gz|tgz|jar|so|dylib|dll|exe|bin) exit 0 ;;
esac

# Read at most 100 KB so the scan stays fast on large files.
CONTENT="$(head -c 102400 "$FILE_PATH" 2>/dev/null || true)"
[[ -n "$CONTENT" ]] || exit 0

IS_CODE=false
IS_TEMPLATE=false
IS_CONFIG=false
case "$FILE_EXT" in
  js|ts|jsx|tsx|mjs|cjs|py|go|rb|java|kt|scala|rs|php|sql|prisma|vue|svelte) IS_CODE=true ;;
  html|htm|ejs|hbs|handlebars|pug|jade|njk|jinja|j2|twig) IS_TEMPLATE=true ;;
  yaml|yml|json|toml|ini|conf|cfg|properties|tf|tfvars|env) IS_CONFIG=true ;;
esac
[[ "$FILE_NAME_LOWER" =~ ^dockerfile || "$FILE_NAME_LOWER" =~ \.dockerfile$ ]] && IS_CONFIG=true
[[ "$FILE_NAME_LOWER" =~ ^\.env ]] && IS_CONFIG=true

CRITICAL=()
HIGH=()
MEDIUM=()
LOW=()
NOTES=()

# Arrays are expanded as ${arr[@]+"${arr[@]}"} where they may be empty, so
# the scripts also run under bash 3.2 (the macOS default) with set -u.

# Matching helpers. Here-strings instead of pipes from echo, so an early exit
# from grep -q cannot turn a match into a SIGPIPE failure under pipefail.
has()   { grep -qE  -- "$1" <<<"$CONTENT"; }
hasi()  { grep -qiE -- "$1" <<<"$CONTENT"; }
# Some line matches $1 and that same line does not match $2.
has_not() {
  local m
  m="$(grep -E -- "$1" <<<"$CONTENT" || true)"
  [[ -n "$m" ]] && grep -qvE -- "$2" <<<"$m"
}
hasi_not() {
  local m
  m="$(grep -iE -- "$1" <<<"$CONTENT" || true)"
  [[ -n "$m" ]] && grep -qviE -- "$2" <<<"$m"
}
# Some line matches $1 and that same line also matches $2 (case-insensitive).
has_with() {
  local m
  m="$(grep -E -- "$1" <<<"$CONTENT" || true)"
  [[ -n "$m" ]] && grep -qiE -- "$2" <<<"$m"
}

ENV_READS='process\.env|os\.environ|os\.getenv|getenv\(|env\(|env\[|ENV\['
PLACEHOLDERS='example|placeholder|your[_-]|xxx|changeme|todo|replace|dummy|fake|<[a-z_-]+>'

# =============================================================================
# 1. SQL injection
# =============================================================================
check_sql_injection() {
  if has_not "(\"|')(SELECT|INSERT|UPDATE|DELETE)\s.*\+" '^\s*(//|#|\*|/\*)'; then
    HIGH+=("SQL injection: string concatenation in a SQL query. Use parameterized queries.")
  fi
  if has_not '`(SELECT|INSERT|UPDATE|DELETE)\s[^`]*\$\{' '^\s*(//|\*|/\*)'; then
    HIGH+=("SQL injection: template literal interpolation in a SQL query. Use placeholders (\$1, ?, :param) or a tagged sql template.")
  fi
  if has_not "f\"(SELECT|INSERT|UPDATE|DELETE)\s|f'(SELECT|INSERT|UPDATE|DELETE)\s" '^\s*#'; then
    HIGH+=("SQL injection: Python f-string in a SQL query. Pass parameters to execute() instead.")
  fi
  if has_not "[\"'](SELECT|INSERT|UPDATE|DELETE)\s.*\.format\(" '^\s*#'; then
    HIGH+=("SQL injection: Python .format() in a SQL query. Pass parameters to execute() instead.")
  fi
  if has_not 'fmt\.Sprintf\(\s*"(SELECT|INSERT|UPDATE|DELETE)' '^\s*//'; then
    HIGH+=("SQL injection: Go fmt.Sprintf builds a SQL query. Use prepared statements with placeholders.")
  fi
  if has "\.(rawQuery|raw|unsafeRaw|executeRaw)\s*\(\s*[\"'\`]?\s*(SELECT|INSERT|UPDATE|DELETE)"; then
    MEDIUM+=("SQL: raw query API in use. Make sure every value is bound as a parameter.")
  fi
  if has '\$executeRawUnsafe|\$queryRawUnsafe'; then
    HIGH+=("SQL injection: Prisma \$queryRawUnsafe/\$executeRawUnsafe. Use \$queryRaw with the Prisma.sql tagged template.")
  elif has '\$executeRaw|\$queryRaw'; then
    MEDIUM+=("SQL: Prisma raw query. Pass values through the tagged template, never by string building.")
  fi
}

# =============================================================================
# 2. XSS
# =============================================================================
check_xss() {
  has 'dangerouslySetInnerHTML' && HIGH+=("XSS: dangerouslySetInnerHTML. Sanitize with DOMPurify (or similar) before rendering.")
  if has_not '\.innerHTML\s*=' '^\s*(//|\*|/\*)'; then
    HIGH+=("XSS: innerHTML assignment. Use textContent for text, or sanitize the HTML first.")
  fi
  has '\.outerHTML\s*=' && HIGH+=("XSS: outerHTML assignment. Sanitize content before injecting it.")
  has 'document\.write\s*\(' && MEDIUM+=("XSS: document.write(). Prefer DOM APIs.")
  has 'v-html' && HIGH+=("XSS: Vue v-html. Sanitize the bound content.")
  has '\[innerHTML\]' && MEDIUM+=("XSS: Angular [innerHTML] binding. Rely on DomSanitizer and never bypass it for user data.")
  has '\{@html' && HIGH+=("XSS: Svelte {@html}. Sanitize the content.")
  has '<%-|\{\{\{|\{%\s*autoescape\s+false' && MEDIUM+=("XSS: unescaped template output. Use the escaping form for user data.")
  has '\|\s*safe\b' && MEDIUM+=("XSS: template 'safe' filter. Use it only on trusted content.")
  return 0
}

# =============================================================================
# 3. Hardcoded secrets
# =============================================================================
check_hardcoded_secrets() {
  # .env files are where secrets are expected to live.
  [[ "$FILE_NAME_LOWER" =~ ^\.env ]] && return 0

  if hasi_not "(api[_-]?key|apikey|api[_-]?secret)\s*[:=]\s*['\"][A-Za-z0-9_\-]{16,}" "$ENV_READS|$PLACEHOLDERS"; then
    CRITICAL+=("Secrets: possible hardcoded API key. Load it from the environment or a secrets manager.")
  fi
  if has '(AKIA|ASIA)[A-Z0-9]{16}'; then
    CRITICAL+=("Secrets: AWS access key ID in the file. Rotate it and use IAM roles or environment variables.")
  fi
  if hasi_not "(password|passwd|secret|token|private[_-]?key)\s*[:=]\s*['\"][^'\"]{8,}" "$ENV_READS|$PLACEHOLDERS|hash|bcrypt|argon|\*\*\*|type|interface|schema|model|validation|zod|yup|joi|describe|test|spec|mock"; then
    HIGH+=("Secrets: possible hardcoded password, secret, or token. Use environment variables or a secrets manager.")
  fi
  if hasi_not "(jwt[_-]?secret)\s*[:=]\s*['\"][^'\"]{4,}" "$ENV_READS|$PLACEHOLDERS"; then
    CRITICAL+=("Secrets: hardcoded JWT secret. Anyone holding it can forge tokens; load it from the environment.")
  fi
  if has '-----BEGIN (RSA |EC |DSA |OPENSSH |ENCRYPTED )?PRIVATE KEY-----'; then
    CRITICAL+=("Secrets: private key embedded in the file. Move it to a protected file or secret store and reference it.")
  fi
  if has_not '(postgres(ql)?|mysql|mongodb(\+srv)?|redis|amqp)://[^:/@ ]+:[^@ ]+@' "$ENV_READS|localhost|127\.0\.0\.1|$PLACEHOLDERS"; then
    HIGH+=("Secrets: connection string with embedded credentials. Build it from environment variables.")
  fi
  if has '(ghp_[A-Za-z0-9]{36}|gho_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{22,}|glpat-[A-Za-z0-9_-]{20})'; then
    CRITICAL+=("Secrets: GitHub or GitLab access token. Revoke and rotate it.")
  fi
  if has 'xox[baprs]-[A-Za-z0-9-]{10,}'; then
    CRITICAL+=("Secrets: Slack token. Revoke it and load the replacement from the environment.")
  fi
  if has '(sk_live_|rk_live_)[A-Za-z0-9]{20,}'; then
    CRITICAL+=("Secrets: Stripe live secret key. Roll it in the Stripe dashboard and load it from the environment.")
  fi
  return 0
}

# =============================================================================
# 4. Insecure cryptography
# =============================================================================
check_insecure_crypto() {
  if has_with "(createHash\(['\"]md5|hashlib\.md5|\bmd5\(|MD5\.Create|Digest::MD5)" '(password|passwd|secret|token|credential)'; then
    HIGH+=("Crypto: MD5 used near password or secret handling. Hash passwords with argon2id, bcrypt, or scrypt.")
  elif has_not "createHash\(['\"]md5['\"]|hashlib\.md5|\bmd5\(" 'checksum|integrity|fingerprint|etag|cache'; then
    LOW+=("Crypto: MD5 in use. Fine for non-security checksums; use SHA-256 or better for anything security-related.")
  fi
  if has_with "(createHash\(['\"]sha1|hashlib\.sha1|SHA1\.Create)" '(password|passwd|secret|credential)'; then
    HIGH+=("Crypto: SHA-1 used for password hashing. Use argon2id, bcrypt, or scrypt.")
  fi
  if has_with 'Math\.random\(\)' '(token|secret|key|password|passwd|nonce|salt|uuid|session|otp)'; then
    HIGH+=("Crypto: Math.random() for a security-sensitive value. Use crypto.randomBytes() or crypto.getRandomValues().")
  fi
  if [[ "$FILE_EXT" == "py" ]] && has '^\s*(import random|from random import)' && hasi '(token|secret|password|nonce|salt|otp)'; then
    MEDIUM+=("Crypto: Python 'random' module in a file that handles secrets. Use the 'secrets' module for security values.")
  fi
  if has '(TLSv1(\.[01]|_[01])?|SSLv[23]|TLS_1_[01])([^0-9._]|$)'; then
    HIGH+=("Crypto: TLS 1.0/1.1 or SSL enabled. Require TLS 1.2 or 1.3.")
  fi
  if hasi '\becb\b|mode_ecb'; then
    HIGH+=("Crypto: ECB cipher mode. Use an authenticated mode such as AES-GCM.")
  fi
  return 0
}

# =============================================================================
# 5. Command injection
# =============================================================================
check_command_injection() {
  if has_not '\beval\s*\(' '^\s*(//|#|\*|/\*)|eslint|webpack|babel|jest'; then
    HIGH+=("Injection: eval(). Replace it with a parser for the specific format (for example JSON.parse).")
  fi
  if has_not 'new\s+Function\s*\(' '^\s*(//|\*|/\*)'; then
    MEDIUM+=("Injection: new Function(). Same risk as eval with user-controlled input.")
  fi
  if has 'child_process'; then
    if has "(exec|execSync)\s*\(\s*[\`\"'][^)]*\\\$\{"; then
      HIGH+=("Injection: shell command built with interpolation. Use execFile or spawn with an argument array.")
    elif has '\b(exec|execSync|spawn|spawnSync|execFile|execFileSync)\s*\('; then
      MEDIUM+=("Injection: shell command execution. Keep user input out of the command; prefer execFile with an argument array.")
    fi
  fi
  if has_not 'os\.system\(|os\.popen\(' '^\s*#'; then
    HIGH+=("Injection: os.system/os.popen. Use subprocess.run with a list of arguments and shell=False.")
  fi
  has 'subprocess\.(call|run|Popen|check_output|check_call).*shell\s*=\s*True' && HIGH+=("Injection: subprocess with shell=True. Pass a list of arguments with shell=False.")
  has 'exec\.Command\(\s*"(sh|bash|cmd)"' && MEDIUM+=("Injection: Go exec.Command through a shell. Call the program directly with separate arguments.")
  if [[ "$FILE_EXT" == "php" ]] && has_not '\b(system|exec|passthru|shell_exec|popen|proc_open)\s*\(' '^\s*//'; then
    HIGH+=("Injection: PHP shell execution. Escape arguments with escapeshellarg, or avoid the shell.")
  fi
  if [[ "$FILE_EXT" == "rb" ]] && has "(system|exec|%x)\s*\(?\s*[\"'\`].*#\{"; then
    HIGH+=("Injection: Ruby shell command with interpolation. Use the array form of system().")
  fi
  return 0
}

# =============================================================================
# 6. Path traversal
# =============================================================================
check_path_traversal() {
  if has_with '(readFile|readFileSync|writeFile|createReadStream|createWriteStream|\bopen\(|fopen)' '(req\.|request\.|params\.|query\.|body\.|args\[|argv)'; then
    MEDIUM+=("Path traversal: file access with possible request input. Resolve the path and check it stays under the intended base directory.")
  fi
  if has '(path\.join|path\.resolve|os\.path\.join)\s*\(.*\b(req\.|request\.|params|query|body|user_input)'; then
    MEDIUM+=("Path traversal: path built from user input. Verify the resolved path is inside the expected directory.")
  fi
  has 'res\.(sendFile|download)\s*\(.*req\.' && HIGH+=("Path traversal: file served from a request-controlled path. Restrict to an allowed directory.")
  has 'filepath\.Join.*r\.URL|filepath\.Join.*r\.Form|os\.Open.*r\.(URL|Form)' && MEDIUM+=("Path traversal: Go file access from request input. Clean the path and check it against the base directory.")
  return 0
}

# =============================================================================
# 7. CORS
# =============================================================================
check_cors() {
  if has_not "Access-Control-Allow-Origin.*\*|origin:\s*['\"]?\*['\"]?|cors\(\s*\)|allowAllOrigins|AllowAllOrigins" '^\s*(//|#|\*|/\*)'; then
    HIGH+=("CORS: wildcard origin. Restrict to an allowlist of origins in production.")
  fi
  if has_with 'req\.headers?\.origin|request\.headers?\[.origin.\]' 'Access-Control-Allow-Origin|setHeader|header\('; then
    MEDIUM+=("CORS: request Origin reflected. Check it against an allowlist before echoing it back.")
  fi
  if hasi 'Access-Control-Allow-Credentials.*true|credentials:\s*true|allowCredentials.*true' && has 'origin.*\*|Allow-Origin.*\*'; then
    CRITICAL+=("CORS: credentials allowed together with a wildcard origin.")
  fi
  return 0
}

# =============================================================================
# 8. Input validation
# =============================================================================
check_input_validation() {
  if has '(req\.body|req\.params|req\.query|request\.json|request\.form|request\.args)'; then
    if ! hasi '(zod|yup|joi|celebrate|class-validator|express-validator|pydantic|marshmallow|validate|sanitize|Validator|@IsString|@IsEmail|@IsInt)'; then
      LOW+=("Validation: request input used with no visible validation. Validate with a schema library (zod, joi, pydantic, ...).")
    fi
  fi
  if has 'JSON\.parse\s*\(' && ! has 'try\s*\{'; then
    LOW+=("Validation: JSON.parse without error handling. Catch malformed input.")
  fi
  has 'parseInt\s*\(\s*(req\.|request\.|params|query)' && LOW+=("Validation: parseInt on user input. Check it is numeric and pass radix 10.")
  return 0
}

# =============================================================================
# 9. Insecure deserialization
# =============================================================================
check_deserialization() {
  if [[ "$FILE_EXT" == "py" ]]; then
    has 'pickle\.(load|loads)\s*\(' && HIGH+=("Deserialization: pickle can execute code. Use JSON (or another data-only format) for untrusted data.")
    if has_not 'yaml\.load\s*\(' 'SafeLoader|CSafeLoader|safe_load'; then
      HIGH+=("Deserialization: yaml.load without SafeLoader. Use yaml.safe_load().")
    fi
  fi
  if [[ "$FILE_EXT" =~ ^(java|kt|scala)$ ]] && has 'ObjectInputStream|readObject\s*\(|XMLDecoder'; then
    MEDIUM+=("Deserialization: Java object deserialization. Use an allowlist filter (ObjectInputFilter) or a data-only format.")
  fi
  if [[ "$FILE_EXT" == "php" ]] && has '\bunserialize\s*\('; then
    HIGH+=("Deserialization: PHP unserialize. Use json_decode for untrusted data, or set allowed_classes.")
  fi
  if [[ "$FILE_EXT" == "rb" ]] && has 'Marshal\.load\s*\('; then
    HIGH+=("Deserialization: Ruby Marshal.load can execute code. Use JSON for untrusted data.")
  fi
  return 0
}

# =============================================================================
# 10. Rate limiting on auth endpoints
# =============================================================================
check_rate_limiting() {
  if [[ "$FILE_NAME_LOWER" =~ (auth|login|signin|register|signup|password|reset|forgot|verify|otp|2fa|mfa) ]]; then
    if ! hasi '(rateLimit|rate[_-]?limit|throttle|slowDown|RateLimiter|Throttler|limiter)'; then
      MEDIUM+=("Rate limit: auth endpoint with no visible rate limiting. Add limits against brute force and credential stuffing.")
    fi
  fi
  return 0
}

# =============================================================================
# 11. Dockerfile
# =============================================================================
check_docker_security() {
  [[ "$FILE_NAME_LOWER" =~ ^dockerfile || "$FILE_NAME_LOWER" =~ \.dockerfile$ ]] || return 0
  has '^USER root\s*$' && MEDIUM+=("Docker: container runs as root. Add a non-root USER.")
  has '^USER ' || MEDIUM+=("Docker: no USER instruction, so the container runs as root. Add a non-root USER.")
  if has '^FROM\s+\S+:latest\b' || has_not '^FROM\s+[^:@ ]+\s*$' '^FROM\s+scratch'; then
    LOW+=("Docker: image tag is :latest or unpinned. Pin a version or digest.")
  fi
  has '^(COPY|ADD)\s+.*\.(env|pem|key|cert|p12|pfx)\b' && HIGH+=("Docker: secret or key file copied into the image. Use build secrets or runtime mounts.")
  has '^ADD\s+https?://' && MEDIUM+=("Docker: ADD from a URL. Download with a checksum check instead.")
  has '^EXPOSE\s+(22|3306|5432|6379|27017)\b' && LOW+=("Docker: database or SSH port exposed. Keep it on an internal network.")
  return 0
}

if [[ "$IS_CODE" == true || "$IS_TEMPLATE" == true ]]; then
  check_sql_injection
  check_xss
  check_hardcoded_secrets
  check_insecure_crypto
  check_command_injection
  check_path_traversal
  check_cors
  check_input_validation
  check_deserialization
  check_rate_limiting
fi
if [[ "$IS_CONFIG" == true ]]; then
  check_hardcoded_secrets
  check_cors
  check_docker_security
  check_insecure_crypto
fi

# =============================================================================
# Checklists for security-sensitive file types
# =============================================================================
IS_AUTH=false
IS_API=false
IS_DB=false

if [[ "$FILE_NAME_LOWER" =~ (auth|login|signin|sign-in|signup|sign-up|register|password|passwd|two-factor|2fa|mfa|totp|oauth|sso|saml|jwt|session|cookie|credential|permission|rbac|acl) ]] \
  || [[ "$FILE_PATH_LOWER" =~ /(auth|authentication|authorization|identity|security|passport|guards|policies)/ ]] \
  || [[ "$FILE_PATH_LOWER" =~ \[\.\.\.nextauth\] ]]; then
  IS_AUTH=true
  NOTES+=("Auth code checklist: validate input, hash passwords with argon2id or bcrypt, compare secrets in constant time, set Secure/HttpOnly/SameSite on cookies, rate-limit the endpoint.")
  BASE="${FILE_NAME%.*}"
  HAS_TESTS=false
  for suffix in .test .spec _test _spec; do
    for ext in ts js tsx jsx py go rb java; do
      [[ -f "$FILE_DIR/${BASE}${suffix}.${ext}" ]] && HAS_TESTS=true
    done
  done
  [[ -f "$FILE_DIR/test_${BASE}.py" ]] && HAS_TESTS=true
  if [[ -d "$FILE_DIR/__tests__" ]] && find "$FILE_DIR/__tests__" -maxdepth 1 -name "${BASE}*" -print -quit 2>/dev/null | grep -q .; then
    HAS_TESTS=true
  fi
  [[ "$HAS_TESTS" == true ]] || NOTES+=("No test file found next to this auth code. Security-critical paths deserve tests for the failure cases.")
fi

if [[ "$FILE_NAME_LOWER" =~ (model|schema|migration|query|queries|repository|dao|database|seed) ]] \
  || [[ "$FILE_PATH_LOWER" =~ /(models|schemas|migrations|database|db|repositories|queries|prisma|entities)/ ]] \
  || [[ "$FILE_EXT" =~ ^(sql|prisma)$ ]]; then
  IS_DB=true
  NOTES+=("Database code checklist: parameterized queries only, authorize before querying, return only the fields the caller needs.")
fi

if [[ "$FILE_NAME_LOWER" =~ (route|router|controller|handler|endpoint|middleware|interceptor|guard) ]] \
  || [[ "$FILE_PATH_LOWER" =~ /(routes|api|controllers|handlers|endpoints|middleware)/ ]]; then
  IS_API=true
  if [[ "$IS_AUTH" == false ]]; then
    NOTES+=("API endpoint checklist: authenticate, authorize per object, validate input, rate-limit, return safe errors.")
  fi
fi

[[ "$FILE_NAME_LOWER" =~ (cors|cross-origin) ]] && NOTES+=("CORS config: no wildcard origins in production; list allowed methods and headers explicitly.")
[[ "$FILE_NAME_LOWER" =~ (csp|security-headers|helmet|content-security) ]] && NOTES+=("Security headers: keep CSP free of unsafe-inline and unsafe-eval; check frame-ancestors and HSTS.")
[[ "$FILE_NAME_LOWER" =~ (nginx\.conf|httpd\.conf|\.htaccess) ]] && NOTES+=("Web server config: review TLS settings, security headers, proxy rules, and directory listing.")
[[ "$FILE_PATH_LOWER" =~ /(k8s|kubernetes|manifests|charts|helm)/ && "$FILE_EXT" =~ ^(yaml|yml|json)$ ]] && NOTES+=("Kubernetes manifest: check securityContext (runAsNonRoot, readOnlyRootFilesystem), resource limits, NetworkPolicies, and RBAC scope.")
[[ "$FILE_EXT" =~ ^(tf|tfvars)$ ]] && NOTES+=("Terraform: check security groups, IAM policy scope, encryption settings, and public exposure.")
if [[ "$FILE_PATH_LOWER" =~ /\.github/workflows/ || "$FILE_NAME_LOWER" =~ ^(jenkinsfile|\.gitlab-ci\.yml|\.travis\.yml|azure-pipelines\.yml|bitbucket-pipelines\.yml)$ ]]; then
  NOTES+=("CI/CD config: keep secrets out of logs, prefer OIDC over long-lived tokens, pin third-party actions by commit SHA, set least-privilege permissions.")
fi

# Nearby files worth a look, capped at three names each.
related() {
  local label="$1"; shift
  local found
  found="$(find "$@" 2>/dev/null | head -3 | while IFS= read -r x; do basename "$x"; done | paste -sd, - || true)"
  [[ -n "$found" ]] && NOTES+=("${label}: ${found//,/, }")
  return 0
}
PARENT_DIR="$(dirname "$FILE_DIR")"
if [[ "$IS_API" == true ]]; then
  for d in "$FILE_DIR/middleware" "$FILE_DIR/../middleware"; do
    [[ -d "$d" ]] && related "Middleware to review" "$d" -maxdepth 1 -type f
  done
fi
if [[ "$IS_AUTH" == true && ${#PARENT_DIR} -gt 4 ]]; then
  related "Rate limiting config to review" "$PARENT_DIR" -maxdepth 2 \( -iname '*rate*limit*' -o -iname '*throttle*' \) -not -path '*/node_modules/*'
fi
if [[ "$IS_DB" == true && ${#PARENT_DIR} -gt 4 ]]; then
  related "Validation schemas to review" "$PARENT_DIR" -maxdepth 2 \( -iname '*valid*' -o -iname '*schema*' \) -not -path '*/node_modules/*'
fi

# =============================================================================
# Output
# =============================================================================
TOTAL=$(( ${#CRITICAL[@]} + ${#HIGH[@]} + ${#MEDIUM[@]} + ${#LOW[@]} ))
(( TOTAL > 0 || ${#NOTES[@]} > 0 )) || exit 0

REPORT="LibreSecOps scan of ${REL_PATH}"
(( TOTAL > 0 )) && REPORT+=" (${TOTAL} pattern finding(s); verify each before acting)"
REPORT+=":"
for f in ${CRITICAL[@]+"${CRITICAL[@]}"}; do REPORT+=$'\n'"[CRITICAL] $f"; done
for f in ${HIGH[@]+"${HIGH[@]}"};     do REPORT+=$'\n'"[HIGH] $f"; done
for f in ${MEDIUM[@]+"${MEDIUM[@]}"};   do REPORT+=$'\n'"[MEDIUM] $f"; done
for f in ${LOW[@]+"${LOW[@]}"};      do REPORT+=$'\n'"[LOW] $f"; done
for n in ${NOTES[@]+"${NOTES[@]}"};    do REPORT+=$'\n'"- $n"; done

USER_MSG=""
if (( ${#CRITICAL[@]} > 0 )); then
  USER_MSG="LibreSecOps: ${#CRITICAL[@]} critical finding(s) in ${REL_PATH}. ${CRITICAL[0]}"
fi

jq -n --arg ctx "$REPORT" --arg msg "$USER_MSG" '
  {hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $ctx}}
  + (if $msg == "" then {} else {systemMessage: $msg} end)'
exit 0
