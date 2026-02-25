# Network Segmentation

> Segmentation strategies, trust zone design, micro-segmentation, and lateral movement prevention.

## Knowledge Base

### Why Segmentation Matters

In a flat network (no segmentation), compromising any single host gives an attacker direct network access to every other host. Lateral movement is trivial -- the attacker can reach databases, admin panels, and other servers directly from the compromised host.

Segmentation creates boundaries that an attacker must cross. Each boundary is an opportunity for detection and prevention. The goal is to limit the blast radius of any single compromise.

### Segmentation Models

| Model | Granularity | Implementation | Use Case |
|-------|-------------|----------------|----------|
| **Perimeter** | Network edge only | Edge firewall | Legacy, insufficient alone |
| **Zone-based** | Trust zones (DMZ, Internal, DB) | Firewalls between zones | Traditional enterprise |
| **VLAN-based** | Per functional group | 802.1Q VLANs + ACLs | Network-level isolation |
| **Micro-segmentation** | Per workload/application | Host firewalls, SDN, service mesh | Modern data center, cloud |
| **Zero Trust** | Per request | Identity-aware proxy, mTLS, BeyondCorp | Cloud-native, remote workforce |

### Trust Zones (Classic Enterprise)

```
                    ┌─────────────────────────────────┐
   Internet ──────► │         DMZ (Untrusted)          │
                    │   Web servers, reverse proxies    │
                    └──────────────┬──────────────────┘
                                   │ Port 8080 only
                    ┌──────────────▼──────────────────┐
                    │       Application Zone           │
                    │   App servers, API gateways       │
                    └──────────────┬──────────────────┘
                                   │ Port 5432 only
                    ┌──────────────▼──────────────────┐
                    │        Database Zone             │
                    │   Databases, caches              │
                    └──────────────┬──────────────────┘
                                   │ (No outbound)
                    ┌──────────────▼──────────────────┐
                    │       Management Zone            │
                    │   Jump boxes, monitoring, logs    │
                    └─────────────────────────────────┘
```

Each zone boundary is a firewall. Traffic flows in one direction -- from less trusted to more trusted -- with explicit rules for each allowed path.

## Patterns

### Pattern 1: VLAN-Based Segmentation with Inter-VLAN Routing

```
# VLAN Design
VLAN 10  - Management       (10.0.10.0/24) - Network devices, jump boxes
VLAN 20  - Servers           (10.0.20.0/24) - Application servers
VLAN 30  - Database          (10.0.30.0/24) - Database servers
VLAN 40  - User Workstations (10.0.40.0/24) - Employee desktops
VLAN 50  - Guest             (10.0.50.0/24) - Guest WiFi, IoT
VLAN 100 - DMZ               (10.0.100.0/24) - Public-facing services
```

**Inter-VLAN firewall rules (nftables on the router/firewall):**

```nft
table inet inter_vlan {
    chain forward {
        type filter hook forward priority 0; policy drop;

        # Allow established/related
        ct state established,related accept

        # DMZ -> Servers (web app to API)
        iifname "vlan100" oifname "vlan20" tcp dport 8080 accept

        # Servers -> Database
        iifname "vlan20" oifname "vlan30" tcp dport { 5432, 6379 } accept

        # Management -> All (for administration)
        iifname "vlan10" accept

        # Workstations -> Servers (internal tools)
        iifname "vlan40" oifname "vlan20" tcp dport { 80, 443 } accept

        # Workstations -> Internet (via NAT)
        iifname "vlan40" oifname "wan0" accept

        # Guest -> Internet only (complete isolation)
        iifname "vlan50" oifname "wan0" tcp dport { 80, 443 } accept
        iifname "vlan50" oifname "wan0" udp dport 53 accept

        # Everything else: DROP (default policy)
        log prefix "[inter-vlan-drop] "
    }
}
```

**Why this works**: Each VLAN is a separate broadcast domain. Inter-VLAN traffic must pass through the firewall, where explicit rules control which VLANs can communicate and on which ports. The guest network can only reach the internet. The database network only accepts connections from the server network. Management has broad access but can be further restricted.

### Pattern 2: Cloud VPC Segmentation (AWS)

