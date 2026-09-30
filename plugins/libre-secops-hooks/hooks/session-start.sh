#!/bin/bash
# =============================================================================
# LibreSecOps Session Start Hook
# =============================================================================
# Runs when a Claude Code session starts in a project.
# Detects security-relevant project characteristics, recommends plugins,
# and warns about missing security basics.
#
# What this hook does:
# 1. Detects language, framework, package manager, lockfiles
# 2. Identifies auth libraries, ORMs, API frameworks
# 3. Finds env files, Docker setup, CI/CD configs
# 4. Checks for security tooling (Snyk, Trivy, Semgrep, gitleaks, etc.)
# 5. Recommends relevant LibreSecOps plugins based on detected stack
# 6. Warns about missing security basics (.gitignore, lockfiles, .env in git)
# =============================================================================

set -euo pipefail

# Read hook input from stdin (contains session info as JSON)
HOOK_INPUT=$(cat)

# Get current working directory
CURRENT_DIR=$(pwd)
PROJECT_NAME=$(basename "$CURRENT_DIR")

# Ensure log directory exists
HOOKS_LOG_DIR="${LIBRESECOPS_HOOKS_DIR:-$(dirname "$0")}/logs"
mkdir -p "$HOOKS_LOG_DIR"

# Log session start
echo "$(date '+%Y-%m-%d %H:%M:%S') - LibreSecOps Session started in $CURRENT_DIR" >> "$HOOKS_LOG_DIR/sessions.log"

# Initialize output arrays
CONTEXT_MESSAGES=()
SECURITY_CONTEXT=()
WARNINGS=()

# =============================================================================
# LANGUAGE AND FRAMEWORK DETECTION
# =============================================================================

LANGUAGES=()
FRAMEWORKS=()
PACKAGE_MANAGER=""
HAS_LOCKFILE=false

# -----------------------------------------------------------------------------
# Node.js / JavaScript / TypeScript
# -----------------------------------------------------------------------------
if [ -f "$CURRENT_DIR/package.json" ]; then
    LANGUAGES+=("JavaScript/TypeScript")
    PACKAGE_JSON=$(cat "$CURRENT_DIR/package.json" 2>/dev/null || echo "{}")

    # Package manager detection
    if [ -f "$CURRENT_DIR/pnpm-lock.yaml" ]; then
        PACKAGE_MANAGER="pnpm"
        HAS_LOCKFILE=true
    elif [ -f "$CURRENT_DIR/yarn.lock" ]; then
        PACKAGE_MANAGER="yarn"
        HAS_LOCKFILE=true
    elif [ -f "$CURRENT_DIR/bun.lockb" ] || [ -f "$CURRENT_DIR/bun.lock" ]; then
        PACKAGE_MANAGER="bun"
        HAS_LOCKFILE=true
    elif [ -f "$CURRENT_DIR/package-lock.json" ]; then
        PACKAGE_MANAGER="npm"
        HAS_LOCKFILE=true
    else
        PACKAGE_MANAGER="npm (no lockfile)"
    fi

    # Framework detection
    if echo "$PACKAGE_JSON" | grep -q '"next"'; then
        FRAMEWORKS+=("Next.js")
    elif echo "$PACKAGE_JSON" | grep -q '"express"'; then
        FRAMEWORKS+=("Express")
    elif echo "$PACKAGE_JSON" | grep -q '"fastify"'; then
        FRAMEWORKS+=("Fastify")
    elif echo "$PACKAGE_JSON" | grep -q '"hono"'; then
        FRAMEWORKS+=("Hono")
    elif echo "$PACKAGE_JSON" | grep -q '"@nestjs/core"'; then
        FRAMEWORKS+=("NestJS")
    elif echo "$PACKAGE_JSON" | grep -q '"nuxt"'; then
        FRAMEWORKS+=("Nuxt")
    elif echo "$PACKAGE_JSON" | grep -q '"gatsby"'; then
        FRAMEWORKS+=("Gatsby")
    elif echo "$PACKAGE_JSON" | grep -q '"remix"'; then
        FRAMEWORKS+=("Remix")
    fi

    if echo "$PACKAGE_JSON" | grep -q '"react"'; then
        FRAMEWORKS+=("React")
    elif echo "$PACKAGE_JSON" | grep -q '"vue"'; then
        FRAMEWORKS+=("Vue")
    elif echo "$PACKAGE_JSON" | grep -q '"svelte"'; then
        FRAMEWORKS+=("Svelte")
    elif echo "$PACKAGE_JSON" | grep -q '"@angular/core"'; then
        FRAMEWORKS+=("Angular")
    fi
