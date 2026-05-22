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

## 🤖 Script Automation

The [`podman_setup.sh`](./podman_setup.sh) script automates environment validation and the initial setup of UID mapping files for your user.

### Run the script:

1. Grant execution permissions:

   ```bash
   chmod +x podman_setup.sh
   ```

2. Run it:

   ```bash
   ./podman_setup.sh
   ```
