# Container Runtime Security

> Runtime isolation mechanisms, Linux capabilities, seccomp profiles, AppArmor, and namespace configuration for containers.

## Knowledge Base

### Linux Kernel Features Used by Containers

Containers are not a kernel primitive. They are a userspace abstraction built on real kernel features:

| Feature | Purpose | Container Impact |
|---------|---------|------------------|
| **Namespaces** | Isolation of system resources (PID, NET, MNT, UTS, IPC, USER, CGROUP) | Each container gets its own view of processes, network, filesystem mounts |
| **cgroups** | Resource limiting and accounting (CPU, memory, I/O, PIDs) | Prevents a container from consuming all host resources |
| **Capabilities** | Fine-grained subdivision of root privileges (37 capabilities in Linux) | Containers can run as "root" but without dangerous capabilities |
| **Seccomp** | System call filtering (BPF-based) | Blocks dangerous syscalls like `mount`, `reboot`, `kexec_load` |
| **AppArmor/SELinux** | Mandatory Access Control (MAC) | Restricts file access, network operations, capabilities |
| **User namespaces** | Map container UID 0 to unprivileged host UID | Container "root" is not host root |

### Linux Capabilities Breakdown

Docker drops most capabilities by default, keeping only these 14:

```
CHOWN, DAC_OVERRIDE, FOWNER, FSETID, KILL, SETGID, SETUID, SETPCAP,
NET_BIND_SERVICE, NET_RAW, SYS_CHROOT, MKNOD, AUDIT_WRITE, SETFCAP
```

**Dangerous capabilities to NEVER add:**

| Capability | Risk |
|------------|------|
| `SYS_ADMIN` | Near-complete root access. Allows mounting filesystems, using `unshare`, BPF operations. The "god capability." |
| `SYS_PTRACE` | Trace any process. Can inject code into other containers sharing a PID namespace. |
| `SYS_RAWIO` | Raw I/O port access, can modify kernel memory via `/dev/mem`. |
| `DAC_READ_SEARCH` | Bypass file read permissions. Can read any file on mounted filesystems. |
| `NET_ADMIN` | Full network control. Can modify routing tables, firewall rules, capture traffic. |
| `SYS_MODULE` | Load kernel modules. Instant host compromise. |

### Default Docker Seccomp Profile

Docker ships with a seccomp profile that blocks approximately 44 of 300+ syscalls. Key blocked syscalls:

- `mount`, `umount2` -- Prevents filesystem mounting inside containers
- `reboot` -- Prevents host reboot
- `kexec_load` -- Prevents loading a new kernel
- `swapon`, `swapoff` -- Prevents swap manipulation
- `add_key`, `keyctl`, `request_key` -- Prevents kernel keyring access
- `bpf` -- Prevents BPF program loading (partial, architecture-dependent)
- `clone` with `CLONE_NEWUSER` -- Prevents creating new user namespaces (can be used for privilege escalation)

## Patterns

### Pattern 1: Maximum Isolation Docker Run

```bash
docker run \
  --name secure-app \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  --tmpfs /var/run:rw,noexec,nosuid,size=1m \
  --cap-drop ALL \
  --cap-add NET_BIND_SERVICE \
  --security-opt no-new-privileges:true \
  --security-opt seccomp=seccomp-profile.json \
  --security-opt apparmor=docker-custom \
  --user 1001:1001 \
  --memory 512m \
  --cpus 1.0 \
  --pids-limit 100 \
  --network app-network \
  --restart unless-stopped \
  --health-cmd "wget -qO- http://localhost:8080/health || exit 1" \
  --health-interval 30s \
  myapp:v1.2.3
```

**Why each flag matters:**
- `--read-only` -- Root filesystem is read-only; attacker cannot write backdoors, download tools, or modify configs
- `--tmpfs` -- Writable tmpfs for temporary data, with `noexec` preventing binary execution
- `--cap-drop ALL --cap-add NET_BIND_SERVICE` -- Only capability granted is binding to ports below 1024
- `--no-new-privileges` -- Prevents `setuid` binaries from escalating privileges inside the container
- `--seccomp` -- Custom seccomp profile restricting available system calls
- `--user 1001:1001` -- Non-root user, even if Dockerfile does not specify one
- `--memory`, `--cpus`, `--pids-limit` -- Resource limits prevent DoS against the host

### Pattern 2: Hardened Docker Compose Service

```yaml
version: "3.9"

services:
  api:
    image: myapp:v1.2.3@sha256:abc123...
    read_only: true
    tmpfs:
      - /tmp:size=64M,noexec,nosuid
    user: "1001:1001"
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
    security_opt:
      - no-new-privileges:true
      - seccomp:seccomp-profile.json
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: "1.0"
          pids: 100
        reservations:
          memory: 256M
    networks:
      - frontend
    healthcheck:
      test: ["CMD", "wget", "--spider", "-q", "http://localhost:8080/health"]
      interval: 30s
      timeout: 3s
      retries: 3
      start_period: 10s
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"

  db:
    image: postgres:16-alpine@sha256:def456...
    read_only: true
    tmpfs:
      - /tmp:size=64M
      - /run/postgresql:size=1M
    user: "999:999"
    cap_drop:
      - ALL
    security_opt:
      - no-new-privileges:true
    volumes:
      - db-data:/var/lib/postgresql/data
    networks:
      - backend
    environment:
      POSTGRES_PASSWORD_FILE: /run/secrets/db_password
    secrets:
      - db_password

networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access

secrets:
  db_password:
    file: ./secrets/db_password.txt

volumes:
  db-data:
    driver: local
```

