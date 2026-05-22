# 🐧 🛡️ Sysctl Security Configuration

This subdirectory contains kernel parameters to improve overall system security via sysctl. It features carefully selected options divided into multiple categories, each addressing specific security concerns.

---

## Configuration Sections and Their Purpose

### 1. Anti-Spoofing and Route Filtering Protections

- **rp_filter**: Configures reverse path filtering to prevent IP spoofing attacks.
  - Set to mode 2 (loose) for compatibility with VPNs and asymmetric routing.
  - Applies to both IPv4 and IPv6.

### 2. DoS and SYN Flood Protection

- **tcp_syncookies**: Enables protection against SYN flood attacks.
- **icmp_echo_ignore_broadcasts**: Prevents Smurf attack/DoS attempts.
- **icmp_ignore_bogus_error_responses**: Enhances privacy by ignoring suspicious ICMP errors.
- **icmp_echo_ignore_all (IPv4) / icmp.echo_ignore_all (IPv6)**: Ignores all incoming pings for stealth mode.

### 3. ICMP Redirects and MITM Protection

- Disables ICMP redirects acceptance and sending to prevent man-in-the-middle attacks.
- Applies security measures for both IPv4 and IPv6.

### 4. Advanced Forwarding and Routing

- **ip_forward**: Disables IP forwarding to prevent the machine from acting as a router.
- Blocks source routing to prevent route manipulation by attackers.

### 5. Logging and Detection

- **log_martians**: Option to log invalid/spoofed packets for security monitoring.

### 6. TCP Optimizations and Anti-Fingerprinting

- **tcp_timestamps**: Can be disabled to reduce OS fingerprinting.
- Disables SACK and D-SACK to reduce kernel attack surface.

### 7. IPv6 Controls

- Options to disable IPv6 if not needed, reducing attack surface.
- **use_tempaddr**: Enables IPv6 privacy extensions (RFC 4941) to use temporary, randomized addresses for improved privacy.

### 8. TTY and Line Disciplines Protections

- Prevents automatic loading of TTY line disciplines to reduce attack surface.
- Uses **dev.tty.ldisc_autoload** to control this behavior.

### 9. Filesystem Protections

- Hardening against malicious file interactions including symlinks, hardlinks, FIFOs, and regular files.
- Implements protections through **fs.protected_fifos**, **fs.protected_hardlinks**, **fs.protected_regular**, and **fs.protected_symlinks**.
- **fs.binfmt_misc.status**: Disable support for non-native binaries.
- **fs.suid_dumpable**: Prevent privileged (SUID) processes from generating core dumps.

### 10. Kernel Access Restrictions

- Restricts access to kernel information and features to reduce exploitation surface.
- Uses **kernel.dmesg_restrict**, **kernel.io_uring_disabled**, **kernel.kexec_load_disabled**, **kernel.kptr_restrict**, **kernel.perf_event_paranoid**, and **kernel.slab_merging**.
- Additional kernel controls: **kernel.sysrq**, **kernel.oops_limit**, **kernel.warn_limit**, **kernel.panic**, **kernel.printk**, **kernel.core_pattern**.
- **vm.unprivileged_userfaultfd**: Disable userfaultfd for unprivileged users to mitigate use-after-free style vulnerabilities.

### 11. Advanced Network and TCP Protections

- Hardens TCP stack and prevents unwanted redirects.
- Implements **net.ipv4.tcp_rfc1337** and **net.ipv4.conf.\*.shared_media** protections.
- LAN ARP hardening: **net.ipv4.conf.\*.arp_filter**, **net.ipv4.conf.\*.arp_ignore**, **net.ipv4.conf.all.drop_gratuitous_arp**.

### 12. Memory Randomization (ASLR)

- Increases memory layout randomization to make memory exploits significantly harder.
- Uses **vm.mmap_rnd_bits** and **vm.mmap_rnd_compat_bits** for enhanced ASLR.

### 13. BPF and User Namespaces Protections

- Hardens BPF JIT compiler and restricts BPF usage to privileged users.
- Implements **net.core.bpf_jit_harden**, **kernel.unprivileged_bpf_disabled**, and **kernel.yama.ptrace_scope**.

### 14. Memory and Swap Optimizations

- Optimizes memory management by reducing swap usage tendency.
- Controlled by **vm.swappiness** parameter.

---

## 🚀 Implementation Guide

1. Copy the configuration file with root privileges:

   ```bash
   sudo cp 99-linux-security.conf /etc/sysctl.d/
   ```

2. Apply the changes using one of these methods:

   **Method 1**: Apply all sysctl configurations (recommended for most users)

   ```bash
   sudo sysctl --system
   ```

   **Method 2**: Apply only this specific configuration

   ```bash
   sudo sysctl -p /etc/sysctl.d/99-linux-security.conf
   ```

---

## 🔍 Verifying the Changes

You can verify the applied settings using any of the verification commands detailed in the main READMEs or by checking individual parameters:

```bash
sysctl <parameter_name>
```
