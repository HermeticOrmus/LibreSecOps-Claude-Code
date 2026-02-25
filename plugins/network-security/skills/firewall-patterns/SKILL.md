# Firewall Patterns

> iptables/nftables rulesets, cloud security group patterns, and firewall design principles.

## Knowledge Base

### Firewall Processing Models

Different firewalls process rules differently. Understanding the model is critical for correct configuration:

| Firewall | Processing | Implication |
|----------|-----------|-------------|
| **iptables** | Sequential (first match wins) | Rule order matters. A broad ACCEPT before a specific DROP makes the DROP unreachable. |
| **nftables** | Sequential within chains, but supports sets and maps for efficiency | More flexible than iptables, same sequential logic. |
| **AWS Security Groups** | All rules evaluated, any allow = allow. No deny rules. | Cannot deny specific IPs. Denies require NACLs. Stateful. |
| **AWS NACLs** | Sequential by rule number (lowest first). Has explicit deny. | Stateless -- must allow return traffic explicitly. |
| **Azure NSGs** | Priority-based (lowest number = highest priority) | Has deny rules. Stateful. Default rules at priority 65000+. |
| **GCP Firewall Rules** | Priority-based (lowest number = highest priority) | Has deny rules. Implied deny-all ingress, allow-all egress. |

### Stateful vs Stateless

- **Stateful** (iptables with conntrack, security groups): Tracks connections. If outbound is allowed, the return traffic is automatically allowed.
- **Stateless** (NACLs, basic nftables without conntrack): Each packet evaluated independently. Must explicitly allow return traffic (ephemeral ports).

## Patterns

### Pattern 1: Linux Server Baseline (nftables)

```nft
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;

        # Allow established/related connections
        ct state established,related accept

        # Drop invalid packets
        ct state invalid drop

        # Allow loopback
        iif "lo" accept

        # Allow ICMP (ping) with rate limiting
        ip protocol icmp icmp type echo-request limit rate 5/second accept
        ip6 nexthdr icmpv6 icmpv6 type echo-request limit rate 5/second accept

        # Allow ICMPv6 neighbor/router discovery (required for IPv6)
        ip6 nexthdr icmpv6 icmpv6 type {
            nd-neighbor-solicit,
            nd-neighbor-advert,
            nd-router-solicit,
            nd-router-advert
        } accept

        # Allow SSH from management network only
        ip saddr 10.0.1.0/24 tcp dport 22 accept

        # Allow HTTP/HTTPS (if web server)
        tcp dport { 80, 443 } accept

        # Log dropped packets (rate limited to prevent log flooding)
        limit rate 5/minute log prefix "[nftables-drop] " level warn

        # Default policy: drop (set above)
    }

    chain forward {
        type filter hook forward priority 0; policy drop;
        # Drop all forwarded traffic unless this is a router/gateway
    }

    chain output {
        type filter hook output priority 0; policy drop;

        # Allow established/related
        ct state established,related accept

        # Allow loopback
        oif "lo" accept

        # Allow DNS
        tcp dport 53 accept
        udp dport 53 accept

        # Allow HTTP/HTTPS outbound
        tcp dport { 80, 443 } accept

        # Allow NTP
        udp dport 123 accept

        # Allow SSH outbound (for git, deployments)
        tcp dport 22 accept

        # Log dropped outbound
        limit rate 5/minute log prefix "[nftables-egress-drop] " level warn
    }
}
```

**Why this works**: Default policy is drop on all chains (input, forward, output). Established connections are handled by conntrack. SSH is restricted to the management network. Egress is filtered -- the server can only reach DNS, HTTP/S, NTP, and SSH outbound. Dropped packets are logged with rate limiting to prevent log floods.

### Pattern 2: AWS Security Group for Web Application

