# CIS Benchmarks

> Reference knowledge base for CIS Benchmark controls across common platforms: Linux, Docker, Kubernetes, AWS, PostgreSQL, Nginx, and more.

## Knowledge Base

### CIS Benchmark Structure

Every CIS Benchmark follows a consistent structure:

- **Profile Levels**: Level 1 (practical, minimal impact) and Level 2 (defense-in-depth, may impact functionality)
- **Scored vs Not-Scored**: Scored controls count toward compliance percentage. Not-scored controls are recommendations.
- **Control Format**: Each control has a description, rationale, audit procedure, remediation procedure, and impact statement
- **Assessment Status**: Automated (can be checked with tools) or Manual (requires human judgment)

### Linux (Ubuntu/Debian) -- Key Controls

#### 1. Initial Setup

**1.1 Filesystem Configuration**
```bash
# Ensure /tmp is a separate partition with nodev, nosuid, noexec
# Audit:
mount | grep -E '\s/tmp\s'
# Expected: /tmp on separate partition with nodev,nosuid,noexec

# Ensure /var, /var/tmp, /var/log, /var/log/audit are separate partitions
# Audit:
mount | grep -E '\s/var\s'

# Disable unused filesystems
# /etc/modprobe.d/CIS.conf:
install cramfs /bin/true
install squashfs /bin/true
install udf /bin/true
install usb-storage /bin/true  # Level 2, if USB not needed
```

**1.3 Mandatory Access Control**
```bash
# Ensure AppArmor is installed and enforcing
apt list --installed 2>/dev/null | grep apparmor
aa-status  # Should show profiles in enforce mode

# Remediation:
apt install apparmor apparmor-utils
systemctl enable apparmor
aa-enforce /etc/apparmor.d/*
```

**1.4 Bootloader Configuration**
```bash
# Ensure bootloader password is set
grep "^set superusers" /boot/grub/grub.cfg
# Ensure permissions on bootloader config
stat /boot/grub/grub.cfg  # Should be 0400, root:root
```

#### 2. Services

```bash
# Ensure unnecessary services are not installed or disabled
# Check for services that should NOT be running:
systemctl is-active avahi-daemon  # mDNS - disable unless needed
systemctl is-active cups          # Printing - disable on servers
systemctl is-active dhcpd         # DHCP server - disable unless needed
systemctl is-active slapd         # LDAP server - disable unless needed
systemctl is-active nfs-server    # NFS - disable unless needed
systemctl is-active rpcbind       # RPC - disable unless needed
systemctl is-active rsync         # rsync - disable unless needed
systemctl is-active snmpd         # SNMP - disable unless needed

# Ensure only required services are listening
ss -tlnp  # Review all listening TCP services
ss -ulnp  # Review all listening UDP services
```

#### 3. Network Configuration

```bash
# Kernel network parameters (/etc/sysctl.d/99-cis.conf)
# Disable IP forwarding (unless router/gateway)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Disable source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0

# Disable ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Enable TCP SYN cookies
net.ipv4.tcp_syncookies = 1

# Log suspicious packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# Ignore ICMP broadcasts
net.ipv4.icmp_echo_ignore_broadcasts = 1

# Apply: sysctl -p /etc/sysctl.d/99-cis.conf
```

#### 4. Logging and Auditing

```bash
# Ensure auditd is installed and enabled
apt install auditd audispd-plugins
systemctl enable auditd

# Key audit rules (/etc/audit/rules.d/cis.rules)
# Monitor time changes
-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -k time-change
-w /etc/localtime -p wa -k time-change

# Monitor user/group changes
-w /etc/group -p wa -k identity
-w /etc/passwd -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# Monitor network changes
-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale
-w /etc/issue -p wa -k system-locale
-w /etc/issue.net -p wa -k system-locale
-w /etc/hosts -p wa -k system-locale
-w /etc/network -p wa -k system-locale

# Monitor login/logout events
-w /var/log/faillog -p wa -k logins
-w /var/log/lastlog -p wa -k logins
-w /var/log/tallylog -p wa -k logins

# Monitor session initiation
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session

# Monitor permission changes
-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod
-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod

# Monitor sudo usage
-w /var/log/sudo.log -p wa -k actions

# Make audit configuration immutable (requires reboot to change)
-e 2
```

#### 5. Access and Authentication

```bash
# SSH hardening (/etc/ssh/sshd_config)
Protocol 2
LogLevel VERBOSE
MaxAuthTries 4
PermitRootLogin no
PermitEmptyPasswords no
PasswordAuthentication no          # Key-only authentication
X11Forwarding no
AllowTcpForwarding no
MaxSessions 4
ClientAliveInterval 300
ClientAliveCountMax 0
LoginGraceTime 60
Banner /etc/issue.net
AllowUsers specific_user           # Allowlist of permitted users
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# Password policy (/etc/security/pwquality.conf)
minlen = 14
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1

# Account lockout (/etc/pam.d/common-auth)
auth required pam_faillock.so preauth silent audit deny=5 unlock_time=900
auth required pam_faillock.so authfail audit deny=5 unlock_time=900

# Sudo configuration
# Ensure sudo log file exists
Defaults logfile="/var/log/sudo.log"
# Require authentication for sudo
Defaults !authenticate  # REMOVE this if present
# Use individual accounts, not shared passwords
```

