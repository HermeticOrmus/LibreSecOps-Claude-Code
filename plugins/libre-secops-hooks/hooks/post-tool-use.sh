#!/bin/bash
# =============================================================================
# LibreSecOps Post Tool Use Hook
# =============================================================================
# Runs AFTER Edit/Write/MultiEdit operations.
# Scans written/edited code for common security vulnerabilities using
# pattern matching. No network calls - purely local regex scanning.
#
# What this hook does:
# 1. Scans for SQL injection patterns
# 2. Detects XSS vulnerabilities (innerHTML, dangerouslySetInnerHTML)
# 3. Finds hardcoded secrets (API keys, passwords, tokens)
# 4. Identifies insecure cryptography (MD5, SHA1 for passwords)
# 5. Detects command injection risks (exec, system, eval)
# 6. Checks for path traversal patterns
# 7. Flags CORS misconfigurations
# 8. Identifies missing input validation
# 9. Detects insecure deserialization
# 10. Checks for missing rate limiting on auth endpoints
# =============================================================================

set -euo pipefail

# Read hook input from stdin (contains tool info as JSON)
HOOK_INPUT=$(cat)

# Extract tool name and file path from hook input
TOOL_NAME=$(echo "$HOOK_INPUT" | grep -oP '"tool_name"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")
FILE_PATH=$(echo "$HOOK_INPUT" | grep -oP '"file_path"\s*:\s*"\K[^"]+' 2>/dev/null || echo "")

# Alternative extraction if grep -P not available
if [ -z "$TOOL_NAME" ]; then
    TOOL_NAME=$(echo "$HOOK_INPUT" | grep -o '"tool_name":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
fi
if [ -z "$FILE_PATH" ]; then
    FILE_PATH=$(echo "$HOOK_INPUT" | grep -o '"file_path":"[^"]*"' | cut -d'"' -f4 2>/dev/null || echo "")
fi

# Exit early if not a file modification tool or no file path
if [ "$TOOL_NAME" != "Edit" ] && [ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "MultiEdit" ]; then
    exit 0
fi

if [ -z "$FILE_PATH" ] || [ ! -f "$FILE_PATH" ]; then
    exit 0
fi

# Setup logging
HOOKS_LOG_DIR="${LIBRESECOPS_HOOKS_DIR:-$(dirname "$0")}/logs"
mkdir -p "$HOOKS_LOG_DIR"

# Get file info
FILE_EXT="${FILE_PATH##*.}"
FILE_NAME=$(basename "$FILE_PATH")
FILE_NAME_LOWER=$(echo "$FILE_NAME" | tr '[:upper:]' '[:lower:]')

# Initialize findings arrays
CRITICAL=()
HIGH=()
MEDIUM=()
LOW=()
SUGGESTIONS=()

# Read file content (limit to 100KB to stay fast)
FILE_SIZE=$(stat -c%s "$FILE_PATH" 2>/dev/null || echo "0")
if [ "$FILE_SIZE" -gt 102400 ]; then
    FILE_CONTENT=$(head -c 102400 "$FILE_PATH")
else
    FILE_CONTENT=$(cat "$FILE_PATH")
fi

# Determine file type category for targeted scanning
IS_CODE=false
IS_CONFIG=false
IS_TEMPLATE=false

case "$FILE_EXT" in
    js|ts|jsx|tsx|mjs|cjs)
        IS_CODE=true
        ;;
    py)
        IS_CODE=true
        ;;
    go)
        IS_CODE=true
        ;;
    rb)
        IS_CODE=true
        ;;
    java|kt|scala)
        IS_CODE=true
        ;;
    rs)
        IS_CODE=true
        ;;
    php)
        IS_CODE=true
        ;;
    html|htm|ejs|hbs|handlebars|pug|jade|njk|jinja|j2|twig)
        IS_TEMPLATE=true
        ;;
    yaml|yml|json|toml|ini|conf|cfg)
        IS_CONFIG=true
        ;;
    env|env.*|properties)
        IS_CONFIG=true
        ;;
    sql|prisma)
        IS_CODE=true
        ;;
    tf|tfvars)
        IS_CONFIG=true
        ;;
    dockerfile|Dockerfile)
        IS_CONFIG=true
        ;;
