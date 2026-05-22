# 📦 Container Security with Podman (Rootless)

**Podman** (Pod Manager) is an open-source, daemonless container engine developed by Red Hat. Unlike Docker, which traditionally requires a daemon running as root (`dockerd`), Podman is designed to run entirely in unprivileged user space (**Rootless**).

This module provides guides and automation to implement secure containers using the principle of least privilege.

---

## 🛡️ Why Podman Rootless?

1. **No daemon running as root:** Docker requires a daemon with superuser privileges. If an attacker compromises the Docker daemon, they gain root access to the host. Podman interacts directly with the kernel through ordinary system calls.
2. **Rootless by design:** Containers run under the UID of the user who launches them. A container escape will leave the attacker with the privileges of a standard user on the host, not root.
3. **Native Systemd Integration:** Podman generates clean systemd service files to manage container life cycles as user services.
4. **Namespace Support:** It uses user namespaces to map UID `0` (root) inside the container to an unprivileged UID on the host.

---

## ⚙️ Host Requirements and Configuration

To allow an unprivileged user to run Podman in rootless mode, user namespaces must be configured.

### 1. Installation on Arch Linux

```bash
sudo pacman -S podman dbus-user-session slirp4netns
```

### 2. Configure `/etc/subuid` and `/etc/subgid`

These files define the ranges of user and group IDs that the user is allowed to use inside containers.

Edit `/etc/subuid` and `/etc/subgid` adding a range for your user (for example, 65,536 IDs starting from ID 100,000):

```text
# Format: username:initial_range:id_count
josel:100000:65536
```

### 3. Enable Kernel Namespaces (if applicable)

On Arch Linux, unprivileged user namespaces are enabled by default in the kernel. You can verify this with:

```bash
sysctl kernel.unprivileged_userns_clone
```

If it returns `1`, it is enabled. If it returns `0` or does not exist, add it to your sysctl files:

```ini
kernel.unprivileged_userns_clone=1
```

---

## 🔒 Best Practices when Running Containers

Even with Podman Rootless, you should apply hardening principles when launching containers:

### 1. Reduce Kernel Capabilities

By default, containers inherit several kernel capabilities. Disable all of them and add only the required ones:

```bash
# Example: Disable all and enable only NET_BIND_SERVICE
podman run --cap-drop=all --cap-add=net_bind_service -d nginx
```

### 2. Read-Only Container Mode

Prevents an attacker from modifying binaries or scripts inside the container if they manage to gain entry:

```bash
podman run --read-only -d nginx
```

_Note: If the application needs to write to temporary directories, mount a `tmpfs` volume:_

```bash
podman run --read-only --tmpfs /tmp --tmpfs /run -d nginx
```

### 3. Do Not Use the Privileged Flag (`--privileged`)

Using `--privileged` disables all security protections of Podman (including Seccomp and AppArmor/SELinux profiles), giving near-total access to the host hardware and kernel. **Never use it in production.**

### 4. Limit Resources

Prevent local Denial of Service (DoS) attacks by limiting memory and CPU usage:

```bash
podman run --memory=512m --cpus=1.0 -d nginx
```

---

## ⚙️ Configuration Methods

You can configure the environment using either the automated script or by performing the steps manually for granular system control.

### Option 1: Script Automation

The [`podman_setup.sh`](./podman_setup.sh) script validates the environment safely, calculates free ID ranges, and applies the basic configuration.

1. Grant execution permissions:

   ```bash
   chmod +x podman_setup.sh
   ```

2. Run the script (it will prompt for `sudo` privileges only when necessary):

   ```bash
   ./podman_setup.sh
   ```

---

### Option 2: Step-by-Step Manual Configuration (DIY)

If you prefer to configure everything yourself from scratch:

#### 1. Install necessary packages

On Arch Linux-based distributions, install the required packages for network routing and user session management:

```bash
sudo pacman -S podman dbus-user-session slirp4netns
```

#### 2. Calculate and assign secondary UID/GID ranges

To avoid ID collisions with existing users, find the first free ID range on your system:

```bash
# Get the last assigned ID in /etc/subuid
awk -F: '{print $2+$3}' /etc/subuid | sort -n | tail -n1
```

- If the output is empty, you can use `100000` as your start ID.
- If it returns a number (e.g., `165536`), use that number as your start ID.

Assign a range of 65,536 IDs to your user in `/etc/subuid` and `/etc/subgid`:

```bash
# Replace '100000' with the free start ID calculated above if different
echo "$USER:100000:65536" | sudo tee -a /etc/subuid
echo "$USER:100000:65536" | sudo tee -a /etc/subgid
```

#### 3. Enable user namespaces in the kernel

Verify if they are active:

```bash
sysctl kernel.unprivileged_userns_clone
```

If the command doesn't exist or returns `0`, configure it persistently:

```bash
echo "kernel.unprivileged_userns_clone=1" | sudo tee /etc/sysctl.d/99-userns.conf
sudo sysctl --system
```

#### 4. Verify user environment (XDG)

Ensure the `$XDG_RUNTIME_DIR` environment variable is defined in your current session:

```bash
echo $XDG_RUNTIME_DIR
```

This should return a valid path like `/run/user/1000`. If empty, temporarily export the variable in your shell configuration file (e.g., `.bashrc` or `config.nu`):

```bash
export XDG_RUNTIME_DIR="/run/user/$(id -u)"
```

#### 5. Apply changes and validate

If you have run Podman prior to configuring subuids, migrate the existing container database:

```bash
podman system migrate
```

Finally, run a test container to verify rootless operations:

```bash
podman run --rm alpine echo "Rootless Podman is working!"
```
