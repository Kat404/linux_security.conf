# 🐧 🛡️ Linux Hardening, Security, and Privacy Guide

<div align="left">
  <a href="./README-es.md">
    <img src="https://img.shields.io/badge/README_en_Español-1a5fb4?style=for-the-badge&logo=googletranslate&logoColor=white" alt="README en Español">
  </a>
</div>

This repository is a modular collection of security configurations, practical guides, and Bash automation scripts designed to audit, secure, and optimize Linux operating systems (especially Arch Linux and Debian/Ubuntu-based distributions) against common threats, safeguard physical and digital network privacy, and anonymize metadata.

---

## 🗂️ Repository Structure

The repository is organized in a modular fashion. Each subdirectory contains its own detailed technical guide and corresponding automation scripts:

### 1. ⚙️ [sysctl/](./sysctl) - Kernel and Network Configuration

- **Contents:** Advanced kernel-level tuning via `.conf` configuration files.
- **Focus:** IP Spoofing protections, Deny of Service mitigation (DoS/SYN Floods), ICMP redirects disabling (MITM prevention), LAN ARP hardening, and IPv6 Privacy Extensions.
- **Go to Module:** 👉 [sysctl/README.md](./sysctl/README.md)

### 2. 🛡️ [hardening/](./hardening) - System Auditing & Hardening

- **Contents:** OS-level hardening techniques and system auditing.
- **Focus:** Using the FOSS tool `Lynis` to audit system security robustness, advanced SSH daemon configuration and cryptography (`sshd_config`), and disabling obsolete or unused kernel modules.
- **Go to Module:** 👉 [hardening/README.md](./hardening/README.md)

### 3. 📦 [containers/](./containers) - Container Security (Podman)

- **Contents:** Least-privilege best practices tailored for the Podman ecosystem.
- **Focus:** Running containers in **Rootless** mode (no root privileges on the host), safe mapping of user namespace IDs (`subuid`/`subgid`), dropping Linux capabilities (`--cap-drop`), read-only container execution, and Seccomp profiles.
- **Go to Module:** 👉 [containers/README.md](./containers/README.md)

### 4. 🧹 [exif/](./exif) - Metadata Anonymization

- **Contents:** Automated cleanup of sensitive metadata in media files and documents.
- **Focus:** Practical usage guide for the recommended FOSS tool `mat2` (Metadata Anonymisation Toolkit v2) and a portable Bash script for recursive and automated directory cleaning.
- **Go to Module:** 👉 [exif/README.md](./exif/README.md)

### 5. 👤 [privacy/](./privacy) - Network Privacy & Anonymity

- **Contents:** Privacy enhancements at the network interface and firewall level.
- **Focus:** Automated MAC address randomization in NetworkManager, secure DNS resolution using DNS-over-TLS (DoT) with `systemd-resolved`, selective terminal traffic routing through the Tor network, and a robust UFW Firewall configuration with VPN Kill-Switch rules.
- **Go to Module:** 👉 [privacy/README.md](./privacy/README.md)

---

## 🚀 Project Design Philosophy

- **CLI Portability:** All automation scripts in this repository are written in **pure Bash**, ensuring they run on any modern Linux distribution without complex external dependencies.
- **Privacy-First (FOSS):** We strictly prioritize the use of free, open-source, and privacy-respecting software like `mat2`, `Tor`, `Lynis`, and `Podman`.
- **Educational & Transparent:** Every script and configuration file contains detailed analytical explanations. We believe it is crucial to understand the **"Why"** before applying any changes to your system.

---

## 🔄 Compatibility

- **Operating Systems:** Tested and designed for Arch Linux and Debian/Ubuntu-based distributions.
- **Linux Kernel:** Most parameters require a modern kernel (version `>= 4.x` for basic sysctl, and `>= 5.x` for advanced features like container rootless namespaces or blocking `io_uring`).

---

## 📚 High-Quality Resources and References

To expand your knowledge of Linux security and privacy, we highly recommend checking the official documentation and top-tier resources:

- [Privacy Guides](https://www.privacyguides.org/) - The industry-standard reference for digital privacy and security.
- [Awesome Privacy](https://awesome-privacy.xyz/) - A curated list of privacy-respecting software and services.
- [Lynis Official Site](https://cisofy.com/lynis/) - Official documentation and CIS audit guidelines.
- [Maturity Model for Linux Hardening (MTR)](https://github.com/mzet-/linux-hardening-checklist) - Reference checklist for advanced kernel and userland hardening.
- [Tor Project](https://www.torproject.org/) - Official documentation about the Tor anonymity network and integration.

---

## ⚠️ DISCLAIMER

> Applying the configurations and scripts in this repository is done at the user's own risk. Security is about risk management; hardening a system excessively may break compatibility with certain applications (for example, strict user namespace restrictions may interfere with Flatpak or other sandboxes).
>
> **Always test configurations in a controlled environment (VM) before implementing them in production.**