fi

# -----------------------------------------------------------------------------
# Python
# -----------------------------------------------------------------------------
if [ -f "$CURRENT_DIR/requirements.txt" ] || [ -f "$CURRENT_DIR/pyproject.toml" ] || [ -f "$CURRENT_DIR/setup.py" ] || [ -f "$CURRENT_DIR/Pipfile" ]; then
    LANGUAGES+=("Python")

    if [ -f "$CURRENT_DIR/Pipfile.lock" ]; then
        PACKAGE_MANAGER="${PACKAGE_MANAGER:+$PACKAGE_MANAGER, }pipenv"
        HAS_LOCKFILE=true
    elif [ -f "$CURRENT_DIR/poetry.lock" ]; then
        PACKAGE_MANAGER="${PACKAGE_MANAGER:+$PACKAGE_MANAGER, }poetry"
        HAS_LOCKFILE=true
    elif [ -f "$CURRENT_DIR/uv.lock" ]; then
        PACKAGE_MANAGER="${PACKAGE_MANAGER:+$PACKAGE_MANAGER, }uv"
        HAS_LOCKFILE=true
    elif [ -f "$CURRENT_DIR/requirements.txt" ]; then
        PACKAGE_MANAGER="${PACKAGE_MANAGER:+$PACKAGE_MANAGER, }pip"
    fi

    # Python framework detection
    PY_DEPS=""
    if [ -f "$CURRENT_DIR/requirements.txt" ]; then
        PY_DEPS=$(cat "$CURRENT_DIR/requirements.txt" 2>/dev/null || echo "")
    fi
    if [ -f "$CURRENT_DIR/pyproject.toml" ]; then
        PY_DEPS="$PY_DEPS $(cat "$CURRENT_DIR/pyproject.toml" 2>/dev/null || echo "")"
    fi

    if echo "$PY_DEPS" | grep -qiE "^django|\"django\"|'django'"; then
        FRAMEWORKS+=("Django")
    fi
    if echo "$PY_DEPS" | grep -qiE "^fastapi|\"fastapi\"|'fastapi'"; then
        FRAMEWORKS+=("FastAPI")
    fi
    if echo "$PY_DEPS" | grep -qiE "^flask|\"flask\"|'flask'"; then
        FRAMEWORKS+=("Flask")
    fi
fi

# -----------------------------------------------------------------------------
# Go
# -----------------------------------------------------------------------------
if [ -f "$CURRENT_DIR/go.mod" ]; then
    LANGUAGES+=("Go")
    HAS_LOCKFILE=true  # go.sum is auto-generated

    GO_MOD=$(cat "$CURRENT_DIR/go.mod" 2>/dev/null || echo "")
    if echo "$GO_MOD" | grep -q "github.com/gin-gonic/gin"; then
        FRAMEWORKS+=("Gin")
    fi
    if echo "$GO_MOD" | grep -q "github.com/gofiber/fiber"; then
        FRAMEWORKS+=("Fiber")
    fi
    if echo "$GO_MOD" | grep -q "github.com/labstack/echo"; then
        FRAMEWORKS+=("Echo")
    fi
fi

# -----------------------------------------------------------------------------
# Rust
# -----------------------------------------------------------------------------
if [ -f "$CURRENT_DIR/Cargo.toml" ]; then
    LANGUAGES+=("Rust")
    if [ -f "$CURRENT_DIR/Cargo.lock" ]; then
        HAS_LOCKFILE=true
    fi

    CARGO_TOML=$(cat "$CURRENT_DIR/Cargo.toml" 2>/dev/null || echo "")
    if echo "$CARGO_TOML" | grep -q "actix-web"; then
        FRAMEWORKS+=("Actix Web")
    fi
    if echo "$CARGO_TOML" | grep -q "axum"; then
        FRAMEWORKS+=("Axum")
    fi
    if echo "$CARGO_TOML" | grep -q "rocket"; then
        FRAMEWORKS+=("Rocket")
    fi
