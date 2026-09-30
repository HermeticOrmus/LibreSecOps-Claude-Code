#!/usr/bin/env bash
# =============================================================================
# LibreSecOps SessionStart hook
# =============================================================================
# Runs when a Claude Code session starts, resumes, clears, or compacts.
#
# Claude Code sends the hook input as JSON on stdin; this hook reads cwd with
# jq and looks at the project's files (no network calls, nothing written):
#
# 1. Languages, frameworks, and lockfiles (Node, Python, Go, Rust, Java/Kotlin)
# 2. Auth libraries and ORMs
# 3. .env files, and whether any is tracked by git
# 4. Docker, Kubernetes manifests, Terraform, CI/CD systems
# 5. Security tooling (Snyk, Trivy, Semgrep, Gitleaks, Dependabot, ...)
# 6. Missing basics (.gitignore, .env ignore rule, lockfile, security headers)
# 7. Which LibreSecOps plugins fit the detected stack
#
# When the directory is a software project it prints ONE line of plain text,
# which Claude Code adds to the session context. Anywhere else it prints
# nothing.
# =============================================================================

set -euo pipefail
IFS=$'\n\t'

INPUT="$(cat)"
DIR=""
if command -v jq >/dev/null 2>&1; then
  DIR="$(jq -r '.cwd // empty' <<<"$INPUT" 2>/dev/null || true)"
fi
DIR="${DIR:-$PWD}"
[[ -d "$DIR" ]] || exit 0

f() { [[ -f "$DIR/$1" ]]; }
d() { [[ -d "$DIR/$1" ]]; }
# grep a file without failing when it is missing.
in_file() { [[ -f "$DIR/$2" ]] && grep -qiE -- "$1" "$DIR/$2"; }

LANGS=()
FRAMEWORKS=()
AUTH=()
ORMS=()
INFRA=()
CI=()
TOOLS=()
WARN=()
HAS_LOCKFILE=false

# -----------------------------------------------------------------------------
# Languages, frameworks, lockfiles
# -----------------------------------------------------------------------------
PKG=""
if f package.json; then
  LANGS+=("JavaScript/TypeScript")
  PKG="$(cat "$DIR/package.json" 2>/dev/null || true)"
  if f pnpm-lock.yaml || f yarn.lock || f bun.lockb || f bun.lock || f package-lock.json; then HAS_LOCKFILE=true; fi
  pkg() { grep -qE -- "\"$1\"" <<<"$PKG"; }
  for pair in next:Next.js express:Express fastify:Fastify hono:Hono @nestjs/core:NestJS nuxt:Nuxt remix:Remix @remix-run/node:Remix gatsby:Gatsby; do
    pkg "${pair%%:*}" && FRAMEWORKS+=("${pair#*:}")
  done
  for pair in passport:Passport next-auth:NextAuth @auth/core:Auth.js @auth0/nextjs-auth0:Auth0 auth0:Auth0 firebase:Firebase @supabase/supabase-js:Supabase jsonwebtoken:jsonwebtoken jose:jose @clerk/nextjs:Clerk lucia:Lucia better-auth:Better-Auth; do
    pkg "${pair%%:*}" && AUTH+=("${pair#*:}")
  done
  for pair in @prisma/client:Prisma prisma:Prisma sequelize:Sequelize typeorm:TypeORM drizzle-orm:Drizzle knex:Knex mongoose:Mongoose; do
    pkg "${pair%%:*}" && ORMS+=("${pair#*:}")
  done
fi

PY=""
if f requirements.txt || f pyproject.toml || f setup.py || f Pipfile; then
  LANGS+=("Python")
  if f Pipfile.lock || f poetry.lock || f uv.lock; then HAS_LOCKFILE=true; fi
  PY="$(cat "$DIR/requirements.txt" "$DIR/pyproject.toml" "$DIR/Pipfile" 2>/dev/null || true)"
  py() { grep -qiE -- "$1" <<<"$PY"; }
  py '(^|["'"'"' ])django' && FRAMEWORKS+=("Django") && ORMS+=("Django ORM")
  py '(^|["'"'"' ])fastapi' && FRAMEWORKS+=("FastAPI")
  py '(^|["'"'"' ])flask' && FRAMEWORKS+=("Flask")
  py 'sqlalchemy' && ORMS+=("SQLAlchemy")
  py 'django-allauth' && AUTH+=("django-allauth")
  py 'pyjwt|python-jose' && AUTH+=("JWT")
  py 'authlib' && AUTH+=("Authlib")
  py 'passlib' && AUTH+=("passlib")
