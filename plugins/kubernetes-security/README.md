# Kubernetes Security

> Cluster hardening, RBAC design, Pod Security Standards, network policies, and admission control for Kubernetes environments.

---

## Overview

Kubernetes is a distributed system that orchestrates containers across many nodes. Its security model is fundamentally different from securing individual containers because it introduces cluster-level primitives: the API server as a central control plane, RBAC for authorization, admission controllers as gatekeepers, and network policies for pod-to-pod communication. Every one of these layers must be configured correctly -- Kubernetes defaults are permissive, optimized for ease of getting started rather than security.

The most common Kubernetes security failures are not sophisticated attacks. They are misconfigurations: overly permissive RBAC, no network policies (so every pod can talk to every other pod), no Pod Security Standards (so pods run as root with full capabilities), and exposed API servers. This plugin provides agents, commands, and knowledge bases to systematically identify and remediate these gaps.

---

## Contents

### Agents

| Agent | File | Purpose |
|-------|------|---------|
| K8s Security Architect | `agents/k8s-security-architect.md` | Reviews and designs secure cluster architecture, node security, API server hardening, and multi-tenancy |
| K8s Policy Enforcer | `agents/k8s-policy-enforcer.md` | Designs and reviews admission policies, Pod Security Standards, OPA/Gatekeeper policies, and Kyverno rules |

### Commands

| Command | File | Purpose |
|---------|------|---------|
| `/k8s-sec-audit` | `commands/k8s-sec-audit.md` | Structured audit of Kubernetes cluster security configuration |
| `/k8s-rbac-audit` | `commands/k8s-rbac-audit.md` | Focused audit of Kubernetes RBAC configuration |

### Skills (Knowledge Bases)

| Skill | Directory | Purpose |
|-------|-----------|---------|
| K8s Security Policies | `skills/k8s-security-policies/` | Pod Security Standards, NetworkPolicy patterns, and admission control |
| K8s RBAC Patterns | `skills/k8s-rbac-patterns/` | RBAC design patterns, least-privilege roles, and common misconfigurations |

---

## Usage

### Cluster Audit

Use `/k8s-sec-audit` for a comprehensive review of cluster security. Works with live `kubectl` access, Kubernetes manifests, Helm charts, or Kustomize overlays.

### RBAC Review

Use `/k8s-rbac-audit` for a focused review of RBAC configuration. Identifies overly permissive roles, dangerous ClusterRole bindings, and privilege escalation paths.

### Architecture Review

Activate `k8s-security-architect` when designing new clusters, evaluating managed Kubernetes offerings (EKS, GKE, AKS), or reviewing multi-tenant architectures.

### Policy Design

Activate `k8s-policy-enforcer` when implementing Pod Security Standards, designing OPA/Gatekeeper constraints, or creating Kyverno policies.

---

## Key Principles

1. **Kubernetes defaults are insecure.** Default RBAC is permissive, default network allows all pod-to-pod traffic, default pod security allows root and privileged containers.
2. **The API server is the crown jewel.** Every operation flows through the API server. Secure it with authentication, authorization (RBAC), admission control, audit logging, and network restrictions.
3. **RBAC is your primary authorization control.** Poorly designed RBAC is the most common path to cluster compromise. Audit it regularly.
4. **Network policies are your east-west firewall.** Without them, any compromised pod can communicate with every other pod and every service.
5. **Pod Security Standards are mandatory.** PSS/PSA replaced PodSecurityPolicy. Every namespace must have a security standard (baseline or restricted).

---

## Prerequisites

- `kubectl` configured with appropriate cluster access
- Familiarity with Kubernetes concepts (pods, deployments, services, namespaces, RBAC)
- For policy enforcement: familiarity with OPA/Gatekeeper, Kyverno, or the built-in Pod Security Admission controller

---

## Related Plugins

| Plugin | Relationship |
|--------|-------------|
| `container-security` | Image-level security (Dockerfile hardening, vulnerability scanning) |
| `network-security` | Network-level security concepts that underpin NetworkPolicy |
| `identity-access-management` | Access control models (RBAC theory) that apply to K8s RBAC |
| `cloud-security-aws` | EKS-specific security (IRSA, cluster endpoint access) |
| `cloud-security-gcp` | GKE-specific security (Workload Identity, Binary Authorization) |
| `cloud-security-azure` | AKS-specific security (Entra ID integration, Azure Policy) |

---

## References

- [CIS Kubernetes Benchmark](https://www.cisecurity.org/benchmark/kubernetes)
- [Kubernetes Security Documentation](https://kubernetes.io/docs/concepts/security/)
- [NSA/CISA Kubernetes Hardening Guide](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [MITRE ATT&CK Containers Matrix](https://attack.mitre.org/matrices/enterprise/containers/)
- [Kubernetes RBAC Good Practices](https://kubernetes.io/docs/concepts/security/rbac-good-practices/)
- [kube-bench -- CIS Benchmark Checker](https://github.com/aquasecurity/kube-bench)
- [kubeaudit -- Cluster Auditing](https://github.com/Shopify/kubeaudit)
