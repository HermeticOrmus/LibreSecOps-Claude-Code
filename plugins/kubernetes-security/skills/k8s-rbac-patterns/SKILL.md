# K8s RBAC Patterns

> RBAC design patterns, least-privilege role definitions, common misconfigurations, and privilege escalation prevention.

## Knowledge Base

### RBAC Object Model

Kubernetes RBAC uses four object types:

| Object | Scope | Purpose |
|--------|-------|---------|
| **Role** | Namespace | Defines permissions within a single namespace |
| **ClusterRole** | Cluster-wide | Defines permissions across all namespaces or for cluster-scoped resources |
| **RoleBinding** | Namespace | Binds a Role OR ClusterRole to subjects within a namespace |
| **ClusterRoleBinding** | Cluster-wide | Binds a ClusterRole to subjects across all namespaces |

**Critical distinction**: A ClusterRole bound with a RoleBinding is scoped to that namespace. The same ClusterRole bound with a ClusterRoleBinding applies cluster-wide. This is how you create reusable role definitions with namespace-scoped grants.

### RBAC Evaluation Logic

1. All RBAC rules are **additive** -- there is no deny rule in Kubernetes RBAC
2. If no rule grants access, the request is **denied by default**
3. Rules are evaluated by the API server at request time
4. `system:masters` group bypasses RBAC entirely (built into the API server)
5. The `escalate` and `bind` verbs control whether a user can create roles more powerful than their own

### Privilege Escalation Through RBAC

These permissions enable RBAC-based privilege escalation:

| Permission | Escalation Path |
|-----------|----------------|
| `create pods` | Create a pod with any service account, mounting secrets, using hostPath |
| `create pods/exec` | Exec into a pod running with a more-privileged service account |
| `create serviceaccounts` + `create rolebindings` | Create a SA and bind cluster-admin to it |
| `escalate` on roles | Create or modify roles to have more permissions than you have |
| `bind` on roles | Bind any role (including cluster-admin) to any subject |
| `impersonate` | Act as any user, group, or service account |
| `create secrets` | Create a service account token secret for any SA |
| `patch nodes` | Modify node labels to bypass scheduling constraints |

## Patterns