**Why this works**: Each service drops all capabilities, runs read-only, uses non-root users, and has resource limits. The database is on an `internal` network with no external access. Secrets are injected via Docker Secrets (file-based), not environment variables. Logging is configured to prevent disk exhaustion.

### Pattern 3: Custom Seccomp Profile (Restrictive)

```json
{
  "defaultAction": "SCMP_ACT_ERRNO",
  "defaultErrnoRet": 1,
  "architectures": [
    "SCMP_ARCH_X86_64",
    "SCMP_ARCH_AARCH64"
  ],
  "syscalls": [
    {
      "names": [
        "accept", "accept4", "bind", "brk", "clock_gettime",
        "clone", "close", "connect", "dup", "dup2", "dup3",
        "epoll_create", "epoll_create1", "epoll_ctl", "epoll_wait",
        "epoll_pwait", "execve", "exit", "exit_group",
        "fcntl", "fstat", "futex", "getcwd", "getdents64",
        "getegid", "geteuid", "getgid", "getpid", "getppid",
        "getsockname", "getsockopt", "getuid",
        "ioctl", "listen", "lseek",
        "madvise", "memfd_create", "mmap", "mprotect", "mremap",
        "munmap", "nanosleep", "newfstatat", "openat",
        "pipe", "pipe2", "poll", "ppoll",
        "pread64", "pwrite64", "read", "readlink",
        "recvfrom", "recvmsg", "rename", "rt_sigaction",
        "rt_sigprocmask", "rt_sigreturn",
        "sched_getaffinity", "sched_yield",
        "sendmsg", "sendto", "set_robust_list",
        "set_tid_address", "setsockopt", "shutdown",
        "sigaltstack", "socket", "stat",
        "tgkill", "uname", "unlink", "wait4", "write", "writev"
      ],
      "action": "SCMP_ACT_ALLOW"
    }
  ]
}
```

**Why this works**: This is an allowlist approach -- only explicitly named syscalls are permitted. Everything else returns ERRNO. This is more secure than Docker's default profile (which is a denylist). Start by profiling your application with `strace` to identify which syscalls it actually uses, then build the allowlist.

### Pattern 4: User Namespace Remapping

```json
// /etc/docker/daemon.json
{
  "userns-remap": "default"
}
```

```bash
# After enabling, Docker creates subordinate UID/GID mappings:
# /etc/subuid: dockremap:100000:65536
# /etc/subgid: dockremap:100000:65536

# Container UID 0 maps to host UID 100000
# Container UID 1 maps to host UID 100001
# ...
```

**Why this works**: User namespace remapping ensures that even if a container process runs as UID 0 (root) inside the container, it maps to an unprivileged UID on the host. A container escape as "root" gives the attacker no privileges on the host.

## Anti-Patterns

### Anti-Pattern 1: `--privileged` Flag

```bash
# NEVER do this in production
docker run --privileged myapp
```

`--privileged` disables ALL security features: grants all capabilities, disables seccomp, disables AppArmor, shares all host devices, and effectively gives the container root access to the host. There is almost never a legitimate reason for this in production.

### Anti-Pattern 2: Docker Socket Mount

```yaml
# NEVER mount the Docker socket unless the container IS your Docker management tool
volumes:
  - /var/run/docker.sock:/var/run/docker.sock
```

Access to the Docker socket = root on the host. Any container with the socket can create a new privileged container with host filesystem access, extracting any file or credential from the host.

### Anti-Pattern 3: `--pid=host`

Sharing the host PID namespace lets the container see and signal all host processes. Combined with `SYS_PTRACE`, it enables process injection attacks against the host.

### Anti-Pattern 4: Running Without Resource Limits

Without memory and PID limits, a compromised container can:
- Allocate all available memory (OOM kills other containers and host processes)
- Fork-bomb (create processes until the host is unusable)
- Fill disk with logs (denial of service)

### Anti-Pattern 5: Disabling Seccomp

```bash
# NEVER disable seccomp
docker run --security-opt seccomp=unconfined myapp
```

Disabling seccomp exposes the full Linux syscall surface. Kernel vulnerabilities in obscure syscalls have historically been used for container escapes (e.g., CVE-2022-0185 used `fsconfig` which seccomp blocks by default).

## References

- [Docker Security Documentation](https://docs.docker.com/engine/security/)
- [Linux Capabilities Manual (capabilities(7))](https://man7.org/linux/man-pages/man7/capabilities.7.html)
- [Docker Default Seccomp Profile](https://github.com/moby/moby/blob/master/profiles/seccomp/default.json)
- [CIS Docker Benchmark](https://www.cisecurity.org/benchmark/docker)
- [NIST SP 800-190: Application Container Security Guide](https://csrc.nist.gov/publications/detail/sp/800-190/final)
- [Container Escape Techniques](https://blog.trailofbits.com/2019/07/19/understanding-docker-container-escapes/)
- [Falco -- Container Runtime Security](https://falco.org/)
- [gVisor -- Container Sandbox Runtime](https://gvisor.dev/)
