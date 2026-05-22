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

### ⚙️ Métodos de Aplicación

#### Opción 1: Auditoría y Aplicación con Script

El script [`ssh_hardening.sh`](./ssh_hardening.sh) cuenta con un menú interactivo:

1. Permite realizar una **auditoría pasiva (modo lectura)** que evalúa el estado actual sin aplicar cambios.
2. Aplica las directivas de forma automática, realizando un backup y verificando la sintaxis del archivo antes de reiniciar el daemon.

---

#### Opción 2: Configuración Manual y Verificación (DIY Seguro)

Para modificar el archivo de configuración manualmente sin riesgos de quedar excluido (_lockout_):

1. **Crear una copia de seguridad inmediata:**

   ```bash
   sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
   ```

2. **Editar la configuración:**

   Abre el archivo `/etc/ssh/sshd_config` con privilegios (ej. `sudo hx /etc/ssh/sshd_config`) y ajusta o agrega las directivas del listado anterior.

3. **Verificar la sintaxis de la configuración (¡CRÍTICO!):**

   Antes de recargar o reiniciar el servicio de SSH, comprueba que las directivas ingresadas sean válidas y soportadas por tu versión local de OpenSSH:

   ```bash
   sudo sshd -t
   ```

   - Si el comando devuelve errores, **no reinicies el daemon**. Restaura el archivo original (`sudo cp /etc/ssh/sshd_config.bak /etc/ssh/sshd_config`) y corrige la línea señalada.

4. **Reiniciar el servicio de forma segura:**

   Una vez que el comando `sshd -t` sea silencioso (indica que no hay errores de sintaxis), reinicia el daemon:

   ```bash
   # En Arch Linux / RHEL / Fedora
   sudo systemctl restart sshd

   # En Debian / Ubuntu
   sudo systemctl restart ssh
   ```

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
