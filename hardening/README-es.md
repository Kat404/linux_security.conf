# 🛡️ Hardening y Auditoría de Sistemas

El **Hardening** (endurecimiento) es el proceso de asegurar un sistema operativo reduciendo su superficie de vulnerabilidad mediante la desactivación de funciones y puertos innecesarios, la aplicación de políticas estrictas de control de acceso y el monitoreo constante.

Este módulo recopila guías y scripts para auditar y endurecer sistemas Linux basados en estándares de la industria.

---

## 🔍 1. Auditoría del Sistema con Lynis

**Lynis** es una de las herramientas de auditoría de seguridad FOSS más confiables y recomendadas para sistemas tipo Unix. Realiza un escaneo exhaustivo en busca de vulnerabilidades, configuraciones incorrectas y oportunidades de endurecimiento.

### Instalación

- **Arch Linux:** `sudo pacman -S lynis`
- **Debian/Ubuntu:** `sudo apt install lynis`

### Ejecutar una Auditoría Completa

Ejecuta la auditoría como superusuario para que Lynis tenga acceso a los archivos de configuración del kernel y del sistema:

```bash
sudo lynis audit system
```

Al finalizar el escaneo, Lynis:

1. Generará un **Hardening Index** (índice numérico de robustez de seguridad).
2. Proporcionará un informe detallado con advertencias (`Warnings`) y sugerencias (`Suggestions`).
3. Registrará los detalles completos en `/var/log/lynis.log` y `/var/log/lynis-report.dat`.

---

## 🔒 2. Endurecimiento de SSH (Secure Shell)

El servicio SSH (`sshd`) suele ser la principal puerta de entrada remota a un servidor. Configurarlo adecuadamente es crucial para prevenir intrusiones.

### Buenas Prácticas Clave en `/etc/ssh/sshd_config`

- **Deshabilitar autenticación por contraseña:** Forzar exclusivamente el uso de llaves criptográficas (SSH Keys).

  ```ini
  PasswordAuthentication no
  PubkeyAuthentication yes
  ```

- **Deshabilitar el login de root:** Impedir que el superusuario acceda directamente de forma remota.

  ```ini
  PermitRootLogin no
  ```

- **Deshabilitar X11 Forwarding:** Evitar el reenvío de interfaces gráficas si el servidor es CLI.

  ```ini
  X11Forwarding no
  ```

- **Deshabilitar contraseñas vacías:**

  ```ini
  PermitEmptyPasswords no
  ```

- **Restringir algoritmos de cifrado y KEX:** Usar solo algoritmos modernos basados en criptografía de curva elíptica:

  ```ini
  # Criptografía fuerte moderna (KEX y Cifrados)
  KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
  Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
  MACs hmac-sha2-512-etm@openssh.com
  ```

_Puedes usar el script [`ssh_hardening.sh`](./ssh_hardening.sh) para generar o aplicar automáticamente estas directivas._

---

## 🔌 3. Inhabilitación de Módulos del Kernel Obsoletos

Para reducir la superficie de ataque del kernel, se debe deshabilitar la carga de controladores de protocolos de red poco comunes o puertos físicos innecesarios (que un atacante físico podría explotar, por ejemplo, mediante dispositivos USB maliciosos).

### Desactivación mediante Modprobe

Crea un archivo en `/etc/modprobe.d/blacklist.conf` o `/etc/modprobe.d/99-unused-protocols.conf` utilizando la instrucción `install <modulo> /bin/true`. Esto engaña al sistema haciéndole creer que el módulo se cargó con éxito pero sin hacer nada real.

**Módulos de red obsoletos/inseguros recomendados para deshabilitar:**

```ini
# Deshabilitar protocolos de red no utilizados
install dccp /bin/true
install sctp /bin/true
install rds /bin/true
install tipc /bin/true

# Deshabilitar sistemas de archivos antiguos/obsoletos
install cramfs /bin/true
install freevxfs /bin/true
install hfs /bin/true
install hfsplus /bin/true
install jffs2 /bin/true
install squashfs /bin/true (Opcional, mantener si usas Snap/Flatpak)
install udf /bin/true

# Deshabilitar almacenamiento USB en servidores críticos (fuerza de seguridad física)
# install usb-storage /bin/true
```
