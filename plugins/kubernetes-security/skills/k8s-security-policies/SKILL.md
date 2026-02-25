# K8s Security Policies

> Pod Security Standards, NetworkPolicy patterns, admission control strategies, and workload security enforcement.

## Knowledge Base

### Pod Security Standards (PSS) -- The Three Profiles

Pod Security Standards define three progressively restrictive security profiles. These are not policies themselves -- they are standards that admission controllers enforce.

| Profile | Purpose | Restrictions |
|---------|---------|------------|
| **Privileged** | Unrestricted. For system-level workloads. | None. Everything allowed. |
| **Baseline** | Prevents known privilege escalations. Minimally restrictive. | No privileged containers, no hostPath, no hostNetwork/PID/IPC, restricted capabilities, restricted volume types, no host ports |
| **Restricted** | Heavily restricted. Best practice for untrusted workloads. | Baseline + must run as non-root, must drop ALL capabilities (may add NET_BIND_SERVICE), seccomp profile required, restricted seccomp/AppArmor profiles |

### Pod Security Admission (PSA) Controller

PSA is the built-in admission controller that enforces PSS. Three modes per namespace:

| Mode | Behavior |
|------|----------|
| `enforce` | Violations are rejected. Pod will not be created. |
| `audit` | Violations are recorded in audit log but pod is created. |
| `warn` | Violations generate a warning to the user but pod is created. |

**Best practice**: Start with `audit` + `warn`, fix violations, then switch to `enforce`.

```yaml
# Namespace labels for PSA
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/audit-version: latest
    pod-security.kubernetes.io/warn: restricted
    pod-security.kubernetes.io/warn-version: latest
```

### NetworkPolicy Fundamentals

NetworkPolicy is Kubernetes' built-in network segmentation. Key behaviors:

- **Without any NetworkPolicy**, all pods can communicate with all other pods (cluster-wide flat network).
- **Once any NetworkPolicy selects a pod** (via `podSelector`), that pod's traffic is restricted to what the policies explicitly allow.
- NetworkPolicies are **additive** -- multiple policies selecting the same pod combine their allowed traffic.
- NetworkPolicies are **namespace-scoped** but can reference other namespaces via `namespaceSelector`.
- **Egress policies are often forgotten** -- even with ingress restrictions, a compromised pod can phone home without egress controls.
- **DNS egress must be explicitly allowed** when using egress policies (UDP port 53 to kube-dns).

## Patterns

### Pattern 1: Default Deny All Traffic

```yaml
# Apply to every namespace that should have network restrictions
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}  # Selects ALL pods in namespace
  policyTypes:
    - Ingress
    - Egress
  # No ingress or egress rules = deny all
---
# Allow DNS egress (required for service discovery)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-dns
  namespace: production
spec:
  podSelector: {}
  policyTypes:
    - Egress
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

**Why this works**: Starting with default-deny forces explicit allow rules for every communication path. This is the network equivalent of dropping all capabilities and adding back only what is needed. The DNS allow is necessary because Kubernetes service discovery requires DNS resolution.

### Pattern 2: Microservice Communication Policy

```yaml
# Frontend can talk to API
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-ingress-from-frontend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: frontend
      ports:
        - protocol: TCP
          port: 8080
---
# API can talk to database
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: db-ingress-from-api
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: database
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: api
      ports:
        - protocol: TCP
          port: 5432
---
# API egress to database and external APIs
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-egress
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Egress
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: database
      ports:
        - protocol: TCP
          port: 5432
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - 10.0.0.0/8
              - 172.16.0.0/12
              - 192.168.0.0/16
      ports:
        - protocol: TCP
          port: 443
```

**Why this works**: Each policy explicitly defines which pods can communicate, on which ports, in which direction. The API egress policy allows database access and external HTTPS, but excludes private IP ranges (preventing lateral movement to internal services not explicitly allowed).

### Pattern 3: Pod Security Context (Restricted Profile Compliant)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        runAsGroup: 1001
        fsGroup: 1001
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: app
          image: myapp:v1.2.3@sha256:abc123...
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
          resources:
            requests:
              memory: "128Mi"
              cpu: "100m"
            limits:
              memory: "256Mi"
              cpu: "500m"
          ports:
            - containerPort: 8080
              protocol: TCP
          volumeMounts:
            - name: tmp
              mountPath: /tmp
            - name: cache
              mountPath: /app/cache
      volumes:
        - name: tmp
          emptyDir:
            sizeLimit: 64Mi
        - name: cache
          emptyDir:
            sizeLimit: 128Mi
```

**Why this works**: This manifest complies with the PSS Restricted profile. Non-root user, all capabilities dropped, privilege escalation blocked, read-only root filesystem (with emptyDir for writable paths), seccomp enabled, resource limits set, service account token not mounted, and image pinned by digest.

### Pattern 4: Kyverno Policy -- Require Labels

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-labels
  annotations:
    policies.kyverno.io/title: Require Labels
    policies.kyverno.io/severity: medium
spec:
  validationFailureAction: Enforce
  background: true
  rules:
    - name: require-team-label
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - StatefulSet
                - DaemonSet
      validate:
        message: "The label 'team' is required."
        pattern:
          metadata:
            labels:
              team: "?*"
    - name: require-app-label
      match:
        any:
          - resources:
              kinds:
                - Deployment
                - StatefulSet
                - DaemonSet
      validate:
        message: "The label 'app' is required for NetworkPolicy targeting."
        pattern:
          spec:
            template:
              metadata:
                labels:
                  app: "?*"
```

**Why this works**: Labels are the foundation of NetworkPolicy targeting and RBAC scoping in Kubernetes. Requiring `team` and `app` labels ensures every workload can be targeted by network policies and attributed to an owner.

## Anti-Patterns

### Anti-Pattern 1: No NetworkPolicy

Without any NetworkPolicy, every pod can communicate with every other pod on every port. A compromised frontend can directly access the database, exfiltrate data to external servers, and scan internal services.

### Anti-Pattern 2: Privileged Containers Without Justification

`privileged: true` disables all container isolation. Only a few workloads legitimately need this (CNI plugins, CSI drivers, node monitoring agents). Application containers should never be privileged.

### Anti-Pattern 3: PSA Set to "Privileged"

Setting `pod-security.kubernetes.io/enforce: privileged` on application namespaces effectively disables Pod Security Standards. It should only be used for `kube-system` and infrastructure namespaces.

### Anti-Pattern 4: Ingress-Only NetworkPolicy

Protecting ingress without controlling egress leaves data exfiltration wide open. Always implement both ingress and egress policies.

### Anti-Pattern 5: Using hostPath Volumes

`hostPath` volumes mount host directories into containers, bypassing namespace isolation. A pod with `hostPath: {path: "/"}` has access to the entire host filesystem. Use PersistentVolumeClaims instead.

## References

- [Pod Security Standards](https://kubernetes.io/docs/concepts/security/pod-security-standards/)
- [Pod Security Admission](https://kubernetes.io/docs/concepts/security/pod-security-admission/)
- [NetworkPolicy Documentation](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
- [Kyverno Documentation](https://kyverno.io/docs/)
- [OPA Gatekeeper](https://open-policy-agent.github.io/gatekeeper/)
- [NSA/CISA Kubernetes Hardening Guide](https://media.defense.gov/2022/Aug/29/2003066362/-1/-1/0/CTR_KUBERNETES_HARDENING_GUIDANCE_1.2_20220829.PDF)
- [NetworkPolicy Editor (Cilium)](https://editor.networkpolicy.io/)
