# Dockerfile Hardening

> Secure Dockerfile patterns, multi-stage builds, minimal base images, and build-time security practices.

## Knowledge Base

### Container Image Security Model

A container image is a stack of filesystem layers. Each Dockerfile instruction creates a layer. Security implications:

- **Layers are permanent.** Even if you `RUN rm /secret` in a later layer, the file exists in the layer where it was created. Anyone with `docker history` or `dive` can extract it.
- **Layers are shared.** If two images share a base, they share layers. A vulnerability in the base affects all derived images.
- **The build context is sent to the daemon.** Without `.dockerignore`, your entire directory (including `.env`, `.git`, `node_modules`) is sent to the Docker daemon.

### Base Image Hierarchy (Most to Least Secure)

| Base | Size | Packages | Debug Tools | Use Case |
|------|------|----------|-------------|----------|
| `scratch` | 0 MB | None | None | Statically compiled Go/Rust binaries |
| `gcr.io/distroless/*` | 2-20 MB | Runtime only (glibc, libssl) | None | Java, Python, Node.js runtimes |
| `cgr.dev/chainguard/*` | 5-30 MB | Minimal, hardened, daily-patched | Minimal | Production workloads needing updates |
| `alpine` | 5 MB | musl, busybox, apk | Basic shell | General purpose, small footprint |
| `debian-slim` | 75 MB | glibc, apt, basic utils | Some | When Alpine compatibility issues arise |
| `ubuntu` | 75 MB | Full distribution | Full | Development, not recommended for production |

## Patterns

### Pattern 1: Multi-Stage Build (Node.js)

```dockerfile
# Stage 1: Build
FROM node:22-alpine AS builder
WORKDIR /app

# Install dependencies first (cache optimization)
COPY package.json package-lock.json ./
RUN npm ci --only=production

# Copy source and build
COPY src/ ./src/
COPY tsconfig.json ./
RUN npm run build

# Stage 2: Runtime (distroless)
FROM gcr.io/distroless/nodejs22-debian12:nonroot
WORKDIR /app

# Copy only production artifacts
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist

# Distroless already runs as nonroot (uid 65532)
EXPOSE 3000
CMD ["dist/server.js"]
```

**Why this works**: Build tools (npm, TypeScript compiler, dev dependencies) never appear in the final image. Distroless has no shell, no package manager, no debugging tools -- an attacker who gains code execution cannot download additional tools or explore the filesystem. The `nonroot` tag runs as UID 65532.

### Pattern 2: Multi-Stage Build (Go)

```dockerfile
# Stage 1: Build
FROM golang:1.22-alpine AS builder
WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build \
    -ldflags="-w -s" \
    -o /app/server ./cmd/server

# Stage 2: Runtime (scratch -- zero dependencies)
FROM scratch

# Import CA certificates for HTTPS
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Import the binary
COPY --from=builder /app/server /server

# Run as non-root
USER 65534:65534

EXPOSE 8080
ENTRYPOINT ["/server"]
```

**Why this works**: `scratch` is literally empty -- the final image contains only the binary and CA certificates. `CGO_ENABLED=0` ensures a statically linked binary with no glibc dependency. `-ldflags="-w -s"` strips debug information, reducing binary size and attack surface. Running as UID 65534 (nobody) even in scratch prevents root-level access.

### Pattern 3: Secrets Handling with BuildKit

```dockerfile
# syntax=docker/dockerfile:1

FROM python:3.12-slim AS builder
WORKDIR /app

# Use BuildKit secret mount -- secret is available only during this RUN
# and never persisted in any layer
RUN --mount=type=secret,id=pip_conf,target=/etc/pip.conf \
    pip install --no-cache-dir -r requirements.txt

# Build command:
# DOCKER_BUILDKIT=1 docker build --secret id=pip_conf,src=./pip.conf .
```

**Why this works**: The `--mount=type=secret` directive makes the secret available as a temporary mount during the `RUN` instruction. It is never written to a layer, never appears in `docker history`, and cannot be extracted from the final image. This is the correct way to handle private registry credentials, SSH keys, or API tokens during build.

### Pattern 4: Hardened Alpine Image

