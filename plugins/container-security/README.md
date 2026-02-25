# Container Security

> Defensive security patterns for Docker/Podman containers, image hardening, vulnerability scanning, and runtime isolation.

---

## Overview

Containers provide process isolation, not security isolation. This is the fundamental misconception that leads to most container security breaches. A container shares the host kernel, and without deliberate hardening, a container escape gives an attacker full host access -- and from there, access to every other container on the host.

This plugin covers the full container security lifecycle: building secure images (shift-left), scanning for vulnerabilities before deployment, hardening runtime configuration, and detecting anomalous behavior. The focus is on Docker and Podman, but the principles apply to any OCI-compatible container runtime.

Container security is not a single layer -- it is the intersection of image supply chain security, build-time hardening, runtime isolation, and orchestration-level controls. This plugin handles the first three; see the `kubernetes-security` plugin for orchestration-level security.

---

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| Container Hardener | `agents/container-hardener.md` | Reviews and hardens Dockerfiles, compose files, and container runtime configurations |
| Image Scanner | `agents/image-scanner.md` | Scans container images for vulnerabilities, misconfigurations, and supply chain risks |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/container-audit` | `commands/container-audit.md` | Audit Dockerfiles and docker-compose/podman-compose files for security issues |
| `/image-scan` | `commands/image-scan.md` | Scan container images for vulnerabilities and misconfigurations |

### Skills (Knowledge Bases)

| Skill | Directory | Purpose |
|-------|-----------|---------|
| Dockerfile Hardening | `skills/dockerfile-hardening/` | Secure Dockerfile patterns, multi-stage builds, minimal base images, and build-time security |
| Container Runtime Security | `skills/container-runtime-security/` | Runtime isolation mechanisms, seccomp, AppArmor, capabilities, and namespace configuration |

---

## Usage

### Dockerfile Review

Use `/container-audit` to review Dockerfiles and compose files for security issues. It checks for running as root, unnecessary capabilities, exposed secrets, insecure base images, and hardening omissions.

### Vulnerability Scanning

Use `/image-scan` to analyze container images for known CVEs, misconfigured packages, and supply chain risks. It guides you through using Trivy, Grype, or Syft for SBOM generation.

### Hardening Guidance

Activate `container-hardener` when building new container images or reviewing existing ones. It provides specific, actionable hardening recommendations.

### Supply Chain Analysis

Activate `image-scanner` when you need to evaluate the provenance and integrity of container images in your registry, including base image selection, layer analysis, and dependency assessment.

---

## Key Principles

1. **Containers are not VMs.** They share the host kernel. A kernel exploit in any container compromises the host and every other container.
2. **Minimal images, minimal attack surface.** Every package in the image is a potential vulnerability. Use distroless, Alpine, or scratch bases.
3. **Never run as root.** The container root user is the host root user (unless user namespaces are configured). Always use a non-root USER directive.
4. **Images are immutable artifacts.** Build once, scan once, deploy many. Never install packages or patch at runtime.
5. **Trust but verify the supply chain.** Pin base image digests, verify signatures, and generate SBOMs. Know what is in your images.

---

## Prerequisites

- Docker or Podman installed
- Trivy, Grype, or Snyk CLI for vulnerability scanning
- Access to Dockerfiles and/or container images to audit

---

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `kubernetes-security` | Orchestration-level security (Pod Security Standards, NetworkPolicy, RBAC) |
| `supply-chain-security` | Broader supply chain security including image signing, SBOM, SLSA |
| `devsecops-pipelines` | CI/CD pipeline integration for automated container scanning |
| `cloud-security-aws` | ECS, EKS, and Fargate container security |
| `cloud-security-gcp` | GKE and Cloud Run container security |
| `cloud-security-azure` | AKS and Azure Container Instances security |

---

## References

- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [NIST SP 800-190: Application Container Security Guide](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [Docker Security Documentation](https://docs.docker.com/engine/security/)
- [Sysdig Container Security Guide](https://sysdig.com/learn-cloud-native/container-security/)
- [Trivy -- Container Vulnerability Scanner](https://github.com/aquasecurity/trivy)