esac

# Also check for Dockerfile by name
if echo "$FILE_NAME_LOWER" | grep -qE "^dockerfile"; then
    IS_CONFIG=true
fi

# Skip binary/image files
if echo "$FILE_EXT" | grep -qiE "^(png|jpg|jpeg|gif|svg|ico|woff|woff2|ttf|eot|mp4|mp3|pdf|zip|tar|gz)$"; then
    exit 0
fi

# =============================================================================
# SQL INJECTION DETECTION
# =============================================================================

check_sql_injection() {
    local content="$1"

    # String concatenation in SQL queries (JavaScript/TypeScript)
    if echo "$content" | grep -E "(\"|')SELECT\s.*\+|(\"|')INSERT\s.*\+|(\"|')UPDATE\s.*\+|(\"|')DELETE\s.*\+" 2>/dev/null | grep -qvE "//|/\*|\*/" 2>/dev/null; then
        HIGH+=("SQL Injection: String concatenation detected in SQL query - use parameterized queries instead")
    fi

    # Template literals with variables in SQL (JS/TS)
    if echo "$content" | grep -E '\`(SELECT|INSERT|UPDATE|DELETE)\s[^`]*\$\{' 2>/dev/null | grep -qvE "//|/\*|\*/" 2>/dev/null; then
        HIGH+=("SQL Injection: Template literal interpolation in SQL query - use parameterized queries (\$1, ?, :param)")
    fi

    # Python f-string or format in SQL
    if echo "$content" | grep -E 'f"(SELECT|INSERT|UPDATE|DELETE)\s|f'"'"'(SELECT|INSERT|UPDATE|DELETE)\s' 2>/dev/null | grep -qvE "^\s*#" 2>/dev/null; then
        HIGH+=("SQL Injection: Python f-string in SQL query - use parameterized queries with %s or :param")
    fi
    if echo "$content" | grep -E '"(SELECT|INSERT|UPDATE|DELETE)\s.*\.format\(' 2>/dev/null | grep -qvE "^\s*#" 2>/dev/null; then
        HIGH+=("SQL Injection: Python .format() in SQL query - use parameterized queries")
    fi

    # Go fmt.Sprintf in SQL
    if echo "$content" | grep -E 'fmt\.Sprintf\(\s*"(SELECT|INSERT|UPDATE|DELETE)' 2>/dev/null | grep -qvE "^\s*//" 2>/dev/null; then
        HIGH+=("SQL Injection: Go fmt.Sprintf in SQL query - use prepared statements with \$1 placeholders")
    fi

    # Raw/unsafe query methods
    if echo "$content" | grep -qE '\.(rawQuery|raw|unsafeRaw|executeRaw|query\s*\()\s*["`'"'"']?\s*(SELECT|INSERT|UPDATE|DELETE)' 2>/dev/null; then
        MEDIUM+=("SQL: Raw query detected - ensure input is properly sanitized or use parameterized queries")
    fi
    if echo "$content" | grep -qE '\$executeRaw|\$queryRaw' 2>/dev/null; then
        MEDIUM+=("SQL: Prisma raw query detected - ensure all parameters are passed via Prisma.sql template tag")
    fi
}

# =============================================================================
# XSS DETECTION
# =============================================================================

