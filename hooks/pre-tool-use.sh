#!/bin/bash
# =============================================================================
# LibreSecOps Pre Tool Use Hook
# =============================================================================
# Runs BEFORE Edit/Write/MultiEdit operations on security-sensitive files.
# Detects what kind of file is being modified and provides security guidance.
#
# What this hook does:
# 1. Detects if the file is security-sensitive (auth, db, API, config, secrets)
# 2. Warns about security implications of the change
# 3. Suggests related files that need security review
# 4. Flags if modifying security-critical code without tests
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

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# Initialize context and warnings
CONTEXT_MESSAGES=()
WARNINGS=()

# Get file info
FILE_NAME=$(basename "$FILE_PATH")
FILE_DIR=$(dirname "$FILE_PATH")
FILE_EXT="${FILE_PATH##*.}"
FILE_NAME_LOWER=$(echo "$FILE_NAME" | tr '[:upper:]' '[:lower:]')
FILE_PATH_LOWER=$(echo "$FILE_PATH" | tr '[:upper:]' '[:lower:]')

# =============================================================================
# AUTHENTICATION FILE DETECTION
# =============================================================================

IS_AUTH_FILE=false

# Filename patterns for auth files
if echo "$FILE_NAME_LOWER" | grep -qE "(auth|login|signin|sign-in|signup|sign-up|register|password|passwd|reset-password|forgot-password|verify-email|two-factor|2fa|mfa|totp|oauth|sso|saml|jwt|token|session|cookie|credential|permission|role|rbac|acl)"; then
    IS_AUTH_FILE=true
fi

# Directory patterns for auth files
if echo "$FILE_PATH_LOWER" | grep -qE "/(auth|authentication|authorization|identity|security|passport|middleware/auth|guards|policies)/"; then
    IS_AUTH_FILE=true
fi

# NextAuth / Auth.js specific files
if echo "$FILE_PATH_LOWER" | grep -qE "\[\.\.\.nextauth\]|auth\.config|auth\.ts$|auth\.js$"; then
    IS_AUTH_FILE=true
fi

if [ "$IS_AUTH_FILE" = true ]; then
    WARNINGS+=("SECURITY-CRITICAL: Modifying authentication/authorization code")
    CONTEXT_MESSAGES+=("Auth file checklist: validate input, hash passwords (bcrypt/argon2), use constant-time comparison, set secure cookie flags, implement rate limiting")

    # Check for related test files
    BASE_NAME="${FILE_NAME%.*}"
    HAS_TESTS=false
    for pattern in ".test" ".spec" "_test" "_spec"; do
        for ext in "ts" "js" "tsx" "jsx" "py" "go"; do
            if [ -f "$FILE_DIR/${BASE_NAME}${pattern}.${ext}" ]; then
                HAS_TESTS=true
                break 2
            fi
        done
    done
    # Also check __tests__ directory
    if [ -d "$FILE_DIR/__tests__" ]; then
        if find "$FILE_DIR/__tests__" -name "${BASE_NAME}*" -print -quit 2>/dev/null | grep -q .; then
            HAS_TESTS=true
        fi
    fi
    if [ "$HAS_TESTS" = false ]; then
        WARNINGS+=("No test file found for auth code - security-critical code should have comprehensive tests")
    fi
fi

# =============================================================================
# DATABASE / QUERY FILE DETECTION
# =============================================================================

IS_DB_FILE=false

# Filename patterns for database files
if echo "$FILE_NAME_LOWER" | grep -qE "(model|schema|migration|query|queries|repository|repo|dao|database|db\.|seed|fixture|prisma\.schema|sequelize|knex)"; then
    IS_DB_FILE=true
fi

# Directory patterns
if echo "$FILE_PATH_LOWER" | grep -qE "/(models|schemas|migrations|database|db|repositories|queries|seeds|fixtures|prisma|entities)/"; then
    IS_DB_FILE=true
fi

# SQL files
if echo "$FILE_EXT" | grep -qiE "^(sql|prisma)$"; then
    IS_DB_FILE=true