```hcl
# Application Load Balancer SG
resource "aws_security_group" "alb" {
  name_prefix = "alb-"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP redirect"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description     = "To application servers"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = { Name = "alb-sg" }
}

# Application Server SG
resource "aws_security_group" "app" {
  name_prefix = "app-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "From ALB"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description     = "To database"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db.id]
  }

  egress {
    description = "HTTPS outbound (APIs, updates)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "DNS"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = { Name = "app-sg" }
}

# Database SG
resource "aws_security_group" "db" {
  name_prefix = "db-"
  vpc_id      = var.vpc_id

  ingress {
    description     = "PostgreSQL from app servers"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  # No egress rules -- database should not initiate connections
  # (AWS SGs are stateful, return traffic is automatic)

  tags = { Name = "db-sg" }
}
```

**Why this works**: Security groups reference each other instead of using CIDR blocks, creating a chain: Internet -> ALB (443) -> App (8080) -> DB (5432). The database has no egress rules -- it accepts connections but never initiates them. Each SG only allows the specific port needed.

### Pattern 3: iptables Rate Limiting for SSH (Anti-Brute-Force)

```bash
# Create a chain for SSH rate limiting
iptables -N SSH_RATE_LIMIT

# Limit new SSH connections to 3 per minute per source IP
iptables -A SSH_RATE_LIMIT -m recent --name sshbrute --set
iptables -A SSH_RATE_LIMIT -m recent --name sshbrute --update --seconds 60 --hitcount 4 -j DROP
iptables -A SSH_RATE_LIMIT -j ACCEPT

# Direct SSH traffic to the rate limit chain
iptables -A INPUT -p tcp --dport 22 -m state --state NEW -j SSH_RATE_LIMIT
```

**Why this works**: The `recent` module tracks source IPs. If a source IP makes more than 3 new SSH connections in 60 seconds, subsequent connections are dropped. This slows brute-force attacks without affecting legitimate users.

## Anti-Patterns

### Anti-Pattern 1: Default Accept Policy

```bash
# BAD -- if no rule matches, traffic is accepted
iptables -P INPUT ACCEPT
```

Default accept means any traffic not explicitly denied is allowed. A new service listening on an unexpected port is immediately reachable. Always use default deny.

### Anti-Pattern 2: Allow All Egress

```bash
# BAD -- no outbound restrictions
iptables -P OUTPUT ACCEPT
```

Without egress filtering, a compromised server can exfiltrate data to any IP on any port, download additional attack tools, and participate in botnet activity. Filter egress to known-required destinations and ports.

### Anti-Pattern 3: Security Group with 0.0.0.0/0 on Database Port

```hcl
# BAD -- database accessible from anywhere
ingress {
  from_port   = 3306
  to_port     = 3306
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}
```

Databases should NEVER be directly accessible from the internet. Use application security groups, private subnets, and VPN/bastion access for database administration.

### Anti-Pattern 4: No Logging

Firewall rules without logging mean you have no visibility into blocked (or allowed) traffic. You cannot detect attacks, cannot forensically investigate incidents, and cannot verify that rules are working as intended.

### Anti-Pattern 5: IPv4 Only

Many administrators configure iptables but forget ip6tables. If IPv6 is enabled on interfaces, all IPv6 traffic bypasses the IPv4 firewall rules entirely. Either disable IPv6 if not needed (`sysctl -w net.ipv6.conf.all.disable_ipv6=1`) or configure matching ip6tables rules.

## References

- [nftables Wiki](https://wiki.nftables.org/)
- [iptables Tutorial](https://www.frozentux.net/iptables-tutorial/iptables-tutorial.html)
- [AWS Security Groups Documentation](https://docs.aws.amazon.com/vpc/latest/userguide/security-groups.html)
- [NIST SP 800-41: Firewall Guidelines](https://csrc.nist.gov/publications/detail/sp/800-41/rev-1/final)
- [PF User's Guide (OpenBSD)](https://www.openbsd.org/faq/pf/)
- [OPNsense Documentation](https://docs.opnsense.org/)