check_xss() {
    local content="$1"

    # dangerouslySetInnerHTML in React
    if echo "$content" | grep -q "dangerouslySetInnerHTML" 2>/dev/null; then
        HIGH+=("XSS: dangerouslySetInnerHTML detected - ensure content is sanitized with DOMPurify or similar before rendering")
    fi

    # innerHTML assignment
    if echo "$content" | grep -E "\.innerHTML\s*=" 2>/dev/null | grep -qvE "//|/\*|\*/" 2>/dev/null; then
        HIGH+=("XSS: Direct innerHTML assignment - use textContent for text or sanitize HTML with DOMPurify")
    fi

    # outerHTML assignment
    if echo "$content" | grep -qE "\.outerHTML\s*=" 2>/dev/null; then
        HIGH+=("XSS: Direct outerHTML assignment - sanitize content before injection")
    fi

    # document.write
    if echo "$content" | grep -q "document\.write\s*(" 2>/dev/null; then
        MEDIUM+=("XSS: document.write() detected - avoid in favor of DOM manipulation methods")
    fi

    # v-html in Vue
    if echo "$content" | grep -q "v-html" 2>/dev/null; then
        HIGH+=("XSS: Vue v-html directive detected - ensure content is sanitized before binding")
    fi

    # [innerHTML] in Angular
    if echo "$content" | grep -q '\[innerHTML\]' 2>/dev/null; then
        MEDIUM+=("XSS: Angular innerHTML binding - use DomSanitizer or Angular's built-in sanitization")
    fi

    # {@html} in Svelte
    if echo "$content" | grep -q '{@html' 2>/dev/null; then
        HIGH+=("XSS: Svelte {@html} tag detected - ensure content is sanitized")
    fi

    # Unescaped template output in EJS/Handlebars/Jinja
    if echo "$content" | grep -qE '<%[-=]\s|{{{|{{!--|{%\s*autoescape\s+false' 2>/dev/null; then
        MEDIUM+=("XSS: Unescaped template output detected - use escaped output (<%=, {{}}, etc.) for user data")
    fi

    # Jinja2 | safe filter or markupsafe
    if echo "$content" | grep -qE '\|\s*safe\b' 2>/dev/null; then
        MEDIUM+=("XSS: Template 'safe' filter detected - only use on trusted content, never on user input")
    fi
}

# =============================================================================
# HARDCODED SECRETS DETECTION
# =============================================================================

check_hardcoded_secrets() {
    local content="$1"

    # Skip if this IS an .env file (expected to have secrets)
    if echo "$FILE_NAME_LOWER" | grep -qE "^\.env"; then
        return
    fi

    # API key patterns (generic)
    if echo "$content" | grep -E "(api[_-]?key|apikey|api[_-]?secret)\s*[:=]\s*['\"][A-Za-z0-9_\-]{16,}" 2>/dev/null | grep -qvE "process\.env|os\.environ|os\.Getenv|env\(|env\[|ENV\[|example|placeholder|your[_-]|xxx|changeme|todo|REPLACE" 2>/dev/null; then
        CRITICAL+=("SECRETS: Possible hardcoded API key detected - use environment variables")
    fi

    # AWS keys
    if echo "$content" | grep -qE "(AKIA|ASIA)[A-Z0-9]{16}" 2>/dev/null; then
        CRITICAL+=("SECRETS: AWS Access Key ID detected - rotate immediately and use IAM roles or environment variables")
    fi

    # Generic secret/password assignment with literal string value
    if echo "$content" | grep -E "(password|passwd|secret|token|private[_-]?key)\s*[:=]\s*['\"][^'\"]{8,}" 2>/dev/null | grep -qvE "process\.env|os\.environ|os\.Getenv|env\(|env\[|ENV\[|example|placeholder|your[_-]|xxx|changeme|todo|REPLACE|hash|bcrypt|argon|\*\*\*|type|interface|schema|model|validation|zod|yup|joi|describe|test|spec|mock" 2>/dev/null; then
        HIGH+=("SECRETS: Possible hardcoded password/secret/token - use environment variables or a secrets manager")
    fi

    # JWT secret hardcoded
    if echo "$content" | grep -E "(jwt[_-]?secret|JWT_SECRET)\s*[:=]\s*['\"][^'\"]{4,}" 2>/dev/null | grep -qvE "process\.env|os\.environ|os\.Getenv|env\(|env\[|ENV\[|example|placeholder|changeme" 2>/dev/null; then
        CRITICAL+=("SECRETS: Hardcoded JWT secret - use environment variables (compromise = all tokens forged)")
    fi

    # Private keys in code
    if echo "$content" | grep -qE "-----BEGIN (RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----" 2>/dev/null; then
        CRITICAL+=("SECRETS: Private key embedded in source code - extract to a secure file and reference via env var")
    fi

    # Database connection strings with credentials
    if echo "$content" | grep -E "(postgres|mysql|mongodb|redis|amqp)://[^:]+:[^@]+@" 2>/dev/null | grep -qvE "process\.env|os\.environ|os\.Getenv|env\(|env\[|localhost|127\.0\.0\.1|example|placeholder|changeme" 2>/dev/null; then
        HIGH+=("SECRETS: Database connection string with credentials detected - use environment variables")
    fi

    # GitHub/GitLab tokens
    if echo "$content" | grep -qE "(ghp_[A-Za-z0-9]{36}|gho_[A-Za-z0-9]{36}|glpat-[A-Za-z0-9\-]{20})" 2>/dev/null; then
        CRITICAL+=("SECRETS: GitHub/GitLab personal access token detected - rotate immediately")
    fi

    # Slack tokens
    if echo "$content" | grep -qE "xox[baprs]-[A-Za-z0-9\-]+" 2>/dev/null; then
        CRITICAL+=("SECRETS: Slack token detected - rotate and use environment variables")
    fi

    # Stripe keys
    if echo "$content" | grep -qE "(sk_live_|rk_live_)[A-Za-z0-9]{20,}" 2>/dev/null; then
        CRITICAL+=("SECRETS: Stripe live secret key detected - rotate immediately and use environment variables")
    fi
}

