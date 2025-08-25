# 🐧 🛡️ Linux Network Security Configuration Guide

[README en Español](./README.es.md)

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

## 🚀 Implementation Guide

1. Open a terminal.

2. Create the configuration file with root privileges:

   ```bash
   sudo nano /etc/sysctl.d/99-network-security.conf
   ```

   (You can use your preferred editor like vim or gedit with sudo)

3. Copy and Paste the contents of [`99-network-security.conf`](./99-network-security.conf), modify the configuration according to your needs.

4. Save and close the editor (in nano: Ctrl+O, Enter, Ctrl+X).

5. Apply the changes:

   ```bash
   sudo sysctl --system
   ```

## 🔍 Verifying the Changes

You can verify the applied settings using either of these commands:

### Compact Version

```bash
sysctl -a | grep -E 'net\.ipv4\.conf\.(all|default)\.(rp_filter|accept_redirects|send_redirects|accept_source_route|log_martians)|net\.ipv4\.(tcp_syncookies|icmp_echo_ignore_broadcasts|icmp_ignore_bogus_error_responses|ip_forward|tcp_timestamps|tcp_sack|tcp_dsack|tcp_fack)|net\.ipv6\.conf\.(all|default)\.(rp_filter|accept_redirects|accept_source_route|disable_ipv6)'
```

### Detailed Version

```bash
sysctl net.ipv4.conf.default.rp_filter net.ipv4.conf.all.rp_filter net.ipv6.conf.default.rp_filter net.ipv6.conf.all.rp_filter net.ipv4.tcp_syncookies net.ipv4.icmp_echo_ignore_broadcasts net.ipv4.icmp_ignore_bogus_error_responses net.ipv4.conf.all.accept_redirects net.ipv4.conf.default.accept_redirects net.ipv4.conf.all.send_redirects net.ipv6.conf.all.accept_redirects net.ipv6.conf.default.accept_redirects net.ipv4.ip_forward net.ipv4.conf.all.accept_source_route net.ipv4.conf.default.accept_source_route net.ipv6.conf.all.accept_source_route net.ipv6.conf.default.accept_source_route net.ipv4.conf.all.log_martians net.ipv4.tcp_timestamps net.ipv4.tcp_sack net.ipv4.tcp_dsack net.ipv4.tcp_fack net.ipv6.conf.all.disable_ipv6 net.ipv6.conf.default.disable_ipv6
```

## Other Recommendations

### Firewall

Use a [firewall](https://en.wikipedia.org/wiki/Firewall_(computing)) and customize it according to your needs. On Ubuntu and its derivatives, **gufw** (GUI uncomplicated firewall) and **ufw** (uncomplicated firewall) are quite simple options to start implementing a firewall on your system and learn how a firewall works.

### VPN

Consider using a [VPN](https://en.wikipedia.org/wiki/Virtual_private_network) to encrypt your traffic and protect your online privacy. There are several options available, both open source and commercial, that you can implement on your system.

The most secure and private options are:

- [MullvadVPN](https://mullvad.net/en)
- [ProtonVPN](https://protonvpn.com)
- [IVPN](https://www.ivpn.net)

### Guides

Privacy and security are fundamental for human beings, and using the wrong tools can put you at risk. Here are some sites you can visit to improve your online privacy and security:

- [PrivacyGuides](https://www.privacyguides.org/)
- [AwesomePrivacy](https://awesome-privacy.xyz/)
- [Personal Security Checklist](https://github.com/Lissy93/personal-security-checklist/blob/HEAD/CHECKLIST.md)

### Reddit/Others

Forums and other online communities can be valuable resources for obtaining information and advice about privacy and security. Some recommended subreddits are:

- [r/privacy](https://www.reddit.com/r/privacy/)
- [r/degoogle](https://www.reddit.com/r/degoogle/)
- [r/PrivacyGuides](https://www.reddit.com/r/PrivacyGuides/)

> **Note**:
>
> - These instructions are specific to Debian-based Linux distributions. For other distributions, please consult with your preferred AI assistant to verify any changes in the procedure and verification process.
> - ⚠️ **DISCLAIMER**: The application of these configuration settings is done at the user's own risk. While these parameters are well-documented and applied at the kernel level, they come with no warranty of operation. It is the user's responsibility to verify the results and compatibility on their own system before applying them in a production environment.