fi

# -----------------------------------------------------------------------------
# Java / Kotlin
# -----------------------------------------------------------------------------
if [ -f "$CURRENT_DIR/pom.xml" ] || [ -f "$CURRENT_DIR/build.gradle" ] || [ -f "$CURRENT_DIR/build.gradle.kts" ]; then
    if [ -f "$CURRENT_DIR/build.gradle.kts" ]; then
        LANGUAGES+=("Kotlin")
    else
        LANGUAGES+=("Java")
    fi

    BUILD_FILE=""
    if [ -f "$CURRENT_DIR/pom.xml" ]; then
        BUILD_FILE=$(cat "$CURRENT_DIR/pom.xml" 2>/dev/null || echo "")
        PACKAGE_MANAGER="${PACKAGE_MANAGER:+$PACKAGE_MANAGER, }Maven"
    fi
    if [ -f "$CURRENT_DIR/build.gradle" ]; then
        BUILD_FILE=$(cat "$CURRENT_DIR/build.gradle" 2>/dev/null || echo "")
        PACKAGE_MANAGER="${PACKAGE_MANAGER:+$PACKAGE_MANAGER, }Gradle"
    fi
    if [ -f "$CURRENT_DIR/build.gradle.kts" ]; then
        BUILD_FILE=$(cat "$CURRENT_DIR/build.gradle.kts" 2>/dev/null || echo "")
        PACKAGE_MANAGER="${PACKAGE_MANAGER:+$PACKAGE_MANAGER, }Gradle"
    fi

    if echo "$BUILD_FILE" | grep -qiE "spring-boot|spring.boot"; then
        FRAMEWORKS+=("Spring Boot")
    fi
fi