# =============================================================================
# INSECURE CRYPTO DETECTION
# =============================================================================

check_insecure_crypto() {
    local content="$1"

    # MD5 for hashing (not checksums)
    if echo "$content" | grep -E "(createHash|hashlib\.md5|md5\(|MD5\.Create|Digest::MD5)" 2>/dev/null | grep -qiE "(password|passwd|secret|token|credential)" 2>/dev/null; then
        HIGH+=("CRYPTO: MD5 used for password/secret hashing - use bcrypt, scrypt, or argon2 instead")
    fi

    # SHA1 for password hashing
    if echo "$content" | grep -E "(createHash.*sha1|hashlib\.sha1|SHA1\.Create)" 2>/dev/null | grep -qiE "(password|passwd|secret|credential)" 2>/dev/null; then
        HIGH+=("CRYPTO: SHA1 used for password hashing - use bcrypt, scrypt, or argon2 instead")
    fi

    # MD5/SHA1 used at all (lower severity - might be for checksums)
    if echo "$content" | grep -E "createHash\(['\"]md5['\"]|hashlib\.md5|\.update.*\.digest\(\)" 2>/dev/null | grep -qvE "checksum|integrity|fingerprint|etag|cache" 2>/dev/null; then
        LOW+=("CRYPTO: MD5 usage detected - if used for security purposes, upgrade to SHA-256 or better")
    fi

    # Math.random for security purposes
    if echo "$content" | grep -E "Math\.random\(\)" 2>/dev/null | grep -qiE "(token|secret|key|password|nonce|salt|random|id|uuid|session)" 2>/dev/null; then
        HIGH+=("CRYPTO: Math.random() used for security-sensitive value - use crypto.randomBytes() or crypto.getRandomValues()")
    fi

    # Python random (not secrets) for security
    if echo "$content" | grep -qE "import random|from random import" 2>/dev/null; then
        if echo "$content" | grep -qiE "(token|secret|key|password|nonce|salt|otp|code)" 2>/dev/null; then
            MEDIUM+=("CRYPTO: Python 'random' module may be used for security values - use 'secrets' module instead")
        fi
    fi

    # Weak TLS versions
    if echo "$content" | grep -qE "TLSv1[^.]|SSLv3|TLS_1_0|TLS_1_1|ssl\.PROTOCOL_TLSv1\b" 2>/dev/null; then
        HIGH+=("CRYPTO: Weak TLS/SSL version detected - use TLS 1.2 or 1.3 minimum")
    fi

    # ECB mode
    if echo "$content" | grep -qE "ECB|MODE_ECB|AES-128-ECB|AES-256-ECB" 2>/dev/null; then
        HIGH+=("CRYPTO: ECB block cipher mode detected - use GCM, CBC with HMAC, or another authenticated mode")
    fi
}

# =============================================================================
# COMMAND INJECTION DETECTION
# =============================================================================

