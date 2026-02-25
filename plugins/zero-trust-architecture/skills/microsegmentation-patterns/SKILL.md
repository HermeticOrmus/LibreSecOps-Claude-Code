# Microsegmentation Patterns

> Implementation approaches for network, application, and identity-based microsegmentation across on-premises and cloud environments.

## Knowledge Base

### Segmentation Levels

Microsegmentation operates at multiple layers, each providing different granularity and capabilities:

**Layer 3/4 (Network)**: IP addresses, ports, protocols. The most basic form. Implemented via firewalls, security groups, VLANs, and Kubernetes NetworkPolicy. Limitation: IP addresses are not stable identities in dynamic environments (containers, autoscaling).

**Layer 7 (Application)**: HTTP methods, paths, headers, gRPC services. Implemented via service mesh (Istio, Linkerd), application-aware firewalls, and API gateways. Provides much finer control but requires deeper infrastructure integration.

**Identity-based**: Cryptographic workload identity (SPIFFE/SPIRE, mTLS certificates). Communication is authorized based on verified identity, not network location. The most robust form -- works across clusters, clouds, and hybrid environments.

### Default Deny vs. Default Allow

**Default deny** (target state): All traffic is blocked unless explicitly allowed. This is the zero trust ideal. In practice, it requires a complete communication matrix before enforcement.

**Default allow with logging** (starting state): All traffic is allowed but logged. Use this phase to discover communication patterns, build the allowlist, and then transition to default deny.

**The transition process**:
1. Deploy in logging/audit mode (default allow, log everything)
2. Analyze traffic patterns for 2-4 weeks
3. Build communication matrix from observed traffic
4. Create explicit allow policies for legitimate traffic
5. Switch to default deny with allow policies
6. Monitor for breakage, adjust policies
7. Iterate per segment/namespace/tier

## Patterns

### Pattern 1: Kubernetes NetworkPolicy (L3/L4)

```yaml
# Default deny all ingress and egress in a namespace
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
  namespace: production
spec:
  podSelector: {}  # Applies to all pods in namespace
  policyTypes:
    - Ingress
    - Egress

---
# Allow frontend to talk to backend API on port 8080
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend-to-backend
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: backend-api
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
# Allow backend API to reach database on port 5432
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-backend-to-database
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
              app: backend-api
      ports:
        - protocol: TCP
          port: 5432

---
# Allow all pods to reach DNS (required for service discovery)
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
        - namespaceSelector: {}
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53
```

### Pattern 2: Cilium Network Policy (L3/L4/L7 with eBPF)

Cilium extends Kubernetes NetworkPolicy with L7 awareness and DNS-based policies:

```yaml
# L7-aware policy: allow only GET and POST to specific API paths
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: api-granular-access
  namespace: production
spec:
  endpointSelector:
    matchLabels:
      app: backend-api
  ingress:
    - fromEndpoints:
        - matchLabels:
            app: frontend
      toPorts:
        - ports:
            - port: "8080"
              protocol: TCP
          rules:
            http:
              - method: "GET"
                path: "/api/v1/products.*"
              - method: "POST"
                path: "/api/v1/orders"
                headers:
                  - 'Content-Type: application/json'

---
# DNS-based egress policy: allow only specific external domains
apiVersion: cilium.io/v2
kind: CiliumNetworkPolicy
metadata:
  name: egress-external-apis
  namespace: production
spec:
  endpointSelector:
    matchLabels:
      app: payment-processor
  egress:
    - toFQDNs:
        - matchName: "api.stripe.com"
        - matchName: "api.twilio.com"
      toPorts:
        - ports:
            - port: "443"
              protocol: TCP
    # Allow DNS lookups
    - toEndpoints:
        - matchLabels:
            k8s:io.kubernetes.pod.namespace: kube-system
            k8s-app: kube-dns
      toPorts:
        - ports:
            - port: "53"
              protocol: ANY
```

### Pattern 3: Istio Service Mesh Authorization (L7 + Identity)