fi

if [ "$IS_DB_FILE" = true ]; then
    WARNINGS+=("DATABASE: Modifying database-related code - review for SQL injection and data exposure risks")
    CONTEXT_MESSAGES+=("DB security checklist: use parameterized queries, validate/sanitize input, limit returned fields, check authorization before queries, avoid raw SQL with user input")

    # Suggest reviewing related middleware for auth checks
    if echo "$FILE_PATH_LOWER" | grep -qE "/(api|routes|controllers)/"; then
        CONTEXT_MESSAGES+=("Verify that this endpoint has proper authentication and authorization middleware")
    fi
fi

# =============================================================================
# API ROUTE / MIDDLEWARE DETECTION
# =============================================================================

IS_API_FILE=false

# Filename patterns
if echo "$FILE_NAME_LOWER" | grep -qE "(route|router|controller|handler|endpoint|middleware|interceptor|guard|api\.)"; then
    IS_API_FILE=true
fi

# Directory patterns
if echo "$FILE_PATH_LOWER" | grep -qE "/(routes|api|controllers|handlers|endpoints|middleware|interceptors|guards)/"; then
    IS_API_FILE=true
fi

# Next.js API routes
if echo "$FILE_PATH_LOWER" | grep -qE "/app/api/|/pages/api/"; then
    IS_API_FILE=true
fi

if [ "$IS_API_FILE" = true ] && [ "$IS_AUTH_FILE" = false ]; then
    CONTEXT_MESSAGES+=("API endpoint security checklist: validate all input, check authentication, verify authorization, implement rate limiting, sanitize output, set proper status codes")

    # Check if this route handles sensitive data
    if echo "$FILE_NAME_LOWER" | grep -qE "(user|account|profile|payment|billing|order|admin|setting|config)"; then
        WARNINGS+=("API: Modifying route that handles sensitive data - ensure proper auth guards and input validation")
    fi
fi

# =============================================================================
# CONFIGURATION FILE DETECTION
# =============================================================================

IS_CONFIG_FILE=false
CONFIG_TYPE=""

# CORS configuration
if echo "$FILE_NAME_LOWER" | grep -qE "(cors|cross-origin)"; then
    IS_CONFIG_FILE=true
    CONFIG_TYPE="CORS"
    WARNINGS+=("CORS: Modifying cross-origin configuration - avoid wildcard (*) origins in production, validate allowed methods and headers")
fi

# CSP / Security headers
if echo "$FILE_NAME_LOWER" | grep -qE "(csp|security-headers|helmet|content-security)"; then
    IS_CONFIG_FILE=true
    CONFIG_TYPE="Security Headers"
    WARNINGS+=("SECURITY HEADERS: Ensure CSP is not weakened (avoid unsafe-inline, unsafe-eval), verify X-Frame-Options, HSTS settings")
fi

# Rate limiting
if echo "$FILE_NAME_LOWER" | grep -qE "(rate-limit|ratelimit|throttle|limiter)"; then
    IS_CONFIG_FILE=true
    CONFIG_TYPE="Rate Limiting"
    CONTEXT_MESSAGES+=("Rate limiting: verify limits are appropriate per endpoint, stricter for auth/login endpoints")
fi

# Framework config files
if echo "$FILE_NAME_LOWER" | grep -qE "^(next\.config|nuxt\.config|vite\.config|webpack\.config|nest-cli|angular\.json|app\.config)"; then
    IS_CONFIG_FILE=true
    CONFIG_TYPE="Framework"
    CONTEXT_MESSAGES+=("Framework config: check for security-relevant settings (headers, proxy, env exposure)")
fi

# Nginx / Apache config
if echo "$FILE_NAME_LOWER" | grep -qE "(nginx\.conf|apache|httpd\.conf|\.htaccess)"; then
    IS_CONFIG_FILE=true
    CONFIG_TYPE="Web Server"
    WARNINGS+=("WEB SERVER CONFIG: Review TLS settings, header configuration, proxy rules, and directory listing settings")