```hcl
# VPC with segmented subnets
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

# Public subnets (ALBs, NAT Gateways)
resource "aws_subnet" "public" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = false  # Explicit EIP allocation, not auto-assign
}

# Application subnets (private)
resource "aws_subnet" "app" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 10}.0/24"
  availability_zone = data.aws_availability_zones.az.names[count.index]
}

# Database subnets (private, isolated)
resource "aws_subnet" "db" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.${count.index + 20}.0/24"
  availability_zone = data.aws_availability_zones.az.names[count.index]
}

# NACLs for defense-in-depth (in addition to Security Groups)
resource "aws_network_acl" "db" {
  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.db[*].id

  # Allow PostgreSQL from app subnets only
  ingress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.10.0/24"
    from_port  = 5432
    to_port    = 5432
  }

  ingress {
    rule_no    = 101
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.11.0/24"
    from_port  = 5432
    to_port    = 5432
  }

  # Allow return traffic (NACLs are stateless)
  egress {
    rule_no    = 100
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.10.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  egress {
    rule_no    = 101
    protocol   = "tcp"
    action     = "allow"
    cidr_block = "10.0.11.0/24"
    from_port  = 1024
    to_port    = 65535
  }

  # Deny all else (implicit, but explicit for clarity)
  ingress {
    rule_no    = 999
    protocol   = "-1"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    rule_no    = 999
    protocol   = "-1"
    action     = "deny"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }
}
```

**Why this works**: Three tiers (public, app, database) with NACLs as a defense-in-depth layer on top of Security Groups. NACLs are stateless and operate at the subnet level, providing an additional barrier even if a Security Group is misconfigured. The database subnets only allow PostgreSQL traffic from app subnets.

### Pattern 3: Micro-Segmentation with Service Mesh (Istio mTLS)

```yaml
# Istio PeerAuthentication: require mTLS for all services
apiVersion: security.istio.io/v1
kind: PeerAuthentication
metadata:
  name: default
  namespace: istio-system
spec:
  mtls:
    mode: STRICT
---
# AuthorizationPolicy: only frontend can call API
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: api-access
  namespace: production
spec:
  selector:
    matchLabels:
      app: api
  action: ALLOW
  rules:
    - from:
        - source:
            principals: ["cluster.local/ns/production/sa/frontend"]
      to:
        - operation:
            methods: ["GET", "POST"]
            paths: ["/api/v1/*"]
---
# AuthorizationPolicy: only API can call database
apiVersion: security.istio.io/v1
kind: AuthorizationPolicy
metadata:
  name: db-access
  namespace: production
spec:
  selector:
    matchLabels:
      app: database
  action: ALLOW
  rules:
    - from:
        - source:
            principals: ["cluster.local/ns/production/sa/api"]
      to:
        - operation:
            ports: ["5432"]
```

**Why this works**: Service mesh provides identity-based segmentation -- authorization is based on cryptographic service identity (mTLS certificates), not IP addresses. This works in dynamic environments (Kubernetes) where IP addresses change constantly. The mesh also provides encryption in transit for all service-to-service communication.

## Anti-Patterns

### Anti-Pattern 1: Flat Network

A single subnet/VLAN with all servers, databases, workstations, and guest devices. Compromising any single device gives direct network access to everything.

### Anti-Pattern 2: Segmentation Without Monitoring

Network segments with no traffic logging between them. You have boundaries but no visibility into what crosses them -- attackers can move laterally undetected.

### Anti-Pattern 3: Over-Permissive Inter-Zone Rules

Firewall rules between zones that allow broad port ranges or all TCP traffic. This defeats the purpose of segmentation -- the boundary exists but does not restrict meaningful traffic.

### Anti-Pattern 4: Management Network With Full Access

Management/admin networks with unrestricted access to all zones. If an admin workstation is compromised, the attacker inherits access to every zone. Even management access should be scoped -- database admins access the database zone, web admins access the DMZ.

### Anti-Pattern 5: Segmentation Only at Layer 3

Relying solely on IP-based segmentation without considering Layer 7 (application) controls. An attacker who can reach a permitted port can still exploit application vulnerabilities. Defense in depth requires both network and application layer controls.

## References

- [NIST SP 800-125B: Secure Virtual Network Configuration](https://csrc.nist.gov/publications/detail/sp/800-125b/final)
- [VMware Micro-Segmentation Design Guide](https://www.vmware.com/content/dam/digitalmarketing/vmware/en/pdf/products/nsx/vmware-micro-segmentation-day-1.pdf)
- [Istio Security Architecture](https://istio.io/latest/docs/concepts/security/)
- [Zero Trust Networks (O'Reilly)](https://www.oreilly.com/library/view/zero-trust-networks/9781491962183/)
- [SANS: Network Segmentation Best Practices](https://www.sans.org/white-papers/36540/)
