# /container-audit

> Audit Dockerfiles and docker-compose/podman-compose files for security issues.

## Trigger

Use when you need to:
- Review a Dockerfile before building or deploying
- Audit a docker-compose.yml or podman-compose.yml for security misconfigurations
- Harden an existing container setup
- Prepare container configurations for a security review

## Input

One or more of:
- **Dockerfile(s)**: Any Dockerfile or Containerfile
- **Compose file(s)**: docker-compose.yml, docker-compose.prod.yml, compose.yaml
- **.dockerignore**: To check for missing exclusions
- **Specific concern**: Focus area (e.g., "secrets handling", "privilege", "networking")

## Process

### Dockerfile Audit

1. **Base image assessment**
   - Is the base image pinned to a digest? (`FROM image@sha256:...`)
   - Is the base image from a trusted source? (Official images, Chainguard, verified publishers)
   - Is the base image minimal? (distroless/Alpine/scratch preferred over ubuntu/debian full)
   - Is the base image version pinned? (`:3.19` not `:latest`)

2. **User context**
   - Does the Dockerfile include a USER directive?
   - Is the final stage running as root? (default if no USER specified)
   - Are file permissions set appropriately for the non-root user?

3. **Secret exposure**
   - Are secrets passed via ARG? (visible in image history)
   - Are secrets COPYed into the image? (persisted in layers even if deleted later)
   - Are secrets in ENV? (visible to any process in the container)
   - Is BuildKit `--mount=type=secret` used for build-time secrets?

4. **Package management**
   - Are package versions pinned? (`apk add curl=8.5.0-r0`)
   - Is the package cache cleaned? (`rm -rf /var/cache/apk/*`)
   - Are unnecessary packages installed? (build tools in runtime image)
   - Is `--no-install-recommends` used with apt-get?

5. **Build hygiene**
   - Is multi-stage build used? (separate build and runtime stages)
   - Are COPY commands specific? (not `COPY . .` without .dockerignore)
   - Is HEALTHCHECK defined?
   - Is ADD used instead of COPY? (ADD has URL and tar extraction, COPY is simpler and safer)

### Compose Audit

6. **Privilege and capabilities**
   - `privileged: true` (grants all capabilities and device access)
   - `cap_add` without corresponding `cap_drop: [ALL]`
   - `pid: host`, `network_mode: host`, `ipc: host` (break namespace isolation)

7. **Volume mounts**
   - Docker socket mount (`/var/run/docker.sock`) -- equivalent to root on host
   - Host filesystem mounts (`/etc`, `/root`, `/var`) -- potential escape path
   - Read-only mount not used where appropriate (`read_only: true`)

8. **Network security**
   - Services on default bridge network (no isolation between services)
   - Unnecessary port exposure to host (`ports` vs `expose`)
   - Internal services exposed externally

9. **Resource limits**
   - Memory limits set? (`mem_limit` / `deploy.resources.limits`)
   - CPU limits set? (prevents DoS against host)
   - PID limits set? (prevents fork bombs)

10. **Security options**
    - Seccomp profile specified? (`security_opt: [seccomp:profile.json]`)
    - AppArmor profile specified?
    - No-new-privileges set? (`security_opt: [no-new-privileges:true]`)
    - Read-only root filesystem? (`read_only: true` + `tmpfs` for writable dirs)

## Output

```
## Container Security Audit

### Files Reviewed
- [List of files audited]

### Summary
| Category | Critical | High | Medium | Low |
|----------|----------|------|--------|-----|
| Base Image |        |      |        |     |
| User Context |      |      |        |     |
| Secrets    |        |      |        |     |
| Privileges |        |      |        |     |
| Network    |        |      |        |     |
| Resources  |        |      |        |     |

### Findings

#### Critical
1. **[Finding]** -- [File:Line]
   - Risk: [What attack this enables]
   - Fix: [Specific change with before/after]

#### High
[Findings]

#### Medium
[Findings]

### Hardened Configuration
[Complete hardened Dockerfile and/or compose file]
```