### Docker -- Key Controls

```bash
# 1. Host Configuration
# Ensure Docker daemon is audited
-w /usr/bin/docker -p wa -k docker
-w /var/lib/docker -p wa -k docker
-w /etc/docker -p wa -k docker
-w /usr/lib/systemd/system/docker.service -p wa -k docker
-w /usr/lib/systemd/system/docker.socket -p wa -k docker

# 2. Docker Daemon Configuration (/etc/docker/daemon.json)
{
  "icc": false,                    # Disable inter-container communication
  "userns-remap": "default",      # Enable user namespace remapping
  "no-new-privileges": true,       # Prevent privilege escalation
  "live-restore": true,            # Keep containers running on daemon restart
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-ulimits": {
    "nofile": { "Name": "nofile", "Hard": 64000, "Soft": 64000 }
  }
}

# 3. Container Runtime
# Run as non-root user
USER nonroot  # In Dockerfile

# Drop all capabilities and add only what's needed
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE ...

# Read-only filesystem
docker run --read-only --tmpfs /tmp ...

# Resource limits
docker run --memory 512m --cpus 1 --pids-limit 100 ...

# No privileged mode
# NEVER use --privileged unless absolutely necessary

# Health checks
HEALTHCHECK --interval=30s --timeout=3s CMD curl -f http://localhost/ || exit 1
```

### Kubernetes -- Key Controls

```yaml
# Pod Security Standards (Restricted)
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop: ["ALL"]
    resources:
      limits:
        memory: "128Mi"
        cpu: "500m"
      requests:
        memory: "64Mi"
        cpu: "250m"

# Network Policy (deny all by default)
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

### AWS Foundations -- Key Controls

```bash
# IAM
# Ensure MFA is enabled for root account
aws iam get-account-summary | grep AccountMFAEnabled
# Expected: 1

# Ensure no root access keys exist
aws iam get-account-summary | grep AccountAccessKeysPresent
# Expected: 0

# Ensure IAM password policy is strong
aws iam get-account-password-policy
# MinimumPasswordLength >= 14, RequireSymbols, RequireNumbers, RequireUppercase, RequireLowercase, MaxPasswordAge <= 90

# Logging
# Ensure CloudTrail is enabled in all regions
aws cloudtrail describe-trails
# Ensure CloudTrail logs are encrypted with KMS
# Ensure CloudTrail log file validation is enabled

# Networking
# Ensure no security groups allow ingress from 0.0.0.0/0 to port 22 or 3389
aws ec2 describe-security-groups --filters "Name=ip-permission.from-port,Values=22" "Name=ip-permission.cidr,Values=0.0.0.0/0"
# Expected: empty result

# Storage
# Ensure S3 bucket policy denies HTTP requests (require HTTPS)
# Ensure S3 buckets have server-side encryption enabled
# Ensure S3 bucket public access is blocked
aws s3api get-public-access-block --bucket BUCKET_NAME
```

## Patterns

### Hardening Automation

The most effective hardening is automated hardening that runs continuously:

1. **Define desired state** in configuration management (Ansible, Terraform, Chef, Puppet)
2. **Apply automatically** on new system provisioning
3. **Detect drift** with compliance scanning (InSpec, Lynis, Prowler)
4. **Remediate automatically** or alert on drift
5. **Report continuously** on compliance status

### Prioritization Framework

When resources are limited, prioritize hardening in this order:
1. Internet-facing systems (highest exposure)
2. Systems handling sensitive data (highest impact)
3. Authentication infrastructure (keys to the kingdom)
4. Internal infrastructure (lateral movement prevention)
5. Development/test systems (supply chain risk)

## Anti-Patterns

- **Hardening once and forgetting**: Configuration drift returns systems to insecure defaults. Automate and monitor continuously.
- **Applying every control blindly**: Some controls break applications. Test in staging, understand the impact, and document exceptions.
- **Hardening the OS but not the application**: A hardened Linux server running a misconfigured web application with default credentials is still vulnerable.
- **Ignoring cloud-specific hardening**: Cloud environments have unique attack surfaces (IAM, metadata service, public storage) that OS-level hardening doesn't address.
- **No exception management**: Skipping controls without documentation. Every exception needs a reason, a compensating control, and a review date.
- **Manual hardening only**: Shell scripts run once are not hardening. Configuration management applied continuously is hardening.

## References

- [CIS Benchmarks (free PDF registration)](https://www.cisecurity.org/cis-benchmarks)
- [CIS Controls v8](https://www.cisecurity.org/controls/v8)
- [DISA STIGs](https://public.cyber.mil/stigs/)
- [dev-sec.io Hardening Framework (Ansible/InSpec)](https://dev-sec.io/)
- [Lynis - Security Auditing Tool](https://cisofy.com/lynis/)
- [OpenSCAP](https://www.open-scap.org/)
- [Prowler - AWS Security Tool](https://github.com/prowler-cloud/prowler)
- [kube-bench - Kubernetes CIS Benchmark](https://github.com/aquasecurity/kube-bench)
- [Docker Bench for Security](https://github.com/docker/docker-bench-security)