check_command_injection() {
    local content="$1"

    # eval() with variable input
    if echo "$content" | grep -E "\beval\s*\(" 2>/dev/null | grep -qvE "//|#|/\*|\*/|eslint|webpack|babel|jest" 2>/dev/null; then
        HIGH+=("INJECTION: eval() detected - avoid eval entirely; use JSON.parse, Function constructor, or specific parsers")
    fi

    # new Function() with external input
    if echo "$content" | grep -E "new\s+Function\s*\(" 2>/dev/null | grep -qvE "//|/\*|\*/" 2>/dev/null; then
        MEDIUM+=("INJECTION: new Function() detected - similar to eval, avoid with user-controlled input")
    fi

    # Node.js child_process exec/execSync with string
    if echo "$content" | grep -E "(child_process|exec|execSync|spawn|spawnSync|execFile)\s*\(" 2>/dev/null | grep -qvE "//|/\*|\*/" 2>/dev/null; then
        if echo "$content" | grep -qE "(exec|execSync)\s*\(\s*(\`|\"|\')[^)]*\$\{" 2>/dev/null; then
            HIGH+=("INJECTION: Command execution with interpolated string - use execFile with argument array instead")
        else
            MEDIUM+=("INJECTION: Shell command execution detected - ensure input is not user-controlled; prefer execFile with args array")
        fi
    fi

    # Python os.system / subprocess.call with shell=True
    if echo "$content" | grep -E "os\.system\(|os\.popen\(" 2>/dev/null | grep -qvE "^\s*#" 2>/dev/null; then
        HIGH+=("INJECTION: Python os.system/os.popen - use subprocess.run with shell=False and list arguments")
    fi
    if echo "$content" | grep -qE "subprocess\.(call|run|Popen).*shell\s*=\s*True" 2>/dev/null; then
        HIGH+=("INJECTION: Python subprocess with shell=True - use shell=False with argument list")
    fi

    # Go os/exec with user input
    if echo "$content" | grep -qE 'exec\.Command\(\s*"(sh|bash|cmd)"' 2>/dev/null; then
        MEDIUM+=("INJECTION: Go shell invocation via exec.Command - pass commands directly without shell wrapper")
    fi

    # PHP dangerous functions (only check in PHP files)
    if [ "$FILE_EXT" = "php" ]; then
        if echo "$content" | grep -E "\b(system|exec|passthru|shell_exec|popen|proc_open)\s*\(" 2>/dev/null | grep -qvE "^\s*//" 2>/dev/null; then
            HIGH+=("INJECTION: PHP shell execution function - ensure input is escaped with escapeshellarg/escapeshellcmd")
        fi
    fi

    # Ruby system/exec/backtick (only check in Ruby files)
    if [ "$FILE_EXT" = "rb" ]; then
        if echo "$content" | grep -qE "\b(system|exec|\`)\s*[\"'].*#\{" 2>/dev/null; then
            HIGH+=("INJECTION: Ruby command with string interpolation - use array form of system()")
        fi
    fi
}

# =============================================================================
# PATH TRAVERSAL DETECTION
# =============================================================================

check_path_traversal() {
    local content="$1"

    # File operations with user input indicators
    if echo "$content" | grep -E "(readFile|readFileSync|writeFile|createReadStream|createWriteStream|open\(|fopen)" 2>/dev/null | grep -qE "(req\.|request\.|params\.|query\.|body\.|args\[|argv)" 2>/dev/null; then
        MEDIUM+=("PATH TRAVERSAL: File operation with possible user input - validate and sanitize file paths, use path.resolve and check against base directory")
    fi

    # Direct path construction from user input
    if echo "$content" | grep -qE "(path\.join|path\.resolve|os\.path\.join)\s*\(.*\b(req\.|request\.|params|query|body|user_input|args)" 2>/dev/null; then
        MEDIUM+=("PATH TRAVERSAL: Path constructed from user input - validate the resolved path is within the expected directory")
    fi

    # Express static file serving with user input
    if echo "$content" | grep -qE "res\.(sendFile|download)\s*\(.*req\." 2>/dev/null; then
        HIGH+=("PATH TRAVERSAL: Serving files based on user input - validate path is within allowed directory")
    fi

    # Go filepath from user input
    if echo "$content" | grep -qE "filepath\.Join.*r\.URL|filepath\.Join.*r\.Form|os\.Open.*r\.(URL|Form)" 2>/dev/null; then
        MEDIUM+=("PATH TRAVERSAL: Go file operation with request input - use filepath.Clean and validate against base path")
    fi
}

