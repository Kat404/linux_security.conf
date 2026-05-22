# 🛡️ System Hardening and Auditing

Hardening is the process of securing an operating system by reducing its vulnerability surface through disabling unnecessary features and ports, applying strict access control policies, and constant monitoring.

This module collects guides and scripts to audit and harden Linux systems based on industry standards.

---

## 🔍 1. System Auditing with Lynis

**Lynis** is one of the most trusted and recommended FOSS security auditing tools for Unix-like systems. It performs an exhaustive scan looking for vulnerabilities, misconfigurations, and hardening opportunities.

### Installation

- **Arch Linux:** `sudo pacman -S lynis`
- **Debian/Ubuntu:** `sudo apt install lynis`

### Run a Complete Audit

Execute the audit as superuser so Lynis has access to kernel and system configuration files:

```bash
sudo lynis audit system
```

Upon completing the scan, Lynis will:

1. Generate a **Hardening Index** (a numerical security robustness rating).
2. Provide a detailed report with warnings (`Warnings`) and suggestions (`Suggestions`).
3. Log full details in `/var/log/lynis.log` and `/var/log/lynis-report.dat`.

---

## 🔒 2. SSH Hardening (Secure Shell)

The SSH service (`sshd`) is often the primary remote entry point to a server. Configuring it properly is crucial to prevent intrusions.

### Key Best Practices in `/etc/ssh/sshd_config`

- **Disable password authentication:** Force the exclusive use of cryptographic keys (SSH Keys).

  ```ini
  PasswordAuthentication no
  PubkeyAuthentication yes
  ```

- **Disable root login:** Prevent the superuser from logging in directly.

  ```ini
  PermitRootLogin no
  ```

- **Disable X11 Forwarding:** Avoid forwarding GUI interfaces if the server is CLI-only.

  ```ini
  X11Forwarding no
  ```

- **Disable empty passwords:**

  ```ini
  PermitEmptyPasswords no
  ```

- **Restrict encryption and KEX algorithms:** Use only modern algorithms based on elliptic curve cryptography:

  ```ini
  # Modern strong cryptography (KEX & Ciphers)
  KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
  MACs hmac-sha2-512-etm@openssh.com
  ```

*You can use the [`ssh_hardening.sh`](./ssh_hardening.sh) script to generate or apply these directives automatically.*

---

## 🔌 3. Disabling Obsolete Kernel Modules

To reduce the kernel's attack surface, you should disable the loading of uncommon network protocol drivers or unnecessary physical ports (which a physical attacker could exploit using malicious USB devices, for example).

### Disabling via Modprobe

Create a file under `/etc/modprobe.d/blacklist.conf` or `/etc/modprobe.d/99-unused-protocols.conf` using the `install <module> /bin/true` instruction. This tricks the system into believing the module loaded successfully while doing nothing in reality.

**Recommended obsolete/insecure network modules to disable:**

```ini
# Disable unused network protocols
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true

# Disable old/obsolete filesystems
install cramfs /bin/true
install freevxfs /bin/true
install hfs /bin/true
install hfsplus /bin/true
install jffs2 /bin/true
install squashfs /bin/true (Optional, keep if you use Snap/Flatpak)
install udf /bin/true

# Disable USB storage on critical servers (physical security enforcement)
# install usb-storage /bin/true
```
