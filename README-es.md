# 🐧 🛡️ Guía de Configuración de Seguridad en Linux

<div align="left">
  <a href="./README.md">
    <img src="https://img.shields.io/badge/English_README-1a5fb4?style=for-the-badge&logo=googletranslate&logoColor=white" alt="English README">
  </a>
</div>

Este repositorio contiene configuraciones de seguridad para sistemas Linux (distribuciones basadas en Debian) que ayudan a proteger contra varios ataques y mejoran la seguridad del sistema.

## ¿Qué es `99-linux-security-es.conf`?

El archivo `99-linux-security-es.conf` es un archivo de configuración del sistema que establece varios parámetros del kernel para mejorar la seguridad total y completa del sistema usando sysctl. Contiene ajustes cuidadosamente configurados divididos en varias secciones, cada una abordando preocupaciones específicas de seguridad.

## Secciones de Configuración y Su Propósito

### 1. Protecciones contra Suplantación y Filtrado de Rutas

- **rp_filter**: Configura el filtrado de ruta inversa para prevenir ataques de suplantación IP.
  - Establecido en modo 2 (flexible) para mejor compatibilidad con VPNs y enrutamiento asimétrico.
  - Se aplica tanto a IPv4 como IPv6.

### 2. Protección contra DoS y Inundaciones SYN

- **tcp_syncookies**: Habilita protección contra ataques de inundación SYN.
- **icmp_echo_ignore_broadcasts**: Previene intentos de ataque Smurf/DoS.
- **icmp_ignore_bogus_error_responses**: Mejora la privacidad ignorando errores ICMP sospechosos.
- **icmp_echo_ignore_all (IPv4) / icmp.echo_ignore_all (IPv6)**: Ignora todos los pings entrantes para modo sigilo sin afectar la conectividad de VPN.

### 3. Protección contra Redirecciones ICMP y Ataques MITM

- Deshabilita la aceptación y envío de redirecciones ICMP para prevenir ataques de intermediario.
- Aplica medidas de seguridad tanto para IPv4 como IPv6.

### 4. Reenvío y Enrutamiento Avanzado

- **ip_forward**: Deshabilita el reenvío IP para evitar que la máquina actúe como router.
- Bloquea el enrutamiento de origen para prevenir la manipulación de rutas por atacantes.

### 5. Registro y Detección

- **log_martians**: Opción para registrar paquetes inválidos/suplantados para monitoreo de seguridad.

### 6. Optimizaciones TCP y Anti-Huella Digital

- **tcp_timestamps**: Puede deshabilitarse para reducir la huella digital del SO.
- Deshabilita SACK y D-SACK para reducir la superficie de ataque del kernel (FACK fue eliminado por depender de SACK).

### 7. Controles IPv6

- Opciones para deshabilitar IPv6 si no se necesita, reduciendo la superficie de ataque.
- **use_tempaddr**: Habilita extensiones de privacidad IPv6 (RFC 4941) generando direcciones temporales aleatorias para mejorar la privacidad.

### 8. Protecciones de TTY y Disciplinas de Línea

- Previene la carga automática de disciplinas de línea en TTY para reducir la superficie de ataque.
- Utiliza **dev.tty.ldisc_autoload** para controlar este comportamiento.

### 9. Protecciones de Sistemas de Archivos

- Endurecimiento contra interacciones maliciosas con archivos, incluyendo symlinks, hardlinks, FIFOs y archivos regulares.
- Implementa protecciones a través de **fs.protected_fifos**, **fs.protected_hardlinks**, **fs.protected_regular** y **fs.protected_symlinks**.
- **fs.binfmt_misc.status**: Deshabilita el soporte para ejecutar binarios no nativos si no se requiere (reduce superficie de ataque del kernel).
- **fs.suid_dumpable**: Previene que procesos SUID generen core dumps con información sensible.

### 10. Restricciones de Acceso al Kernel

- Restringe el acceso a información y funciones del kernel para reducir la superficie de explotación.
- Utiliza **kernel.dmesg_restrict**, **kernel.io_uring_disabled**, **kernel.kexec_load_disabled**, **kernel.kptr_restrict**, **kernel.perf_event_paranoid** y **kernel.slab_merging**.
- Controles adicionales del kernel: **kernel.sysrq**, **kernel.oops_limit**, **kernel.warn_limit**, **kernel.panic**, **kernel.printk**, **kernel.core_pattern** para reforzar seguridad y reducir fugas de información.
- **vm.unprivileged_userfaultfd**: Deshabilita userfaultfd para usuarios no privilegiados, mitigando vulnerabilidades de tipo use-after-free.

### 11. Protecciones Avanzadas de Red y TCP

- Endurece la pila TCP y previene redirecciones no deseadas.
- Implementa protecciones mediante **net.ipv4.tcp_rfc1337** y **net.ipv4.conf.*.shared_media**.
- Endurecimiento ARP en LAN: **net.ipv4.conf.*.arp_filter**, **net.ipv4.conf.*.arp_ignore**, **net.ipv4.conf.all.drop_gratuitous_arp** para mitigar ARP spoofing/MITM.