# =============================================================================
# CORS MISCONFIGURATION DETECTION
# =============================================================================

check_cors() {
    local content="$1"

    # Wildcard CORS origin
    if echo "$content" | grep -E "Access-Control-Allow-Origin.*\*|origin:\s*['\"]?\*['\"]?|cors\(\s*\)|allowAllOrigins|AllowAllOrigins" 2>/dev/null | grep -qvE "//|#|/\*|\*/" 2>/dev/null; then
        HIGH+=("CORS: Wildcard origin (*) detected - restrict to specific allowed origins in production")
    fi

    # Reflecting Origin header without validation
    if echo "$content" | grep -E "req\.headers?\.origin|request\.headers?\[.origin.\]" 2>/dev/null | grep -qE "Access-Control-Allow-Origin|setHeader|header\(" 2>/dev/null; then
        MEDIUM+=("CORS: Origin reflection detected - validate origin against allowlist before reflecting")
    fi

    # Credentials with wildcard origin
    if echo "$content" | grep -qE "Access-Control-Allow-Credentials.*true|credentials:\s*true|allowCredentials.*true" 2>/dev/null; then
        if echo "$content" | grep -qE "origin.*\*|Allow-Origin.*\*" 2>/dev/null; then
            CRITICAL+=("CORS: Credentials enabled with wildcard origin - this is a serious security vulnerability")
        fi
    fi
}

# =============================================================================
# INPUT VALIDATION DETECTION
# =============================================================================

check_input_validation() {
    local content="$1"

    # API route handlers without visible validation
    if echo "$content" | grep -qE "(req\.body|req\.params|req\.query|request\.json|request\.form|request\.args)" 2>/dev/null; then
        # Check if any validation library is used in this file
        if ! echo "$content" | grep -qiE "(zod|yup|joi|celebrate|class-validator|express-validator|pydantic|marshmallow|validate|sanitize|Validator|@IsString|@IsEmail|@IsInt)" 2>/dev/null; then
            LOW+=("VALIDATION: Request input used without visible validation library - consider using zod, joi, or similar for input validation")
        fi
    fi

    # JSON.parse without try/catch
    if echo "$content" | grep -qE "JSON\.parse\s*\(" 2>/dev/null; then
        if ! echo "$content" | grep -qE "try\s*\{" 2>/dev/null; then
            LOW+=("VALIDATION: JSON.parse without error handling - wrap in try/catch to handle malformed input")
        fi
    fi

    # parseInt without radix or validation
    if echo "$content" | grep -qE "parseInt\s*\(\s*(req\.|request\.|params|query)" 2>/dev/null; then
        LOW+=("VALIDATION: parseInt on user input - validate input is numeric first and specify radix (10)")
    fi
}

# =============================================================================
# INSECURE DESERIALIZATION DETECTION
# =============================================================================

check_deserialization() {
    local content="$1"

    # Python pickle with untrusted data
    if echo "$content" | grep -qE "pickle\.(load|loads)\s*\(" 2>/dev/null; then
        HIGH+=("DESERIALIZATION: Python pickle detected - pickle can execute arbitrary code; use JSON for untrusted data")
    fi

    # Python yaml.load (unsafe by default)
    if echo "$content" | grep -E "yaml\.load\s*\(" 2>/dev/null | grep -qvE "Loader\s*=\s*yaml\.SafeLoader|safe_load" 2>/dev/null; then
        HIGH+=("DESERIALIZATION: yaml.load without SafeLoader - use yaml.safe_load() to prevent code execution")
    fi

    # Java deserialization
    if echo "$content" | grep -qE "ObjectInputStream|readObject\s*\(|XMLDecoder" 2>/dev/null; then
        MEDIUM+=("DESERIALIZATION: Java object deserialization - validate object types and use allowlists")
    fi

    # PHP unserialize
    if echo "$content" | grep -qE "\bunserialize\s*\(" 2>/dev/null; then
        HIGH+=("DESERIALIZATION: PHP unserialize detected - use JSON decode for untrusted data; if required, use allowed_classes option")
    fi

    # Ruby Marshal.load
    if echo "$content" | grep -qE "Marshal\.load\s*\(" 2>/dev/null; then
        HIGH+=("DESERIALIZATION: Ruby Marshal.load - can execute arbitrary code; use JSON for untrusted data")
    fi
}