fi

if f go.mod; then
  LANGS+=("Go")
  HAS_LOCKFILE=true
  in_file 'github.com/gin-gonic/gin' go.mod && FRAMEWORKS+=("Gin")
  in_file 'github.com/gofiber/fiber' go.mod && FRAMEWORKS+=("Fiber")
  in_file 'github.com/labstack/echo' go.mod && FRAMEWORKS+=("Echo")
  in_file 'gorm.io/gorm' go.mod && ORMS+=("GORM")
fi

if f Cargo.toml; then
  LANGS+=("Rust")
  f Cargo.lock && HAS_LOCKFILE=true
  in_file 'actix-web' Cargo.toml && FRAMEWORKS+=("Actix Web")
  in_file '^axum|[^a-z]axum' Cargo.toml && FRAMEWORKS+=("Axum")
  in_file '^rocket|[^a-z]rocket' Cargo.toml && FRAMEWORKS+=("Rocket")
fi

if f pom.xml || f build.gradle || f build.gradle.kts; then
  if f build.gradle.kts; then LANGS+=("Kotlin"); else LANGS+=("Java"); fi
  { in_file 'spring-boot' pom.xml || in_file 'spring-boot|org.springframework.boot' build.gradle || in_file 'spring-boot|org.springframework.boot' build.gradle.kts; } && FRAMEWORKS+=("Spring Boot")
  { f gradle.lockfile || f pom.xml; } && HAS_LOCKFILE=true
fi

# -----------------------------------------------------------------------------
# Infrastructure and CI/CD
# -----------------------------------------------------------------------------
HAS_DOCKER=false; HAS_K8S=false; HAS_TF=false
if f Dockerfile || f docker-compose.yml || f docker-compose.yaml || f compose.yml || f compose.yaml; then HAS_DOCKER=true; INFRA+=("Docker"); fi
if d k8s || d kubernetes || d manifests || d charts || d helm; then HAS_K8S=true; INFRA+=("Kubernetes"); fi
if find "$DIR" -maxdepth 2 -name '*.tf' -not -path '*/.terraform/*' -print -quit 2>/dev/null | grep -q .; then HAS_TF=true; INFRA+=("Terraform"); fi

d .github/workflows && CI+=("GitHub Actions")
f .gitlab-ci.yml && CI+=("GitLab CI")
f Jenkinsfile && CI+=("Jenkins")
f .circleci/config.yml && CI+=("CircleCI")
f azure-pipelines.yml && CI+=("Azure Pipelines")
f bitbucket-pipelines.yml && CI+=("Bitbucket Pipelines")

