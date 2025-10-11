# 🐧 🛡️ Linux Network Security Configuration Guide

[![README en Español](https://img.shields.io/badge/README-en%20Español-blue.svg)](./README.es.md)

This repository contains network security configurations for Linux systems (Debian-based distributions) that help protect against various network attacks and improve system security.

## What is `99-network-security.conf`?

The `99-network-security.conf` file is a system configuration file that sets various kernel parameters to enhance network security. It contains carefully tuned settings divided into several sections, each addressing specific security concerns.

## Configuration Sections and Their Purpose

### 1. Anti-Spoofing and Route Filtering Protections

- **rp_filter**: Configures reverse path filtering to prevent IP spoofing attacks.
  - Set to mode 2 (loose) for better compatibility with VPNs and asymmetric routing.
  - Applies to both IPv4 and IPv6.

### 2. DoS and SYN Flood Protection

- **tcp_syncookies**: Enables protection against SYN flood attacks.
- **icmp_echo_ignore_broadcasts**: Prevents Smurf attack/DoS attempts.
- **icmp_ignore_bogus_error_responses**: Enhances privacy by ignoring suspicious ICMP errors.

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
- Enables selective ACK, D-SACK, and FACK for efficient and secure network performance.

### 7. IPv6 Controls

- Options to disable IPv6 if not needed, reducing attack surface.

### 8. TTY and Line Disciplines Protections

- Prevents automatic loading of TTY line disciplines to reduce attack surface.
- Uses **dev.tty.ldisc_autoload** to control this behavior.

### 9. Filesystem Protections

- Hardening against malicious file interactions including symlinks, hardlinks, FIFOs, and regular files.
- Implements protections through **fs.protected_fifos**, **fs.protected_hardlinks**, **fs.protected_regular**, and **fs.protected_symlinks**.

### 10. Kernel Access Restrictions

- Restricts access to kernel information and features to reduce exploitation surface.
- Uses **kernel.dmesg_restrict**, **kernel.io_uring_disabled**, **kernel.kexec_load_disabled**, **kernel.kptr_restrict**, **kernel.perf_event_paranoid**, **kernel.unprivileged_userfaultfd**, and **kernel.slab_merging**.

### 11. Advanced Network and TCP Protections

- Hardens TCP stack and prevents unwanted redirects.
- Implements **net.ipv4.tcp_rfc1337** and **net.ipv4.conf.*.shared_media** protections.

### 12. Memory Randomization (ASLR)

- Increases memory layout randomization to make memory exploits significantly harder.
- Uses **vm.mmap_rnd_bits** and **vm.mmap_rnd_compat_bits** for enhanced ASLR.

### 13. BPF and User Namespaces Protections

- Hardens BPF JIT compiler and restricts BPF usage to privileged users.
- Implements **net.core.bpf_jit_harden**, **kernel.unprivileged_bpf_disabled**, and **kernel.yama.ptrace_scope**.
- Note: User namespace restrictions are commented out by default to maintain compatibility with Flatpak and container runtimes.

### 14. Memory and Swap Optimizations

- Optimizes memory management by reducing swap usage tendency on systems with sufficient RAM.
- Controlled by **vm.swappiness** parameter.

## 🚀 Implementation Guide

1. Open a terminal.

2. Create the configuration file with root privileges:

   ```bash
   sudo nano /etc/sysctl.d/99-network-security.conf
   ```

   (You can use your preferred editor like vim or gedit with sudo)

3. Copy and Paste the contents of [`99-network-security.conf`](./99-network-security.conf), modify the configuration according to your needs.

4. Save and close the editor (in nano: Ctrl+O, Enter, Ctrl+X).

5. Apply the changes using one of these methods:

   **Method 1**: Apply all sysctl configurations (recommended for most users)
   ```bash
   sudo sysctl --system
   ```

   **Method 2**: Apply only this specific configuration
   ```bash
   sudo sysctl -p /etc/sysctl.d/99-network-security.conf
   ```

## 🔍 Verifying the Changes

You can verify the applied settings using either of these commands:

### Compact Version

```bash
sysctl -a | grep -E '
net\.ipv4\.conf\.(all|default)\.(rp_filter|accept_redirects|send_redirects|accept_source_route|log_martians|shared_media)
|net\.ipv4\.(tcp_syncookies|icmp_echo_ignore_broadcasts|icmp_ignore_bogus_error_responses|ip_forward|tcp_timestamps|tcp_sack|tcp_dsack|tcp_fack|tcp_rfc1337)
|net\.ipv6\.conf\.(all|default)\.(rp_filter|accept_redirects|accept_source_route|disable_ipv6)
|dev\.tty\.ldisc_autoload
|fs\.(protected_fifos|protected_hardlinks|protected_regular|protected_symlinks)
|kernel\.(dmesg_restrict|io_uring_disabled|kexec_load_disabled|kptr_restrict|perf_event_paranoid|unprivileged_userfaultfd|slab_merging|unprivileged_bpf_disabled)
|kernel\.yama\.ptrace_scope
|net\.core\.bpf_jit_harden
|vm\.(mmap_rnd_bits|mmap_rnd_compat_bits|swappiness)'
```

### Detailed Version

```bash
sysctl \
  net.ipv4.conf.default.rp_filter net.ipv4.conf.all.rp_filter \
  net.ipv6.conf.default.rp_filter net.ipv6.conf.all.rp_filter \
  net.ipv4.tcp_syncookies net.ipv4.icmp_echo_ignore_broadcasts net.ipv4.icmp_ignore_bogus_error_responses \
  net.ipv4.conf.all.accept_redirects net.ipv4.conf.default.accept_redirects net.ipv4.conf.all.send_redirects \
  net.ipv6.conf.all.accept_redirects net.ipv6.conf.default.accept_redirects \
  net.ipv4.ip_forward net.ipv4.conf.all.accept_source_route net.ipv4.conf.default.accept_source_route \
  net.ipv6.conf.all.accept_source_route net.ipv6.conf.default.accept_source_route \
  net.ipv4.conf.all.log_martians net.ipv4.tcp_timestamps net.ipv4.tcp_sack net.ipv4.tcp_dsack net.ipv4.tcp_fack \
  net.ipv6.conf.all.disable_ipv6 net.ipv6.conf.default.disable_ipv6 \
  dev.tty.ldisc_autoload \
  fs.protected_fifos fs.protected_hardlinks fs.protected_regular fs.protected_symlinks \
  kernel.dmesg_restrict kernel.io_uring_disabled kernel.kexec_load_disabled kernel.kptr_restrict kernel.perf_event_paranoid kernel.unprivileged_userfaultfd kernel.slab_merging \
  net.ipv4.tcp_rfc1337 net.ipv4.conf.all.shared_media net.ipv4.conf.default.shared_media \
  vm.mmap_rnd_bits vm.mmap_rnd_compat_bits \
  net.core.bpf_jit_harden kernel.unprivileged_bpf_disabled kernel.yama.ptrace_scope \
  vm.swappiness
```

## 🔄 Compatibility

### 🐧 Linux Kernel Version
- The sysctl rules are kernel parameters that work on any distribution with a modern kernel (>=4.x).
- Some options like `io_uring_disabled` or `bpf_jit_harden` require relatively recent kernels (>=5.x for io_uring).

### 💻 System Architecture
- Configurations like `vm.mmap_rnd_bits=32` are specific to 64-bit architectures.
- On 32-bit systems, the maximum allowed value is lower.

### 🖥️ Distribution Base Configuration
- **Security-focused distributions**  
  Fedora (SELinux) or Whonix already have many of these protections enabled by default.
  
- **General-purpose distributions**  
  Debian, Ubuntu, or Linux Mint require more manual adjustments.
  
- **Minimalist distributions**  
  Alpine Linux may have different default behaviors.

### 🔍 Compatibility Verification

#### Check if a parameter exists
```bash
sysctl --all | grep "parameter"
```

#### Check kernel version
```bash
uname -r
```

#### Check system architecture
```bash
uname -m
```

> **Important note**: 
> - This configuration was tested on Debian/Ubuntu-based distributions.
> - Arch Linux, having a more up-to-date kernel, might have different default values.
> - Always verify compatibility with your specific kernel and test in a controlled environment before implementing changes in production.

## 📌 Other Recommendations

### 🧱🔥 Firewall

Use a [firewall](https://en.wikipedia.org/wiki/Firewall_(computing)) and customize it according to your needs. On Ubuntu and its derivatives, **gufw** (GUI uncomplicated firewall) and **ufw** (uncomplicated firewall) are quite simple options to start implementing a firewall on your system and learn how a firewall works.

### 🔒 VPN

Consider using a [VPN](https://en.wikipedia.org/wiki/Virtual_private_network) to encrypt your traffic and protect your online privacy. There are several options available, both open source and commercial, that you can implement on your system.

The most secure and private options are:

- [MullvadVPN](https://mullvad.net/en)
- [ProtonVPN](https://protonvpn.com)
- [IVPN](https://www.ivpn.net)

### 📚 Guides

Privacy and security are fundamental for human beings, and using the wrong tools can put you at risk. Here are some sites you can visit to improve your online privacy and security:

- [PrivacyGuides](https://www.privacyguides.org/)
- [AwesomePrivacy](https://awesome-privacy.xyz/)
- [Personal Security Checklist](https://github.com/Lissy93/personal-security-checklist/blob/HEAD/CHECKLIST.md)

### 💬 Reddit/Others

Forums and other online communities can be valuable resources for obtaining information and advice about privacy and security. Some recommended subreddits are:

- [r/privacy](https://www.reddit.com/r/privacy/)
- [r/degoogle](https://www.reddit.com/r/degoogle/)
- [r/PrivacyGuides](https://www.reddit.com/r/PrivacyGuides/)

> ### ⚠️ **Important Note**
> 
> - **DISCLAIMER**: The application of these configuration settings is done at the user's own risk. While these parameters are well-documented and applied at the kernel level, they come with no warranty of operation.
> 
> - It is the user's responsibility to verify the results and compatibility on their own system before applying them in a production environment.