# =============================================================================
# AUTH ENDPOINT RATE LIMITING CHECK
# =============================================================================

check_rate_limiting() {
    local content="$1"
    local file_lower
    file_lower=$(echo "$FILE_NAME_LOWER" | tr '[:upper:]' '[:lower:]')

    # Only check auth-related files
    if echo "$file_lower" | grep -qE "(auth|login|signin|register|signup|password|reset|forgot|verify|otp|2fa|mfa)"; then
        if ! echo "$content" | grep -qiE "(rateLimit|rate[_-]?limit|throttle|slowDown|RateLimiter|Throttler|limiter|RateLimit)" 2>/dev/null; then
            MEDIUM+=("RATE LIMIT: Auth endpoint without visible rate limiting - protect against brute force with rate limiting middleware")
        fi
    fi
}

# =============================================================================
# DOCKER SECURITY CHECKS
# =============================================================================

check_docker_security() {
    local content="$1"

    # Running as root
    if echo "$content" | grep -qE "^USER root$" 2>/dev/null; then
        MEDIUM+=("DOCKER: Container configured to run as root - add a non-root USER instruction")
    fi

    # No USER instruction at all (defaults to root)
    if echo "$FILE_NAME_LOWER" | grep -qE "^dockerfile"; then
        if ! echo "$content" | grep -qE "^USER " 2>/dev/null; then
            MEDIUM+=("DOCKER: No USER instruction - container will run as root; add USER to run as non-root")
        fi
    fi

    # Using :latest tag
    if echo "$content" | grep -qE "^FROM\s+\S+:latest\b|^FROM\s+\S+\s*$" 2>/dev/null; then
        LOW+=("DOCKER: Using :latest or unpinned image tag - pin specific versions for reproducibility and security")
    fi

    # COPY secrets or env files
    if echo "$content" | grep -qE "^(COPY|ADD)\s+.*\.(env|pem|key|cert|p12|pfx)" 2>/dev/null; then
        HIGH+=("DOCKER: Copying secret/key files into image - use Docker secrets, mount volumes, or multi-stage builds instead")
    fi

    # ADD with URL (potential supply chain risk)
    if echo "$content" | grep -qE "^ADD\s+https?://" 2>/dev/null; then
        MEDIUM+=("DOCKER: ADD with URL - use COPY + RUN curl/wget to validate downloads; ADD does not verify checksums")
    fi

    # Exposing sensitive ports
    if echo "$content" | grep -qE "^EXPOSE\s+(22|3306|5432|6379|27017)\b" 2>/dev/null; then
        LOW+=("DOCKER: Exposing database/SSH port directly - use Docker networks for internal communication")
    fi
}

# =============================================================================
# RUN ALL CHECKS
# =============================================================================

if [ "$IS_CODE" = true ] || [ "$IS_TEMPLATE" = true ]; then
    check_sql_injection "$FILE_CONTENT"
    check_xss "$FILE_CONTENT"
    check_hardcoded_secrets "$FILE_CONTENT"
    check_insecure_crypto "$FILE_CONTENT"
    check_command_injection "$FILE_CONTENT"
    check_path_traversal "$FILE_CONTENT"
    check_cors "$FILE_CONTENT"
    check_input_validation "$FILE_CONTENT"
    check_deserialization "$FILE_CONTENT"
    check_rate_limiting "$FILE_CONTENT"
fi

if [ "$IS_CONFIG" = true ]; then
    check_hardcoded_secrets "$FILE_CONTENT"
    check_cors "$FILE_CONTENT"
    check_docker_security "$FILE_CONTENT"

    # Also check for insecure crypto in config
    check_insecure_crypto "$FILE_CONTENT"
fi

# =============================================================================
# LOG FINDINGS
# =============================================================================