# Only a software project gets a line.
(( ${#LANGS[@]} > 0 || ${#INFRA[@]} > 0 )) || exit 0

# -----------------------------------------------------------------------------
# Security tooling
# -----------------------------------------------------------------------------
{ f .snyk || f .snyk.yaml; } && TOOLS+=("Snyk")
{ f .trivyignore || f trivy.yaml; } && TOOLS+=("Trivy")
{ f .semgrep.yml || d .semgrep; } && TOOLS+=("Semgrep")
{ f .bandit || f .bandit.yml; } && TOOLS+=("Bandit")
f .gitleaks.toml && TOOLS+=("Gitleaks")
{ f .secretlintrc || f .secretlintrc.json; } && TOOLS+=("Secretlint")
in_file 'detect-secrets|gitleaks|trufflehog' .pre-commit-config.yaml && TOOLS+=("pre-commit secret scanning")
f .github/dependabot.yml && TOOLS+=("Dependabot")
{ f renovate.json || f .renovaterc.json; } && TOOLS+=("Renovate")
if [[ -d "$DIR/.github/workflows" ]] && grep -rqiE 'codeql|semgrep|trivy|gitleaks|snyk|zap|dependency-review' "$DIR/.github/workflows" 2>/dev/null; then
  TOOLS+=("security scanning in CI")
fi

# -----------------------------------------------------------------------------
# Missing basics
# -----------------------------------------------------------------------------
ENV_FILES=()
for e in .env .env.local .env.development .env.production .env.staging .env.test; do
  f "$e" && ENV_FILES+=("$e")
done
if git -C "$DIR" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  for e in ${ENV_FILES[@]+"${ENV_FILES[@]}"}; do
    git -C "$DIR" ls-files --error-unmatch "$e" >/dev/null 2>&1 && WARN+=("$e tracked by git")
  done
  if ! f .gitignore; then
    WARN+=("no .gitignore")
  elif ! grep -qE '^\s*(\.env|\.env\*|\*\.env|\.env\.\*)\s*$' "$DIR/.gitignore"; then
    WARN+=("no .env rule in .gitignore")
  fi
fi
[[ "$HAS_LOCKFILE" == false && ${#LANGS[@]} -gt 0 ]] && WARN+=("no lockfile")

WEB=false
for fw in ${FRAMEWORKS[@]+"${FRAMEWORKS[@]}"}; do
  case "$fw" in Next.js|Express|Fastify|Hono|NestJS|Nuxt|Remix|Django|FastAPI|Flask|Gin|Fiber|Echo|"Actix Web"|Axum|Rocket|"Spring Boot") WEB=true ;; esac
done
if [[ "$WEB" == true ]]; then
  HEADERS=false
  grep -qE '"helmet"' <<<"$PKG" && HEADERS=true
  grep -qiE 'Content-Security-Policy|X-Frame-Options|headers\s*\(' "$DIR"/next.config.* 2>/dev/null && HEADERS=true
  grep -qiE 'django-csp|secure-headers|secure_headers|flask-talisman' <<<"$PY" && HEADERS=true
  [[ "$HEADERS" == true ]] || WARN+=("no security headers setup")
fi
(( ${#TOOLS[@]} == 0 )) && WARN+=("no security tooling configured")

# -----------------------------------------------------------------------------
# Plugin suggestions
# -----------------------------------------------------------------------------
SUGGEST=("secure-coding-practices")
(( ${#AUTH[@]} > 0 )) && SUGGEST+=("identity-access-management")
[[ "$WEB" == true ]] && SUGGEST+=("web-application-security" "api-security-testing")
[[ "$HAS_DOCKER" == true ]] && SUGGEST+=("container-security")
[[ "$HAS_K8S" == true ]] && SUGGEST+=("kubernetes-security")
[[ "$HAS_TF" == true ]] && SUGGEST+=("cloud-security-aws")
(( ${#CI[@]} > 0 )) && SUGGEST+=("devsecops-pipelines" "supply-chain-security")
(( ${#ENV_FILES[@]} > 0 )) && SUGGEST+=("secrets-management")
(( ${#TOOLS[@]} == 0 )) && SUGGEST+=("vulnerability-scanning")

# -----------------------------------------------------------------------------
# One line out
# -----------------------------------------------------------------------------
# Comma-separated list of the arguments, duplicates removed, order kept.
# Written without mapfile so it also runs under bash 3.2 (the macOS default).
csv() { printf '%s\n' "$@" | awk 'NF && !seen[$0]++' | paste -sd, - | sed 's/,/, /g'; }

STACK=""
(( ${#LANGS[@]} > 0 )) && STACK="$(csv "${LANGS[@]}")"
(( ${#FRAMEWORKS[@]} > 0 )) && STACK+=" ($(csv "${FRAMEWORKS[@]}"))"
LINE="LibreSecOps:"
SEP=" "
add() { LINE+="${SEP}$1"; SEP="; "; }
[[ -n "$STACK" ]] && add "$STACK"
(( ${#AUTH[@]} > 0 )) && add "auth: $(csv "${AUTH[@]}")"
(( ${#ORMS[@]} > 0 )) && add "data: $(csv "${ORMS[@]}")"
(( ${#INFRA[@]} > 0 )) && add "infra: $(csv "${INFRA[@]}")"
(( ${#CI[@]} > 0 )) && add "CI: $(csv "${CI[@]}")"
(( ${#TOOLS[@]} > 0 )) && add "security tooling: $(csv "${TOOLS[@]}")"
LINE+="."
(( ${#WARN[@]} > 0 )) && LINE+=" Gaps: $(csv "${WARN[@]}")."
LINE+=" Relevant plugins: $(printf '%s\n' "${SUGGEST[@]}" | awk 'NF && !seen[$0]++' | head -5 | paste -sd, - | sed 's/,/, /g')."
printf '%s\n' "$LINE"
exit 0