### Pattern 1: Application Developer Role (Namespace-Scoped)

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: app-developer
rules:
  # Workload management
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets", "statefulsets"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  # Do NOT grant delete on deployments (use rollback instead)

  # Pod debugging (read-only + logs + exec)
  - apiGroups: [""]
    resources: ["pods"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get"]
  - apiGroups: [""]
    resources: ["pods/exec"]
    verbs: ["create"]
    # Consider: exec enables command execution as the pod's SA

  # Config and secrets (limited)
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
  - apiGroups: [""]
    resources: ["secrets"]
    verbs: ["get", "list"]
    # Note: no create/update on secrets -- handled by CI/CD or secrets operator

  # Services
  - apiGroups: [""]
    resources: ["services"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]

  # HPA
  - apiGroups: ["autoscaling"]
    resources: ["horizontalpodautoscalers"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]

  # Events (read-only for debugging)
  - apiGroups: [""]
    resources: ["events"]
    verbs: ["get", "list", "watch"]
---
# Bind to a specific namespace
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: dev-team-app-developer
  namespace: team-alpha
subjects:
  - kind: Group
    name: team-alpha-devs
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: app-developer
  apiGroup: rbac.authorization.k8s.io
```

**Why this works**: Developers can manage their workloads, debug pods, and update configs, but cannot create secrets, delete deployments (preventing accidental destruction), access other namespaces, or modify RBAC. The ClusterRole is reusable across namespaces via RoleBindings.

### Pattern 2: CI/CD Service Account (Minimal Deploy Permissions)

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: cicd-deployer
  namespace: production
  annotations:
    description: "CI/CD pipeline deployment account"
automountServiceAccountToken: false
---
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: cicd-deployer-role
  namespace: production
rules:
  # Only update existing deployments (cannot create new ones)
  - apiGroups: ["apps"]
    resources: ["deployments"]
    verbs: ["get", "list", "patch"]
    resourceNames: ["api-server", "worker", "frontend"]
    # resourceNames restricts to specific named resources

  # Can update configmaps for deployment configs
  - apiGroups: [""]
    resources: ["configmaps"]
    verbs: ["get", "update", "patch"]
    resourceNames: ["api-config", "worker-config", "frontend-config"]

  # Can view rollout status
  - apiGroups: ["apps"]
    resources: ["deployments/status", "replicasets"]
    verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: cicd-deployer-binding
  namespace: production
subjects:
  - kind: ServiceAccount
    name: cicd-deployer
    namespace: production
roleRef:
  kind: Role
  name: cicd-deployer-role
  apiGroup: rbac.authorization.k8s.io
```

**Why this works**: The `resourceNames` field restricts access to specific, named resources. The CI/CD pipeline can only update the exact deployments and configmaps it manages -- not create new ones, not access secrets, not modify RBAC. This is the tightest practical RBAC for a deployment pipeline.

### Pattern 3: Read-Only Monitoring Role

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-reader
rules:
  - apiGroups: [""]
    resources: ["pods", "services", "endpoints", "nodes", "namespaces"]
    verbs: ["get", "list", "watch"]
  - apiGroups: ["apps"]
    resources: ["deployments", "replicasets", "statefulsets", "daemonsets"]
    verbs: ["get", "list", "watch"]
  - apiGroups: [""]
    resources: ["pods/log"]
    verbs: ["get"]
  - apiGroups: ["metrics.k8s.io"]
    resources: ["pods", "nodes"]
    verbs: ["get", "list"]
  # Explicitly NOT including: secrets, configmaps, exec, RBAC objects
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: monitoring-reader-binding
subjects:
  - kind: ServiceAccount
    name: prometheus
    namespace: monitoring
roleRef:
  kind: ClusterRole
  name: monitoring-reader
  apiGroup: rbac.authorization.k8s.io
```

**Why this works**: Monitoring tools need broad read access but should never have write access or access to sensitive objects. This role provides visibility into workload state and metrics without exposing secrets, RBAC configurations, or exec capabilities.

### Pattern 4: Emergency Break-Glass ClusterRoleBinding

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: emergency-break-glass
  annotations:
    purpose: "Emergency access only. Usage is monitored and audited."
    contact: "security-team@company.com"
subjects:
  - kind: Group
    name: emergency-responders
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

Paired with audit logging that specifically watches for this group:

```yaml
# Audit policy to log all emergency-responder actions
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
  - level: RequestResponse
    users: []
    userGroups: ["emergency-responders"]
    resources:
      - group: ""
        resources: ["*"]
```

**Why this works**: Emergency access to cluster-admin must exist (you cannot lock yourself out), but it must be audited at the highest level. The group membership should be managed via your identity provider (not directly in Kubernetes), and usage should trigger immediate security team alerts.

## Anti-Patterns

### Anti-Pattern 1: Using Default Service Accounts

Every namespace has a `default` service account. If you do not create explicit service accounts for your workloads, all pods use `default`. If anyone grants permissions to `default`, all pods in the namespace inherit them.

**Fix**: Create dedicated service accounts per workload. Set `automountServiceAccountToken: false` on the `default` service account and on pods that do not need API access.

### Anti-Pattern 2: ClusterRoleBinding Instead of RoleBinding

Binding a ClusterRole with a ClusterRoleBinding grants permissions across ALL namespaces. Most applications only need access to their own namespace.

**Fix**: Use RoleBinding to bind ClusterRoles to specific namespaces. Reserve ClusterRoleBindings for cluster-wide roles (monitoring, node management, emergency access).

### Anti-Pattern 3: Wildcard Verbs or Resources

```yaml
# BAD
rules:
  - apiGroups: ["*"]
    resources: ["*"]
    verbs: ["*"]
```

This is cluster-admin in disguise. Even `["get", "list", "watch"]` on `["*"]` exposes all secrets in all namespaces.

**Fix**: Enumerate the exact apiGroups, resources, and verbs needed. Use `resourceNames` where possible.

### Anti-Pattern 4: Granting RBAC Management Permissions

```yaml
# BAD -- allows self-escalation
rules:
  - apiGroups: ["rbac.authorization.k8s.io"]
    resources: ["roles", "rolebindings", "clusterroles", "clusterrolebindings"]
    verbs: ["create", "update", "patch"]
```

Any user with these permissions can create a RoleBinding that grants themselves cluster-admin (or any other role). The `escalate` verb was introduced to prevent this, but many clusters do not have the `ValidatingAdmissionPolicy` or webhook to enforce it.

**Fix**: RBAC management should be restricted to platform administrators and CI/CD pipelines with specific, audited access.

### Anti-Pattern 5: Not Auditing RBAC Changes

RBAC changes are high-impact, low-frequency events. If you are not logging and alerting on RBAC modifications, an attacker can grant themselves persistent access without detection.

**Fix**: Configure audit policy to log all RBAC changes at `RequestResponse` level. Alert on any creation or modification of ClusterRoleBindings, especially those referencing `cluster-admin`.

## References

- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Kubernetes RBAC Good Practices](https://kubernetes.io/docs/concepts/security/rbac-good-practices/)
- [KubiScan -- RBAC Risk Scanner](https://github.com/cyberark/KubiScan)
- [kubectl-who-can](https://github.com/aquasecurity/kubectl-who-can)
- [rbac-tool](https://github.com/alcideio/rbac-tool)
- [CIS Kubernetes Benchmark -- RBAC Controls](https://www.cisecurity.org/benchmark/kubernetes)
- [Kubernetes Security Audit (Trail of Bits)](https://github.com/trailofbits/audit-kubernetes)