TOTAL_FINDINGS=$(( ${#CRITICAL[@]} + ${#HIGH[@]} + ${#MEDIUM[@]} + ${#LOW[@]} ))

if [ "$TOTAL_FINDINGS" -gt 0 ]; then
    {
        echo "$(date '+%Y-%m-%d %H:%M:%S') - Security scan of $FILE_PATH"
        echo "  Total findings: $TOTAL_FINDINGS (Critical: ${#CRITICAL[@]}, High: ${#HIGH[@]}, Medium: ${#MEDIUM[@]}, Low: ${#LOW[@]})"
        for finding in "${CRITICAL[@]}"; do
            echo "  [CRITICAL] $finding"
        done
        for finding in "${HIGH[@]}"; do
            echo "  [HIGH] $finding"
        done
        for finding in "${MEDIUM[@]}"; do
            echo "  [MEDIUM] $finding"
        done
        for finding in "${LOW[@]}"; do
            echo "  [LOW] $finding"
        done
        echo "---"
    } >> "$HOOKS_LOG_DIR/security-issues.log"
fi

# Log all scanned files for audit trail
echo "$(date '+%Y-%m-%d %H:%M:%S') - Scanned: $FILE_PATH (findings: $TOTAL_FINDINGS)" >> "$HOOKS_LOG_DIR/scan-activity.log"

# =============================================================================
# OUTPUT STRUCTURED RESPONSE
# =============================================================================

# Only output if we have findings or suggestions
if [ "$TOTAL_FINDINGS" -gt 0 ] || [ ${#SUGGESTIONS[@]} -gt 0 ]; then
    OUTPUT="{"

    # Build system message from findings (CRITICAL and HIGH get top billing)
    if [ ${#CRITICAL[@]} -gt 0 ] || [ ${#HIGH[@]} -gt 0 ] || [ ${#MEDIUM[@]} -gt 0 ]; then
        OUTPUT="$OUTPUT\"systemMessage\":\"LibreSecOps Security Scan ($TOTAL_FINDINGS findings):\\n"

        if [ ${#CRITICAL[@]} -gt 0 ]; then
            OUTPUT="$OUTPUT\\n[CRITICAL]\\n"
            for finding in "${CRITICAL[@]}"; do
                ESCAPED=$(echo "$finding" | sed 's/"/\\"/g')
                OUTPUT="$OUTPUT- $ESCAPED\\n"
            done
        fi

        if [ ${#HIGH[@]} -gt 0 ]; then
            OUTPUT="$OUTPUT\\n[HIGH]\\n"
            for finding in "${HIGH[@]}"; do
                ESCAPED=$(echo "$finding" | sed 's/"/\\"/g')
                OUTPUT="$OUTPUT- $ESCAPED\\n"
            done
        fi

        if [ ${#MEDIUM[@]} -gt 0 ]; then
            OUTPUT="$OUTPUT\\n[MEDIUM]\\n"
            for finding in "${MEDIUM[@]}"; do
                ESCAPED=$(echo "$finding" | sed 's/"/\\"/g')
                OUTPUT="$OUTPUT- $ESCAPED\\n"
            done
        fi

        OUTPUT="$OUTPUT\""
    fi

    # Add LOW findings and suggestions as additional context (less prominent)
    if [ ${#LOW[@]} -gt 0 ] || [ ${#SUGGESTIONS[@]} -gt 0 ]; then
        if [ ${#CRITICAL[@]} -gt 0 ] || [ ${#HIGH[@]} -gt 0 ] || [ ${#MEDIUM[@]} -gt 0 ]; then
            OUTPUT="$OUTPUT,"
        fi
        OUTPUT="$OUTPUT\"additionalContext\":["
        FIRST=true

        for finding in "${LOW[@]}"; do
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                OUTPUT="$OUTPUT,"
            fi
            ESCAPED=$(echo "$finding" | sed 's/"/\\"/g')
            OUTPUT="$OUTPUT{\"type\":\"text\",\"text\":\"[LOW] $ESCAPED\"}"
        done

        for suggestion in "${SUGGESTIONS[@]}"; do
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                OUTPUT="$OUTPUT,"
            fi
            ESCAPED=$(echo "$suggestion" | sed 's/"/\\"/g')
            OUTPUT="$OUTPUT{\"type\":\"text\",\"text\":\"Suggestion: $ESCAPED\"}"
        done

        OUTPUT="$OUTPUT]"
    fi

    OUTPUT="$OUTPUT}"
    echo "$OUTPUT"
fi

exit 0
