# 👤 Network Privacy and Anonymity

This module collects practical configurations and scripts to mitigate tracking on physical networks, protect DNS name resolution, configure local anonymity proxies, and establish efficient firewall rules using a simple approach.

---

## 🛜 1. MAC Address Spoofing (MAC Randomization)

Each network interface card has a unique 48-bit physical identifier known as a MAC address. When you connect to public or corporate Wi-Fi networks, this identifier allows persistent tracking of your device.

### NetworkManager Configuration

The cleanest way on modern distributions (such as Arch Linux, Debian, Ubuntu) is to configure **NetworkManager** to automatically randomize the MAC address during both network scanning and connection phases.

The [`mac_spoofer.sh`](./mac_spoofer.sh) script creates the following configuration file `/etc/NetworkManager/conf.d/30-mac-randomization.conf`:

```ini
[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
```

_This generates a different random MAC address every time you associate with a Wi-Fi network or connect an Ethernet cable._

---

## 🔒 2. Secure DNS (DNS over TLS - DoT)

By default, DNS queries are sent in plaintext (port 53), which allows your ISP or a local attacker (MITM) to view and log all the domains you visit, and even manipulate the responses (DNS Spoofing).

**DNS over TLS (DoT)** encrypts all DNS queries within a secure TLS session (port 853).

### Native Configuration with `systemd-resolved`

`systemd-resolved` is the cleanest and lightest way to implement DoT on modern systems without heavy additional software.

1. Edit the `/etc/systemd/resolved.conf` file by configuring secure DNS servers supporting DoT and DNSSEC (e.g., **Quad9** without logs and with malware filtering, or **Mullvad**):

   ```ini
   [Resolve]
   DNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net
   FallbackDNS=45.90.28.0#dns.nextdns.io
   Domains=~.
   DNSOverTLS=yes
   DNSSEC=yes
   ```

   * The `Domains=~.` parameter instructs `resolved` to send all DNS queries to the configured server.
   * `DNSSEC=yes` enables client-side cryptographic validation of DNSSEC signatures to guarantee record integrity and authenticity (preventing cache poisoning and spoofing). If your ISP or local network strips or alters these signatures, DNS resolution will fail for security. If you prefer fallback compatibility in networks hostile to DNSSEC, use `allow-downgrade`.

2. Restart and enable the service:

   ```bash
   sudo systemctl restart systemd-resolved
   sudo systemctl enable systemd-resolved
   ```

3. Verify the status and TLS encryption with:

   ```bash
   resolvectl status
   ```

---

## 🧅 3. Tor Routing (CLI Anonymity)

To browse or perform queries completely anonymously, you can use the **Tor** network as a local proxy.

### Installation

- **Arch Linux:** `sudo pacman -S tor torsocks`
- **Debian/Ubuntu:** `sudo apt install tor torsocks`

### Start the Local Service

```bash
sudo systemctl start tor
sudo systemctl enable tor
```

_Tor will run a local SOCKS5 proxy by default on `127.0.0.1:9050`._

### Usage in Terminal

To force any terminal command to route its traffic through the Tor proxy transparently, prepend the `torsocks` utility:

```bash
# Example: Verify your external IP address
torsocks curl https://check.torproject.org/api/ip
```

---

## 🧱🔥 4. Simple Firewall and VPN Kill-Switch with UFW

**UFW** (Uncomplicated Firewall) is a user-friendly frontend to manage firewall rules in Linux without the complexity of writing raw iptables or nftables rules.

### Installation and Basic Configuration

1. Install the package:

   ```bash
   # Arch Linux
   sudo pacman -S ufw
   # Debian/Ubuntu
   sudo apt install ufw
   ```

2. Set strict default policies (block all incoming, allow outgoing):

   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```

3. Enable the firewall:

   ```bash
   sudo ufw enable
   sudo systemctl enable ufw
   ```

### 🔒 Implementing a VPN Kill-Switch

If you use a VPN (like OpenVPN or WireGuard) and it disconnects, your system will continue sending traffic through your normal physical network interface by default, exposing your real IP (traffic leak). A **Kill-Switch** blocks all outgoing traffic if it does not pass through the VPN tunnel.

The [`ufw_setup.sh`](./ufw_setup.sh) script automates this behavior as follows:

1. Allows exclusive outgoing connection to your VPN server IP through your physical interface.
2. Allows all incoming and outgoing traffic through the VPN interface (e.g., `tun0` or `wg0`).
3. Blocks any other outgoing traffic attempts through your normal physical network interface (e.g., `wlan0` or `eth0`).