```yaml
# Strict mTLS everywhere in the mesh
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: strict-mtls
  namespace: istio-system  # Mesh-wide
spec:
  mtls:
    mode: STRICT

---
# Authorization: only checkout-service can call payment-service
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: payment-service-authz
  namespace: production
spec:
  selector:
    matchLabels:
      app: payment-service
  action: ALLOW
  rules:
    - from:
        - source:
            principals:
              - "cluster.local/ns/production/sa/checkout-service"
      to:
        - operation:
            methods: ["POST"]
            paths: ["/api/v1/charge", "/api/v1/refund"]
      when:
        - key: request.headers[x-request-id]
          notValues: [""]  # Require tracing header

---
# Default deny for the namespace
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: deny-all
  namespace: production
spec:
  {}  # Empty spec = deny all
```

### Pattern 4: AWS Security Group Microsegmentation

```hcl
# Terraform: Microsegmentation with AWS Security Groups

# Web tier -- accepts traffic from ALB only
resource "aws_security_group" "web_tier" {
  name_prefix = "web-tier-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "HTTPS from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description     = "To app tier only"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }

  tags = { Name = "web-tier", Tier = "frontend" }
}

# App tier -- accepts from web tier, talks to database tier
resource "aws_security_group" "app_tier" {
  name_prefix = "app-tier-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From web tier"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_tier.id]
  }

  egress {
    description     = "To database tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db_tier.id]
  }

  egress {
    description     = "To cache tier"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.cache_tier.id]
  }

  tags = { Name = "app-tier", Tier = "application" }
}

# Database tier -- accepts from app tier only, no egress
resource "aws_security_group" "db_tier" {
  name_prefix = "db-tier-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From app tier"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_tier.id]
  }

  # No egress rules -- database should not initiate outbound connections

  tags = { Name = "db-tier", Tier = "data" }
}
```

### Pattern 5: PCI DSS Cardholder Data Environment Isolation

```
Network Segmentation for PCI DSS Requirement 1:

     Internet
        |
   [WAF / CDN]
        |
   +---------+
   | DMZ     |  Web servers (no cardholder data)
   +---------+
        |
   [Firewall -- L7 inspection, IDS/IPS]
        |
   +---------+
   | App Tier|  Application servers (process cardholder data)
   +---------+
        |
   [Firewall -- strict allow-list]
        |
   +---------+
   | CDE     |  Cardholder Data Environment
   | (PCI)   |  - Payment processors
   |         |  - Card databases (encrypted, tokenized)
   |         |  - HSMs for key management
   +---------+

Segmentation validation:
- Penetration test must confirm CDE is isolated
- No direct path from DMZ to CDE
- All CDE access logged and monitored
- Quarterly network scan of CDE perimeter
```

## Anti-Patterns

- **IP-based policies in dynamic environments**: In Kubernetes, containers get new IPs constantly. Security group rules based on IP addresses break with autoscaling. Use label-based or identity-based policies.
- **Segmentation without visibility**: Deploying default-deny without first understanding traffic patterns breaks applications. Always start in audit mode.
- **Forgetting operations traffic**: Blocking monitoring (Prometheus scraping), logging (Fluentd forwarding), CI/CD (deployment agents), and DNS causes cascading failures. Include operations in the communication matrix.
- **Overly granular policies from day one**: Starting with per-endpoint, per-method L7 policies before understanding the application's communication patterns leads to constant policy exceptions. Start with L3/L4 service-to-service policies, then refine to L7.
- **Not testing segmentation**: Segmentation policies are code. Test them. Use network policy simulation tools, connectivity checks, and chaos engineering to verify they work as intended.
- **Assuming cloud security groups are microsegmentation**: Security groups provide coarse segmentation. True microsegmentation requires workload-level policies, often implemented via service mesh or eBPF-based solutions.

## References

- Kubernetes NetworkPolicy Documentation: https://kubernetes.io/docs/concepts/services-networking/network-policies/
- Cilium Network Policy Documentation: https://docs.cilium.io/en/stable/security/policy/
- Istio Authorization Policy: https://istio.io/latest/docs/reference/config/security/authorization-policy/
- NIST SP 800-207 (Zero Trust Architecture): https://csrc.nist.gov/publications/detail/sp/800-207/final
- PCI DSS v4.0 Requirement 1: https://www.pcisecuritystandards.org/
- AWS VPC Security Best Practices: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-security-best-practices.html