### 12. Aleatorización de Memoria (ASLR)

- Aumenta significativamente la aleatorización del diseño de memoria para dificultar los exploits.
- Utiliza **vm.mmap_rnd_bits** y **vm.mmap_rnd_compat_bits** para un ASLR mejorado.

### 13. Protecciones BPF y Namespaces de Usuario

- Endurece el compilador JIT de BPF y restringe su uso a usuarios privilegiados.
- Implementa **net.core.bpf_jit_harden**, **kernel.unprivileged_bpf_disabled** y **kernel.yama.ptrace_scope**.
- Nota: Las restricciones de namespaces de usuario están comentadas por defecto para mantener compatibilidad con Flatpak y contenedores.

### 14. Optimizaciones de Memoria y Swap

- Optimiza la gestión de memoria reduciendo la tendencia a usar swap en sistemas con suficiente RAM.
- Controlado por el parámetro **vm.swappiness**.

## 🚀 Guía de Implementación

1. Abre una terminal.

2. Crea el archivo de configuración con privilegios de root:

   ```bash
   sudo nano /etc/sysctl.d/99-linux-security-es.conf
   ```

   (Puedes usar tu editor preferido como vim o gedit con sudo)

3. Copia y Pega el contenido del archivo [`99-linux-security-es.conf`](./99-linux-security-es.conf), modifica la configuración según tus necesidades.

4. Guarda y cierra el editor (en nano: Ctrl+O, Enter, Ctrl+X).

5. Aplica los cambios usando uno de estos métodos:

   **Método 1**: Aplicar todas las configuraciones de sysctl (recomendado para la mayoría de usuarios)

   ```bash
   sudo sysctl --system
   ```

   **Método 2**: Aplicar solo esta configuración específica

   ```bash
   sudo sysctl -p /etc/sysctl.d/99-linux-security-es.conf
   ```

## 🔍 Verificación de los Cambios

Puedes verificar la configuración aplicada usando cualquiera de estos comandos:

### Versión Completa (de todo el Sistema)

```bash
sysctl -a | grep -E '
net\.ipv4\.conf\.(all|default)\.(rp_filter|accept_redirects|send_redirects|accept_source_route|log_martians|shared_media)
|net\.ipv4\.(tcp_syncookies|icmp_echo_ignore_broadcasts|icmp_ignore_bogus_error_responses|icmp_echo_ignore_all|ip_forward|tcp_timestamps|tcp_sack|tcp_dsack|tcp_rfc1337)
|net\.ipv6\.conf\.(all|default)\.(rp_filter|accept_redirects|accept_source_route|disable_ipv6|use_tempaddr)
|net\.ipv6\.icmp\.echo_ignore_all
|dev\.tty\.ldisc_autoload
|fs\.(protected_fifos|protected_hardlinks|protected_regular|protected_symlinks|binfmt_misc\.status|suid_dumpable)
|kernel\.(dmesg_restrict|io_uring_disabled|kexec_load_disabled|kptr_restrict|perf_event_paranoid|slab_merging|sysrq|oops_limit|warn_limit|panic|printk|core_pattern)
|kernel\.yama\.ptrace_scope
|net\.core\.bpf_jit_harden
|kernel\.unprivileged_bpf_disabled
|vm\.(mmap_rnd_bits|mmap_rnd_compat_bits|swappiness|unprivileged_userfaultfd)
|net\.ipv4\.conf\.\*\.(arp_filter|arp_ignore)
|net\.ipv4\.conf\.all\.drop_gratuitous_arp'
```

### Versión Detallada

```bash
sysctl \
  net.ipv4.conf.default.rp_filter net.ipv4.conf.all.rp_filter \
  net.ipv6.conf.default.rp_filter net.ipv6.conf.all.rp_filter \
  net.ipv4.tcp_syncookies net.ipv4.icmp_echo_ignore_broadcasts net.ipv4.icmp_ignore_bogus_error_responses \
  net.ipv4.icmp_echo_ignore_all net.ipv6.icmp.echo_ignore_all \
  net.ipv4.conf.all.accept_redirects net.ipv4.conf.default.accept_redirects net.ipv4.conf.all.send_redirects \
  net.ipv6.conf.all.accept_redirects net.ipv6.conf.default.accept_redirects \
  net.ipv4.ip_forward net.ipv4.conf.all.accept_source_route net.ipv4.conf.default.accept_source_route \
  net.ipv6.conf.all.accept_source_route net.ipv6.conf.default.accept_source_route \
  net.ipv4.conf.all.log_martians net.ipv4.tcp_timestamps net.ipv4.tcp_sack net.ipv4.tcp_dsack \
  net.ipv6.conf.all.disable_ipv6 net.ipv6.conf.default.disable_ipv6 \
  net.ipv6.conf.all.use_tempaddr net.ipv6.conf.default.use_tempaddr \
  dev.tty.ldisc_autoload \
  fs.protected_fifos fs.protected_hardlinks fs.protected_regular fs.protected_symlinks \
  fs.binfmt_misc.status fs.suid_dumpable \
  kernel.dmesg_restrict kernel.io_uring_disabled kernel.kexec_load_disabled kernel.kptr_restrict kernel.perf_event_paranoid kernel.slab_merging \
  kernel.sysrq kernel.oops_limit kernel.warn_limit kernel.panic kernel.printk kernel.core_pattern \
  net.ipv4.tcp_rfc1337 net.ipv4.conf.all.shared_media net.ipv4.conf.default.shared_media \
  net.ipv4.conf.all.drop_gratuitous_arp \
  vm.mmap_rnd_bits vm.mmap_rnd_compat_bits \
  net.core.bpf_jit_harden kernel.unprivileged_bpf_disabled kernel.yama.ptrace_scope \
  vm.unprivileged_userfaultfd \
  vm.swappiness
```

