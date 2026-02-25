# /k8s-rbac-audit

> Focused audit of Kubernetes RBAC configuration, identifying overly permissive roles and privilege escalation paths.

## Trigger

Use when you need to:
- Audit who has access to what in a Kubernetes cluster
- Identify overly permissive roles and role bindings
- Find privilege escalation paths through RBAC
- Review RBAC after organizational changes (team restructuring, offboarding)
- Prepare for a security review focused on access control

## Input

One of:
- **Live cluster**: `kubectl` access with RBAC read permissions
- **RBAC manifests**: Role, ClusterRole, RoleBinding, ClusterRoleBinding YAML files
- **Helm charts**: Charts defining RBAC resources
- **Specific scope**: Focus on a namespace, team, or service account

## Process

### Phase 1: Cluster-Level RBAC

1. **cluster-admin bindings**
   ```bash
   kubectl get clusterrolebindings -o json | jq -r '
     .items[] |
     select(.roleRef.name == "cluster-admin") |
     "Binding: \(.metadata.name)\nSubjects: \(.subjects | map(.kind + ":" + .name) | join(", "))\n"'
   ```
   - Every cluster-admin binding (should be minimal -- operators, break-glass only)
   - system:masters group members (equivalent to cluster-admin, cannot be restricted by RBAC)

2. **Overprivileged ClusterRoles**
   ```bash
   kubectl get clusterroles -o json | jq -r '
     .items[] |
     select(.rules[]? | .resources[]? == "*" and .verbs[]? == "*") |
     .metadata.name'
   ```
   - ClusterRoles with `*` on all resources and all verbs
   - ClusterRoles with `create` on `pods` or `deployments` (code execution)
   - ClusterRoles with access to `secrets` across all namespaces

3. **Dangerous permission combinations**
   - `create pods` + `get secrets` = create a pod that mounts any secret
   - `create pods` + `create serviceaccounts` + `create rolebindings` = escalate to any role
   - `patch nodes` = modify node labels to bypass nodeSelector constraints
   - `impersonate users/groups` = act as any user
   - `escalate` on roles = create roles with more permissions than you have
   - `bind` on roles = bind any role to any subject

### Phase 2: Namespace-Level RBAC

4. **Service account permissions**
   ```bash
   # For each namespace, check what the default service account can do
   kubectl auth can-i --list --as=system:serviceaccount:NAMESPACE:default -n NAMESPACE
   ```
   - Default service accounts with non-default permissions
   - Service accounts with cluster-wide permissions (via ClusterRoleBindings)
   - Service accounts not used by any pod (orphaned)

5. **Role analysis per namespace**
   ```bash
   kubectl get rolebindings -A -o json | jq -r '
     .items[] |
     "\(.metadata.namespace)/\(.metadata.name) -> \(.roleRef.kind)/\(.roleRef.name) | Subjects: \(.subjects // [] | map(.kind + ":" + .name) | join(", "))"'
   ```
   - Roles granting excessive permissions within namespace
   - Cross-namespace access patterns
   - Users/groups with permissions they no longer need

### Phase 3: Service Account Token Analysis

6. **Token auto-mounting**
   ```bash
   kubectl get pods -A -o json | jq -r '
     .items[] |
     select(.spec.automountServiceAccountToken != false) |
     "\(.metadata.namespace)/\(.metadata.name): automount=true, SA=\(.spec.serviceAccountName // "default")"'
   ```
   - Pods auto-mounting service account tokens unnecessarily
   - Tokens projected with audience restrictions vs legacy tokens
   - Service accounts with long-lived tokens (pre-1.24 secrets)

### Phase 4: Privilege Escalation Paths

7. **Escalation analysis**
   - Can any non-admin create pods? (pod creation = code execution with the pod's SA permissions)
   - Can any SA create other SAs or rolebindings? (self-escalation)
   - Can any SA exec into pods in other namespaces? (lateral movement)
   - Can any SA read secrets in other namespaces? (credential theft)
   - Can any SA access the kubelet API? (node-level access)

## Output

```
## Kubernetes RBAC Audit Results

### Cluster
- Version: [Version]
- Total ClusterRoles: [Count]
- Total ClusterRoleBindings: [Count]
- Total Roles: [Count across all namespaces]
- Total RoleBindings: [Count]
- Total ServiceAccounts: [Count]

### cluster-admin Access
| Subject Type | Subject Name | Binding | Justification |
|-------------|-------------|---------|---------------|
| User | admin@corp.com | cluster-admin-binding | [Justified/Unjustified] |
| Group | system:masters | [built-in] | [Justified/Unjustified] |
| ServiceAccount | kube-system/default | [binding name] | [Justified/Unjustified] |

### Dangerous Permissions
1. **[Subject]** has **[Permission]** via **[Role/Binding]**
   - Risk: [Escalation path]
   - Remediation: [Specific RBAC change]

### Privilege Escalation Paths
1. **[Source] -> [Target]**: [Description of escalation]
   - Via: [RBAC objects involved]
   - Impact: [What the attacker gains]

### Service Account Issues
[Auto-mount findings, excessive permissions, orphaned SAs]

### Recommendations
1. [Remove unnecessary cluster-admin bindings]
2. [Restrict service account permissions]
3. [Disable token auto-mounting where not needed]
4. [Implement RBAC review process]

### RBAC Health Score
- cluster-admin bindings: [Count] (target: <= 3)
- Wildcard ClusterRoles: [Count] (target: 0 custom)
- Namespaces with default SA permissions: [Count] (target: 0)
- Pods with unnecessary token mounts: [Count] (target: 0)
```