```dockerfile
FROM alpine:3.19

# Security: Create non-root user early
RUN addgroup -g 1001 -S appgroup && \
    adduser -u 1001 -S appuser -G appgroup

# Install only required packages with pinned versions
RUN apk add --no-cache \
    dumb-init=1.2.5-r3 \
    && rm -rf /var/cache/apk/*

WORKDIR /app

# Copy with explicit ownership
COPY --chown=appuser:appgroup ./app /app/

# Drop all capabilities, use dumb-init as PID 1
USER appuser:appgroup
ENTRYPOINT ["dumb-init", "--"]
CMD ["/app/server"]

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
```

**Why this works**: `dumb-init` handles signal forwarding and zombie reaping (containers need a proper PID 1). Pinned package versions ensure reproducible builds. HEALTHCHECK enables orchestrators to detect and restart unhealthy containers. Non-root user with explicit group membership follows the principle of least privilege.

### Pattern 5: Comprehensive .dockerignore

```
# Version control
.git
.gitignore

# IDE and editor files
.vscode
.idea
*.swp
*.swo

# Environment and secrets
.env
.env.*
*.pem
*.key
*.crt
credentials.json
secrets/

# Build artifacts and dependencies
node_modules
__pycache__
*.pyc
dist
build
target

# Documentation (not needed in image)
*.md
LICENSE
docs/

# Docker files (prevent recursive context)
Dockerfile*
docker-compose*
.dockerignore

# CI/CD
.github
.gitlab-ci.yml
Jenkinsfile

# Tests (not needed in production image)
test/
tests/
*_test.go
*.test.js
```

**Why this works**: Every file not excluded is sent to the Docker daemon as build context. Without `.dockerignore`, `.env` files with credentials, `.git` directories with commit history, and `node_modules` directories bloating the context are all sent and potentially `COPY`ed into the image.

## Anti-Patterns

### Anti-Pattern 1: Running as Root

```dockerfile
# BAD -- no USER directive, runs as root
FROM node:22
COPY . /app
CMD ["node", "app.js"]
```

The container root user maps to root on the host (unless user namespaces are enabled, which they are not by default). A container escape as root = host root.

### Anti-Pattern 2: Using ADD for Remote Files

```dockerfile
# BAD -- ADD fetches remote URLs without verification
ADD https://example.com/app.tar.gz /app/
```

`ADD` downloads from URLs without checksum verification and auto-extracts archives, creating two attack vectors. Use `COPY` for local files and `RUN wget/curl` with checksum verification for remote files.

### Anti-Pattern 3: Secrets in Build Arguments

```dockerfile
# BAD -- ARG values are visible in docker history
ARG DATABASE_PASSWORD
RUN echo "password=$DATABASE_PASSWORD" > /app/config
```

`docker history --no-trunc` reveals all ARG values. Use BuildKit secret mounts instead.

### Anti-Pattern 4: Installing Unnecessary Packages

```dockerfile
# BAD -- vim, curl, wget, net-tools are attack tools
RUN apt-get update && apt-get install -y \
    vim curl wget net-tools telnet gcc make
```

Every package is attack surface. An attacker who achieves code execution uses these tools for reconnaissance, lateral movement, and data exfiltration. Production images should contain only runtime dependencies.

### Anti-Pattern 5: Using :latest Tag

```dockerfile
# BAD -- :latest changes under you
FROM node:latest
```

`:latest` is mutable. Your image can silently change between builds, breaking reproducibility and making vulnerability tracking impossible. Pin to a specific version (`node:22.11.0-alpine`) or, better, a digest (`node@sha256:abc123...`).

## References

- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Docker BuildKit Secrets](https://docs.docker.com/build/building/secrets/)
- [Google Distroless Images](https://github.com/GoogleContainerTools/distroless)
- [Chainguard Images](https://www.chainguard.dev/chainguard-images)
- [Hadolint -- Dockerfile Linter](https://github.com/hadolint/hadolint)
- [Dive -- Image Layer Analysis](https://github.com/wagoodman/dive)
- [Dockle -- Container Image Linter](https://github.com/goodwithtech/dockle)