## 🔄 Compatibilidad

### 🐧 Versión del Kernel Linux

- Las reglas de sysctl son parámetros del kernel que funcionan en cualquier distribución con un kernel moderno (>=4.x).
- Algunas opciones como `io_uring_disabled` o `bpf_jit_harden` requieren kernels más recientes (>=5.x para io_uring).

### 💻 Arquitectura del Sistema

- Configuraciones como `vm.mmap_rnd_bits=32` son específicas para arquitecturas de 64 bits.
- En sistemas de 32 bits, el valor máximo permitido es menor.

### 🖥️ Configuración Base de la Distribución

- **Distribuciones orientadas a seguridad**  
  Fedora (SELinux) o Whonix ya tienen muchas de estas protecciones habilitadas por defecto.
  
- **Distribuciones de propósito general**  
  Debian, Ubuntu o Linux Mint requieren más ajustes manuales.
  
- **Distribuciones minimalistas**  
  Alpine Linux puede tener comportamientos diferentes por defecto.

### 🔍 Verificación de Compatibilidad

#### Verificar si un parámetro existe

```bash
sysctl --all | grep "parámetro"
```

#### Verificar versión del kernel

```bash
uname -r
```

#### Verificar arquitectura del sistema

```bash
uname -m
```

> **Nota importante**:

> - Esta configuración fue probada en distribuciones basadas en Debian/Ubuntu.
> - Arch Linux, al tener un kernel más actualizado, podría tener valores predeterminados diferentes.
> - Siempre verifica la compatibilidad con tu kernel específico y realiza pruebas en un entorno controlado antes de implementar los cambios en producción.

## 📌 Otras Recomendaciones

### 🧱🔥 Firewall

Utiliza un [firewall](https://es.wikipedia.org/wiki/Cortafuegos_(inform%C3%A1tica)) y personalízalo según tus necesidades. En Ubuntu y sus derivados está **gufw** (GUI uncomplicated firewall) y **ufw** (uncomplicated firewall) que son opciones bastante sencillas para empezar a implementar un firewall en tu sistema y aprender el cómo funciona un firewall.

### 🔒 VPN

Considera el uso de una [VPN](https://es.wikipedia.org/wiki/Red_privada_virtual) para cifrar tu tráfico y proteger tu privacidad en línea. Hay varias opciones disponibles, tanto de código abierto como comerciales, que puedes implementar en tu sistema.

   Las opciones más seguras y privadas son:

- [MullvadVPN](https://mullvad.net/es/)
- [ProtonVPN](https://protonvpn.com/es/)
- [IVPN](https://www.ivpn.net/es)

### 📚 Guías

La privacidad y la seguridad son algo fundamental para el ser humano y el utilizar las herramientas incorrectas puede llegar a ponerte en riesgo, a continuación, te dejo algunos sitios que puedes visitar para poder mejorar tu privacidad y seguridad en línea:

- [PrivacyGuides](https://www.privacyguides.org/es/)
- [AwesomePrivacy](https://awesome-privacy.xyz/)
- [Personal Security Checklist](https://github.com/Lissy93/personal-security-checklist/blob/HEAD/CHECKLIST.md)

### 💬 Reddit/Demás

Los foros y demás comunidades en línea pueden ser recursos valiosos para obtener información y consejos sobre privacidad y seguridad. Algunos subreddits recomendados son:

- [r/privacy](https://www.reddit.com/r/privacy/)
- [r/degoogle](https://www.reddit.com/r/degoogle/)
- [r/PrivacyGuides](https://www.reddit.com/r/PrivacyGuides/)

> ### ⚠️ **Nota Importante**
> 
> - **AVISO DE RESPONSABILIDAD**: La aplicación de estos ajustes de configuración se realiza bajo la responsabilidad del usuario. Aunque estos parámetros están bien documentados y se aplican a nivel del kernel, no vienen con ninguna garantía de funcionamiento.
> 
> - Es responsabilidad del usuario verificar los resultados y la compatibilidad en su propio sistema antes de aplicarlos en un entorno de producción.
