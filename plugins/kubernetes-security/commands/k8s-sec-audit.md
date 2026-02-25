# /k8s-sec-audit

> Structured audit of Kubernetes cluster security configuration.

## Trigger

Use when you need to:
- Assess the security posture of a Kubernetes cluster
- Review Kubernetes manifests, Helm charts, or Kustomize overlays before deployment
- Prepare for a CIS Kubernetes Benchmark assessment
- Evaluate a managed Kubernetes service (EKS, GKE, AKS) configuration
- Investigate cluster security after an incident or organizational change

## Input

One of:
- **Live cluster**: `kubectl` access (preferably cluster-admin for comprehensive audit, or view-only for least-privilege assessment)
- **Manifests**: Kubernetes YAML files, Helm charts, Kustomize overlays
- **kube-bench output**: Previous CIS Benchmark scan results
- **Specific scope**: Focus area (e.g., "RBAC", "network policies", "workload security")

## Process

### Phase 1: Control Plane

1. **API server configuration**
   - Authentication methods (`kubectl cluster-info`, OIDC configuration)
   - Anonymous authentication disabled
   - API server accessible from internet? (EKS: `--api-server-endpoint-access`)
   - Audit logging enabled and configured

2. **Admission controllers**
   - Pod Security Admission labels on namespaces (`kubectl get ns -o yaml`)
   - Additional admission controllers (Gatekeeper, Kyverno, OPA)
   - Webhook configurations (`kubectl get validatingwebhookconfigurations`)

3. **etcd security**
   - Encryption at rest enabled (`kubectl get secrets -n kube-system` for EncryptionConfiguration)
   - etcd access restricted (self-managed clusters)

### Phase 2: RBAC

4. **ClusterRoleBindings**
   ```bash
   kubectl get clusterrolebindings -o json | jq '.items[] | select(.roleRef.name == "cluster-admin") | .subjects'
   ```
   - `cluster-admin` bindings (should be minimal)
   - System:masters group membership
   - Anonymous user bindings

5. **Dangerous permissions**
   - Roles with `create` on `pods` (can run arbitrary code)
   - Roles with `create` on `pods/exec` (can exec into existing pods)
   - Roles with `*` on all resources
   - Roles with access to secrets across namespaces
   - Service accounts with excessive permissions

### Phase 3: Workload Security

6. **Pod Security Standards**
   ```bash
   kubectl get ns -o json | jq '.items[] | {name: .metadata.name, labels: .metadata.labels | with_entries(select(.key | startswith("pod-security")))}'
   ```
   - Namespaces without PSA labels
   - Namespaces with `privileged` profile
   - Gap between audit and enforce levels

7. **Running workloads**
   ```bash
   kubectl get pods -A -o json | jq '.items[] | select(.spec.containers[].securityContext.privileged == true) | .metadata.namespace + "/" + .metadata.name'
   ```
   - Privileged containers
   - Root containers (runAsUser: 0 or no runAsNonRoot: true)
   - Host namespace usage (hostPID, hostNetwork, hostIPC)
   - hostPath volume mounts
   - Containers without resource limits

### Phase 4: Network

8. **NetworkPolicy coverage**
   ```bash
   # Namespaces without any NetworkPolicy
   kubectl get ns -o name | while read ns; do
     count=$(kubectl get networkpolicy -n ${ns##*/} --no-headers 2>/dev/null | wc -l)
     [ "$count" -eq 0 ] && echo "$ns: NO NETWORK POLICY"
   done
   ```
   - Namespaces without NetworkPolicies (all traffic allowed)
   - Default deny policies
   - Egress policies (often missing)

9. **Service exposure**
   - Services of type LoadBalancer (internet-facing)
   - Ingress controllers and their configuration
   - NodePort services (exposed on all nodes)

### Phase 5: Secrets & Supply Chain

10. **Secrets management**
    - Encryption at rest for Kubernetes Secrets
    - Service account token auto-mounting (`automountServiceAccountToken: false`)
    - External secrets operators (Vault, external-secrets)
    - Secrets in environment variables vs mounted volumes

11. **Image security**
    - Image pull policies (`Always` for tag-based, digest-pinned)
    - Private registry authentication
    - Image scanning integration
    - Admission policies restricting image sources

## Output

```
## Kubernetes Security Audit Results

### Cluster Information
- Version: [Kubernetes version]
- Type: [Self-managed / EKS / GKE / AKS]
- Nodes: [Count and OS]
- Namespaces: [Count]
- Date: [Assessment date]

### Summary
| Category | Critical | High | Medium | Low | Pass |
|----------|----------|------|--------|-----|------|
| Control Plane |      |      |        |     |      |
| RBAC     |          |      |        |     |      |
| Workload |          |      |        |     |      |
| Network  |          |      |        |     |      |
| Secrets  |          |      |        |     |      |

### Findings (by severity)

#### Critical
[Findings with kubectl/YAML remediation]

#### High
[Findings]

### CIS Benchmark Alignment
[Key CIS controls and their status]

### Remediation Priority
1. [Immediate]
2. [High]
3. [Medium]

### Positive Findings
[Well-configured areas]
```