fi

# =============================================================================
# SECRETS / CREDENTIALS FILE DETECTION
# =============================================================================

IS_SECRETS_FILE=false

# Environment files
if echo "$FILE_NAME_LOWER" | grep -qE "^\.env|\.env\.|env\.local|env\.development|env\.production|env\.staging"; then
    IS_SECRETS_FILE=true
    WARNINGS+=("SECRETS: Modifying environment/secrets file - never commit secrets to git, use a secrets manager for production")
fi

# Known credential files
if echo "$FILE_NAME_LOWER" | grep -qE "(credentials|secrets|private[_-]?key|service[_-]?account|\.pem$|\.key$|\.p12$|\.pfx$|keystore|truststore)"; then
    IS_SECRETS_FILE=true
    WARNINGS+=("SECRETS: Modifying credentials/key file - ensure this file is in .gitignore and not committed")
fi

# Config files that commonly contain secrets
if echo "$FILE_NAME_LOWER" | grep -qE "(config\.yaml|config\.yml|config\.json|settings\.json|appsettings\.json|application\.properties|application\.yml)"; then
    CONTEXT_MESSAGES+=("Configuration file may contain secrets - use environment variables or a secrets manager instead of hardcoded values")
fi

# =============================================================================
# DEPLOYMENT / INFRASTRUCTURE FILE DETECTION
# =============================================================================

IS_DEPLOY_FILE=false

# Docker files
if echo "$FILE_NAME_LOWER" | grep -qE "^(dockerfile|docker-compose|compose)\b"; then
    IS_DEPLOY_FILE=true
    WARNINGS+=("CONTAINER: Modifying Docker configuration - avoid running as root, use specific image tags (not :latest), don't copy secrets into images, use multi-stage builds")
fi

# Kubernetes manifests
if echo "$FILE_PATH_LOWER" | grep -qE "/(k8s|kubernetes|manifests|charts|helm)/" && echo "$FILE_EXT" | grep -qiE "^(yaml|yml|json)$"; then
    IS_DEPLOY_FILE=true
    WARNINGS+=("K8S: Modifying Kubernetes manifest - review security context, resource limits, network policies, and RBAC settings")
fi

# Terraform / IaC
if echo "$FILE_EXT" | grep -qiE "^(tf|tfvars)$"; then
    IS_DEPLOY_FILE=true
    WARNINGS+=("INFRASTRUCTURE: Modifying Terraform config - review security groups, IAM policies, encryption settings, and public exposure")
fi

# CI/CD pipeline files
if echo "$FILE_PATH_LOWER" | grep -qE "/(\.github/workflows|\.gitlab-ci|\.circleci|\.buildkite)/"; then
    IS_DEPLOY_FILE=true
    WARNINGS+=("CI/CD: Modifying pipeline config - ensure secrets are not logged, use OIDC over long-lived tokens, pin action versions by SHA")
fi
if echo "$FILE_NAME_LOWER" | grep -qE "^(jenkinsfile|\.gitlab-ci\.yml|\.travis\.yml|azure-pipelines\.yml|bitbucket-pipelines\.yml)$"; then
    IS_DEPLOY_FILE=true
    WARNINGS+=("CI/CD: Modifying pipeline config - review secret handling and access permissions")
fi

# =============================================================================
# SUGGEST RELATED FILES FOR REVIEW
# =============================================================================

RELATED_FILES=()

# For API routes, suggest checking middleware chain
if [ "$IS_API_FILE" = true ]; then
    # Look for middleware files nearby
    if [ -d "$FILE_DIR/../middleware" ]; then
        MW_FILES=$(find "$FILE_DIR/../middleware" -maxdepth 1 -type f 2>/dev/null | head -3 || true)
        if [ -n "$MW_FILES" ]; then
            RELATED_FILES+=("Review middleware chain:")
            for mw in $MW_FILES; do
                RELATED_FILES+=("  - $(basename "$mw")")
            done
        fi
    fi
    if [ -d "$FILE_DIR/middleware" ]; then
        MW_FILES=$(find "$FILE_DIR/middleware" -maxdepth 1 -type f 2>/dev/null | head -3 || true)
        if [ -n "$MW_FILES" ]; then
            RELATED_FILES+=("Review middleware chain:")
            for mw in $MW_FILES; do
                RELATED_FILES+=("  - $(basename "$mw")")
            done
        fi
    fi