# Add detected info to context
if [ ${#LANGUAGES[@]} -gt 0 ]; then
    CONTEXT_MESSAGES+=("Languages: ${LANGUAGES[*]}")
fi
if [ ${#FRAMEWORKS[@]} -gt 0 ]; then
    CONTEXT_MESSAGES+=("Frameworks: ${FRAMEWORKS[*]}")
fi
if [ -n "$PACKAGE_MANAGER" ]; then
    CONTEXT_MESSAGES+=("Package Manager: $PACKAGE_MANAGER")
fi

# =============================================================================
# AUTHENTICATION LIBRARY DETECTION
# =============================================================================

AUTH_LIBS=()

if [ -f "$CURRENT_DIR/package.json" ]; then
    # Node.js auth libraries
    if echo "$PACKAGE_JSON" | grep -q '"passport"'; then AUTH_LIBS+=("Passport.js"); fi
    if echo "$PACKAGE_JSON" | grep -q '"next-auth"'; then AUTH_LIBS+=("NextAuth.js"); fi
    if echo "$PACKAGE_JSON" | grep -qE '"@auth/'; then AUTH_LIBS+=("Auth.js"); fi
    if echo "$PACKAGE_JSON" | grep -q '"auth0"'; then AUTH_LIBS+=("Auth0"); fi
    if echo "$PACKAGE_JSON" | grep -q '"@auth0"'; then AUTH_LIBS+=("Auth0"); fi
    if echo "$PACKAGE_JSON" | grep -q '"firebase"'; then AUTH_LIBS+=("Firebase Auth"); fi
    if echo "$PACKAGE_JSON" | grep -q '"@supabase"'; then AUTH_LIBS+=("Supabase Auth"); fi
    if echo "$PACKAGE_JSON" | grep -q '"jsonwebtoken"'; then AUTH_LIBS+=("jsonwebtoken"); fi
    if echo "$PACKAGE_JSON" | grep -q '"jose"'; then AUTH_LIBS+=("jose (JWT)"); fi
    if echo "$PACKAGE_JSON" | grep -q '"bcrypt"'; then AUTH_LIBS+=("bcrypt"); fi
    if echo "$PACKAGE_JSON" | grep -q '"argon2"'; then AUTH_LIBS+=("argon2"); fi
    if echo "$PACKAGE_JSON" | grep -q '"clerk"'; then AUTH_LIBS+=("Clerk"); fi
    if echo "$PACKAGE_JSON" | grep -q '"@clerk"'; then AUTH_LIBS+=("Clerk"); fi
    if echo "$PACKAGE_JSON" | grep -q '"lucia"'; then AUTH_LIBS+=("Lucia Auth"); fi
    if echo "$PACKAGE_JSON" | grep -q '"better-auth"'; then AUTH_LIBS+=("Better Auth"); fi
fi

# Python auth detection
if [ -n "${PY_DEPS:-}" ]; then
    if echo "$PY_DEPS" | grep -qiE "django.contrib.auth|django-allauth"; then AUTH_LIBS+=("Django Auth"); fi
    if echo "$PY_DEPS" | grep -qi "python-jose"; then AUTH_LIBS+=("python-jose (JWT)"); fi
    if echo "$PY_DEPS" | grep -qi "pyjwt"; then AUTH_LIBS+=("PyJWT"); fi
    if echo "$PY_DEPS" | grep -qi "passlib"; then AUTH_LIBS+=("passlib"); fi
    if echo "$PY_DEPS" | grep -qi "authlib"; then AUTH_LIBS+=("Authlib"); fi
fi

if [ ${#AUTH_LIBS[@]} -gt 0 ]; then
    SECURITY_CONTEXT+=("Authentication libraries: ${AUTH_LIBS[*]}")
fi

# =============================================================================
# DATABASE / ORM DETECTION
# =============================================================================

ORM_LIBS=()

if [ -f "$CURRENT_DIR/package.json" ]; then
    if echo "$PACKAGE_JSON" | grep -q '"prisma"'; then ORM_LIBS+=("Prisma"); fi
    if echo "$PACKAGE_JSON" | grep -q '"@prisma/client"'; then ORM_LIBS+=("Prisma"); fi
    if echo "$PACKAGE_JSON" | grep -q '"sequelize"'; then ORM_LIBS+=("Sequelize"); fi
    if echo "$PACKAGE_JSON" | grep -q '"typeorm"'; then ORM_LIBS+=("TypeORM"); fi
    if echo "$PACKAGE_JSON" | grep -q '"drizzle-orm"'; then ORM_LIBS+=("Drizzle ORM"); fi
    if echo "$PACKAGE_JSON" | grep -q '"knex"'; then ORM_LIBS+=("Knex.js"); fi
    if echo "$PACKAGE_JSON" | grep -q '"mongoose"'; then ORM_LIBS+=("Mongoose"); fi
    if echo "$PACKAGE_JSON" | grep -q '"@mikro-orm"'; then ORM_LIBS+=("MikroORM"); fi
fi

# Python ORM detection
if [ -n "${PY_DEPS:-}" ]; then
    if echo "$PY_DEPS" | grep -qi "sqlalchemy"; then ORM_LIBS+=("SQLAlchemy"); fi
    if echo "$PY_DEPS" | grep -qi "django"; then ORM_LIBS+=("Django ORM"); fi
    if echo "$PY_DEPS" | grep -qi "tortoise-orm"; then ORM_LIBS+=("Tortoise ORM"); fi
    if echo "$PY_DEPS" | grep -qi "peewee"; then ORM_LIBS+=("Peewee"); fi
fi

# Go ORM detection
if [ -n "${GO_MOD:-}" ]; then
    if echo "$GO_MOD" | grep -q "gorm.io/gorm"; then ORM_LIBS+=("GORM"); fi
    if echo "$GO_MOD" | grep -q "entgo.io/ent"; then ORM_LIBS+=("Ent"); fi
    if echo "$GO_MOD" | grep -q "github.com/jmoiron/sqlx"; then ORM_LIBS+=("sqlx"); fi
fi

# Deduplicate ORM list
if [ ${#ORM_LIBS[@]} -gt 0 ]; then
    # Simple dedup by converting to sorted unique
    UNIQUE_ORMS=$(printf '%s\n' "${ORM_LIBS[@]}" | sort -u | tr '\n' ', ' | sed 's/,$//')
    SECURITY_CONTEXT+=("Database/ORM: $UNIQUE_ORMS")
fi

# =============================================================================
# ENVIRONMENT FILE DETECTION
# =============================================================================

ENV_FILES=()
ENV_IN_GIT=false

for env_file in ".env" ".env.local" ".env.development" ".env.production" ".env.staging" ".env.test"; do
    if [ -f "$CURRENT_DIR/$env_file" ]; then
        ENV_FILES+=("$env_file")
    fi
done

if [ ${#ENV_FILES[@]} -gt 0 ]; then
    SECURITY_CONTEXT+=("Environment files found: ${ENV_FILES[*]}")

    # Check if .env files are tracked by git
    if command -v git &>/dev/null && [ -d "$CURRENT_DIR/.git" ]; then
        for env_file in "${ENV_FILES[@]}"; do
            if git -C "$CURRENT_DIR" ls-files --error-unmatch "$env_file" &>/dev/null; then
                ENV_IN_GIT=true
                WARNINGS+=("CRITICAL: $env_file is tracked by git - secrets may be exposed in history")
            fi
        done
    fi
fi

# Check for .env.example (good practice)
if [ ${#ENV_FILES[@]} -gt 0 ] && [ ! -f "$CURRENT_DIR/.env.example" ] && [ ! -f "$CURRENT_DIR/.env.template" ]; then
    WARNINGS+=("No .env.example or .env.template found - consider adding one for safe onboarding")
fi

# =============================================================================
# DOCKER / CONTAINER DETECTION
# =============================================================================

HAS_DOCKER=false

if [ -f "$CURRENT_DIR/Dockerfile" ] || [ -f "$CURRENT_DIR/docker-compose.yml" ] || [ -f "$CURRENT_DIR/docker-compose.yaml" ] || [ -f "$CURRENT_DIR/compose.yml" ] || [ -f "$CURRENT_DIR/compose.yaml" ]; then
    HAS_DOCKER=true
    SECURITY_CONTEXT+=("Docker/container setup detected")
fi

# Check for Kubernetes manifests
HAS_K8S=false
if [ -d "$CURRENT_DIR/k8s" ] || [ -d "$CURRENT_DIR/kubernetes" ] || [ -d "$CURRENT_DIR/manifests" ] || [ -d "$CURRENT_DIR/charts" ]; then
    HAS_K8S=true
    SECURITY_CONTEXT+=("Kubernetes manifests detected")
fi

# Check for Terraform
HAS_TERRAFORM=false
if find "$CURRENT_DIR" -maxdepth 2 -name "*.tf" -print -quit 2>/dev/null | grep -q .; then
    HAS_TERRAFORM=true
    SECURITY_CONTEXT+=("Terraform configuration detected")
fi

# =============================================================================
# CI/CD DETECTION
# =============================================================================

CI_SYSTEMS=()

if [ -d "$CURRENT_DIR/.github/workflows" ]; then CI_SYSTEMS+=("GitHub Actions"); fi
if [ -f "$CURRENT_DIR/.gitlab-ci.yml" ]; then CI_SYSTEMS+=("GitLab CI"); fi
if [ -f "$CURRENT_DIR/Jenkinsfile" ]; then CI_SYSTEMS+=("Jenkins"); fi
if [ -f "$CURRENT_DIR/.circleci/config.yml" ]; then CI_SYSTEMS+=("CircleCI"); fi
if [ -f "$CURRENT_DIR/.travis.yml" ]; then CI_SYSTEMS+=("Travis CI"); fi
if [ -d "$CURRENT_DIR/.buildkite" ]; then CI_SYSTEMS+=("Buildkite"); fi
if [ -f "$CURRENT_DIR/azure-pipelines.yml" ]; then CI_SYSTEMS+=("Azure Pipelines"); fi
if [ -f "$CURRENT_DIR/bitbucket-pipelines.yml" ]; then CI_SYSTEMS+=("Bitbucket Pipelines"); fi

if [ ${#CI_SYSTEMS[@]} -gt 0 ]; then
    SECURITY_CONTEXT+=("CI/CD: ${CI_SYSTEMS[*]}")
fi

# =============================================================================
# SECURITY TOOLING DETECTION
# =============================================================================

SECURITY_TOOLS=()

# Static analysis / SAST
if [ -f "$CURRENT_DIR/.snyk" ] || [ -f "$CURRENT_DIR/.snyk.yaml" ]; then SECURITY_TOOLS+=("Snyk"); fi
if [ -f "$CURRENT_DIR/.trivyignore" ] || [ -f "$CURRENT_DIR/trivy.yaml" ]; then SECURITY_TOOLS+=("Trivy"); fi
if [ -f "$CURRENT_DIR/.semgrep.yml" ] || [ -d "$CURRENT_DIR/.semgrep" ]; then SECURITY_TOOLS+=("Semgrep"); fi
if [ -f "$CURRENT_DIR/.bandit" ] || [ -f "$CURRENT_DIR/.bandit.yml" ]; then SECURITY_TOOLS+=("Bandit"); fi
if [ -f "$CURRENT_DIR/.safety" ] || [ -f "$CURRENT_DIR/.safety-policy.yml" ]; then SECURITY_TOOLS+=("Safety"); fi

# Secret scanning
if [ -f "$CURRENT_DIR/.gitleaks.toml" ]; then SECURITY_TOOLS+=("Gitleaks"); fi
if [ -f "$CURRENT_DIR/.secretlintrc.json" ] || [ -f "$CURRENT_DIR/.secretlintrc" ]; then SECURITY_TOOLS+=("Secretlint"); fi
if [ -f "$CURRENT_DIR/.pre-commit-config.yaml" ]; then
    if grep -q "detect-secrets\|gitleaks\|trufflehog" "$CURRENT_DIR/.pre-commit-config.yaml" 2>/dev/null; then
        SECURITY_TOOLS+=("Pre-commit secret scanning")
    fi
fi

# Dependency scanning
if [ -f "$CURRENT_DIR/.npmrc" ] && grep -q "audit" "$CURRENT_DIR/.npmrc" 2>/dev/null; then
    SECURITY_TOOLS+=("npm audit configured")
fi
if [ -f "$CURRENT_DIR/.github/dependabot.yml" ]; then SECURITY_TOOLS+=("Dependabot"); fi
if [ -f "$CURRENT_DIR/renovate.json" ] || [ -f "$CURRENT_DIR/.renovaterc.json" ]; then SECURITY_TOOLS+=("Renovate"); fi

# ESLint security rules
ESLINT_FILES=$(find "$CURRENT_DIR" -maxdepth 1 -name ".eslintrc*" -o -name "eslint.config.*" 2>/dev/null)
if [ -n "$ESLINT_FILES" ]; then
    for eslint_file in $ESLINT_FILES; do
        if grep -qiE "security|no-eval|no-new-Function" "$eslint_file" 2>/dev/null; then
            SECURITY_TOOLS+=("ESLint security rules")
            break
        fi
    done
fi

if [ ${#SECURITY_TOOLS[@]} -gt 0 ]; then
    SECURITY_CONTEXT+=("Security tools configured: ${SECURITY_TOOLS[*]}")
fi

# =============================================================================
# SECURITY BASICS WARNINGS
# =============================================================================

# Check for .gitignore
if [ -d "$CURRENT_DIR/.git" ]; then
    if [ ! -f "$CURRENT_DIR/.gitignore" ]; then
        WARNINGS+=("CRITICAL: No .gitignore found - secrets, build artifacts, and node_modules may be committed")
    else
        GITIGNORE=$(cat "$CURRENT_DIR/.gitignore" 2>/dev/null || echo "")
        # Check .gitignore covers .env
        if ! echo "$GITIGNORE" | grep -qE "^\.env$|^\*\.env|^\.env\*"; then
            WARNINGS+=("WARNING: .gitignore does not appear to exclude .env files")
        fi
        # Check .gitignore covers node_modules (if Node project)
        if [ -f "$CURRENT_DIR/package.json" ] && ! echo "$GITIGNORE" | grep -q "node_modules"; then
            WARNINGS+=("WARNING: .gitignore does not exclude node_modules")
        fi
    fi
fi

# Check for lockfile
if [ "$HAS_LOCKFILE" = false ] && [ ${#LANGUAGES[@]} -gt 0 ]; then
    WARNINGS+=("WARNING: No lockfile found - dependency versions are not pinned (supply chain risk)")
fi

# Check for security headers config in web frameworks
HAS_SECURITY_HEADERS=false
if [ -f "$CURRENT_DIR/next.config.js" ] || [ -f "$CURRENT_DIR/next.config.mjs" ] || [ -f "$CURRENT_DIR/next.config.ts" ]; then
    NEXT_CONFIG=$(cat "$CURRENT_DIR/next.config."* 2>/dev/null || echo "")
    if echo "$NEXT_CONFIG" | grep -qiE "headers|Content-Security-Policy|X-Frame-Options"; then
        HAS_SECURITY_HEADERS=true
    fi
fi

if [ -f "$CURRENT_DIR/package.json" ] && echo "$PACKAGE_JSON" | grep -q '"helmet"' 2>/dev/null; then
    HAS_SECURITY_HEADERS=true
fi

# Only warn about security headers for web frameworks
WEB_FRAMEWORK=false
for fw in "${FRAMEWORKS[@]}"; do
    case "$fw" in
        "Next.js"|"Express"|"Fastify"|"NestJS"|"Nuxt"|"Django"|"FastAPI"|"Flask"|"Gin"|"Fiber"|"Echo"|"Spring Boot"|"Hono"|"Actix Web"|"Axum"|"Rocket")
            WEB_FRAMEWORK=true
            ;;
    esac
done

if [ "$WEB_FRAMEWORK" = true ] && [ "$HAS_SECURITY_HEADERS" = false ]; then
    WARNINGS+=("No security headers configuration detected (CSP, X-Frame-Options, etc.) - consider helmet (Node), django-security-headers, or framework config")
fi

# Check for CORS configuration in web frameworks
if [ "$WEB_FRAMEWORK" = true ] && [ -f "$CURRENT_DIR/package.json" ]; then
    if ! echo "$PACKAGE_JSON" | grep -qE '"cors"|"@fastify/cors"' 2>/dev/null; then
        # Only warn if it looks like an API project (has routes/endpoints)
        if find "$CURRENT_DIR/src" -maxdepth 3 -name "*route*" -o -name "*controller*" -o -name "*api*" 2>/dev/null | grep -q .; then
            WARNINGS+=("No CORS middleware detected for API project")
        fi
    fi
fi

# =============================================================================
# PLUGIN RECOMMENDATIONS
# =============================================================================

RECOMMENDED_PLUGINS=()

# Always recommend secure coding
RECOMMENDED_PLUGINS+=("secure-coding-practices")

# Auth-related plugins
if [ ${#AUTH_LIBS[@]} -gt 0 ]; then
    RECOMMENDED_PLUGINS+=("identity-access-management")
fi

# Database security
if [ ${#ORM_LIBS[@]} -gt 0 ]; then
    RECOMMENDED_PLUGINS+=("web-application-security")
fi

# Web framework security
if [ "$WEB_FRAMEWORK" = true ]; then
    RECOMMENDED_PLUGINS+=("api-security-testing")
    RECOMMENDED_PLUGINS+=("web-application-security")
fi

# Container security
if [ "$HAS_DOCKER" = true ]; then
    RECOMMENDED_PLUGINS+=("container-security")
fi
if [ "$HAS_K8S" = true ]; then
    RECOMMENDED_PLUGINS+=("kubernetes-security")
fi

# Cloud / IaC
if [ "$HAS_TERRAFORM" = true ]; then
    RECOMMENDED_PLUGINS+=("cloud-security-aws")
fi

# CI/CD security
if [ ${#CI_SYSTEMS[@]} -gt 0 ]; then
    RECOMMENDED_PLUGINS+=("devsecops-pipelines")
    RECOMMENDED_PLUGINS+=("supply-chain-security")
fi

# Secrets management (if env files found but no secret scanning)
if [ ${#ENV_FILES[@]} -gt 0 ] && [ ${#SECURITY_TOOLS[@]} -eq 0 ]; then
    RECOMMENDED_PLUGINS+=("secrets-management")
fi

# No security tooling at all
if [ ${#SECURITY_TOOLS[@]} -eq 0 ] && [ ${#LANGUAGES[@]} -gt 0 ]; then
    RECOMMENDED_PLUGINS+=("vulnerability-scanning")
    RECOMMENDED_PLUGINS+=("security-automation")
fi

# Deduplicate plugin recommendations
if [ ${#RECOMMENDED_PLUGINS[@]} -gt 0 ]; then
    UNIQUE_PLUGINS=$(printf '%s\n' "${RECOMMENDED_PLUGINS[@]}" | sort -u | tr '\n' ', ' | sed 's/,$//')
    SECURITY_CONTEXT+=("Recommended LibreSecOps plugins: $UNIQUE_PLUGINS")
fi

# =============================================================================
# OUTPUT STRUCTURED RESPONSE
# =============================================================================

# Build JSON output for Claude
OUTPUT="{"

# Add context about the security environment
if [ ${#CONTEXT_MESSAGES[@]} -gt 0 ] || [ ${#SECURITY_CONTEXT[@]} -gt 0 ]; then
    OUTPUT="$OUTPUT\"additionalContext\":["
    FIRST=true

    # Add main context messages
    for msg in "${CONTEXT_MESSAGES[@]}"; do
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            OUTPUT="$OUTPUT,"
        fi
        ESCAPED_MSG=$(echo "$msg" | sed 's/"/\\"/g')
        OUTPUT="$OUTPUT{\"type\":\"text\",\"text\":\"$ESCAPED_MSG\"}"
    done

    # Add security context details
    for msg in "${SECURITY_CONTEXT[@]}"; do
        if [ "$FIRST" = true ]; then
            FIRST=false
        else
            OUTPUT="$OUTPUT,"
        fi
        ESCAPED_MSG=$(echo "$msg" | sed 's/"/\\"/g')
        OUTPUT="$OUTPUT{\"type\":\"text\",\"text\":\"$ESCAPED_MSG\"}"
    done

    OUTPUT="$OUTPUT]"
fi

# Add warnings as system messages
if [ ${#WARNINGS[@]} -gt 0 ]; then
    if [ ${#CONTEXT_MESSAGES[@]} -gt 0 ] || [ ${#SECURITY_CONTEXT[@]} -gt 0 ]; then
        OUTPUT="$OUTPUT,"
    fi
    OUTPUT="$OUTPUT\"systemMessage\":\"LibreSecOps Security Assessment:\\n"
    for warn in "${WARNINGS[@]}"; do
        ESCAPED_WARN=$(echo "$warn" | sed 's/"/\\"/g')
        OUTPUT="$OUTPUT- $ESCAPED_WARN\\n"
    done
    OUTPUT="$OUTPUT\""
fi

OUTPUT="$OUTPUT}"

# Output JSON only if we have content
if [ ${#CONTEXT_MESSAGES[@]} -gt 0 ] || [ ${#SECURITY_CONTEXT[@]} -gt 0 ] || [ ${#WARNINGS[@]} -gt 0 ]; then
    echo "$OUTPUT"
fi

# Log the detection summary
{
    echo "$(date '+%Y-%m-%d %H:%M:%S') - Security Assessment for $PROJECT_NAME"
    echo "  Languages: ${LANGUAGES[*]:-none}"
    echo "  Frameworks: ${FRAMEWORKS[*]:-none}"
    echo "  Auth Libraries: ${AUTH_LIBS[*]:-none}"
    echo "  ORMs: ${ORM_LIBS[*]:-none}"
    echo "  Security Tools: ${SECURITY_TOOLS[*]:-none}"
    echo "  Env Files: ${ENV_FILES[*]:-none}"
    echo "  Env in Git: $ENV_IN_GIT"
    echo "  Has Lockfile: $HAS_LOCKFILE"
    echo "  Docker: $HAS_DOCKER | K8s: $HAS_K8S | Terraform: $HAS_TERRAFORM"
    echo "  CI/CD: ${CI_SYSTEMS[*]:-none}"
    echo "  Warnings: ${#WARNINGS[@]}"
    echo "---"
} >> "$HOOKS_LOG_DIR/sessions.log"

exit 0