fi

# For auth files, suggest checking related security config
if [ "$IS_AUTH_FILE" = true ]; then
    PARENT_DIR=$(dirname "$FILE_DIR")
    # Only search if parent is a real project directory (not / or /tmp)
    if [ -n "$PARENT_DIR" ] && [ "$PARENT_DIR" != "/" ] && [ ${#PARENT_DIR} -gt 4 ]; then
        RATE_LIMIT=$(find "$PARENT_DIR" -maxdepth 2 -iname "*rate*limit*" -o -iname "*throttle*" 2>/dev/null | head -2 || true)
        if [ -n "$RATE_LIMIT" ]; then
            RELATED_FILES+=("Rate limiting config to review:")
            for rl in $RATE_LIMIT; do
                RELATED_FILES+=("  - $(basename "$rl")")
            done
        fi
    fi
fi

# For DB files, suggest checking validation/schema files
if [ "$IS_DB_FILE" = true ]; then
    PARENT_DIR=$(dirname "$FILE_DIR")
    if [ -n "$PARENT_DIR" ] && [ "$PARENT_DIR" != "/" ] && [ ${#PARENT_DIR} -gt 4 ]; then
        VALIDATION=$(find "$PARENT_DIR" -maxdepth 2 -iname "*valid*" -o -iname "*schema*" 2>/dev/null | head -3 || true)
        if [ -n "$VALIDATION" ]; then
            RELATED_FILES+=("Input validation schemas to review:")
            for vf in $VALIDATION; do
                RELATED_FILES+=("  - $(basename "$vf")")
            done
        fi
    fi
fi

if [ ${#RELATED_FILES[@]} -gt 0 ]; then
    for rf in "${RELATED_FILES[@]}"; do
        CONTEXT_MESSAGES+=("$rf")
    done
fi

# =============================================================================
# OUTPUT STRUCTURED RESPONSE
# =============================================================================

# Only output if we have context or warnings
if [ ${#CONTEXT_MESSAGES[@]} -gt 0 ] || [ ${#WARNINGS[@]} -gt 0 ]; then
    OUTPUT="{"
    FIRST_SECTION=true

    # Add context messages
    if [ ${#CONTEXT_MESSAGES[@]} -gt 0 ]; then
        OUTPUT="$OUTPUT\"additionalContext\":["
        FIRST=true
        for msg in "${CONTEXT_MESSAGES[@]}"; do
            if [ "$FIRST" = true ]; then
                FIRST=false
            else
                OUTPUT="$OUTPUT,"
            fi
            ESCAPED_MSG=$(echo "$msg" | sed 's/"/\\"/g')
            OUTPUT="$OUTPUT{\"type\":\"text\",\"text\":\"$ESCAPED_MSG\"}"
        done
        OUTPUT="$OUTPUT]"
        FIRST_SECTION=false
    fi

    # Add warnings as system message
    if [ ${#WARNINGS[@]} -gt 0 ]; then
        if [ "$FIRST_SECTION" = false ]; then
            OUTPUT="$OUTPUT,"
        fi
        OUTPUT="$OUTPUT\"systemMessage\":\"LibreSecOps Pre-Edit Security Check:\\n"
        for warn in "${WARNINGS[@]}"; do
            ESCAPED_WARN=$(echo "$warn" | sed 's/"/\\"/g')
            OUTPUT="$OUTPUT- $ESCAPED_WARN\\n"
        done
        OUTPUT="$OUTPUT\""
    fi

    OUTPUT="$OUTPUT}"
    echo "$OUTPUT"
fi

exit 0
