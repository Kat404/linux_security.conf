# 🐧 🛡️ Configuración de Seguridad Sysctl

Este subdirectorio contiene parámetros del kernel para mejorar la seguridad total y completa del sistema usando sysctl. Contiene ajustes cuidadosamente configurados divididos en varias secciones, cada una abordando preocupaciones específicas de seguridad.

---

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
- Deshabilita SACK y D-SACK para reducir la superficie de ataque del kernel.

### 7. Controles IPv6

- Opciones para deshabilitar IPv6 si no se necesita, reduciendo la superficie de ataque.
- **use_tempaddr**: Habilita extensiones de privacidad IPv6 (RFC 4941) generando direcciones temporales aleatorias.

### 8. Protecciones de TTY y Disciplinas de Línea

- Previene la carga automática de disciplinas de línea en TTY para reducir la superficie de ataque.
- Utiliza **dev.tty.ldisc_autoload** para controlar este comportamiento.

### 9. Protecciones de Sistemas de Archivos

- Endurecimiento contra interacciones maliciosas con archivos, incluyendo symlinks, hardlinks, FIFOs y archivos regulares.
- Implementa protecciones a través de **fs.protected_fifos**, **fs.protected_hardlinks**, **fs.protected_regular** y **fs.protected_symlinks**.
- **fs.binfmt_misc.status**: Deshabilita el soporte para ejecutar binarios no nativos si no se requiere.
- **fs.suid_dumpable**: Previene que procesos SUID generen core dumps con información sensible.

### 10. Restricciones de Acceso al Kernel

- Restringe el acceso a información y funciones del kernel para reducir la superficie de explotación.
- Utiliza **kernel.dmesg_restrict**, **kernel.io_uring_disabled**, **kernel.kexec_load_disabled**, **kernel.kptr_restrict**, **kernel.perf_event_paranoid** y **kernel.slab_merging**.
- Controles adicionales del kernel: **kernel.sysrq**, **kernel.oops_limit**, **kernel.warn_limit**, **kernel.panic**, **kernel.printk**, **kernel.core_pattern** para reforzar seguridad y reducir fugas de información.
- **vm.unprivileged_userfaultfd**: Deshabilita userfaultfd para usuarios no privilegiados, mitigando vulnerabilidades de tipo use-after-free.

### 11. Protecciones Avanzadas de Red y TCP

- Endurece la pila TCP y previene redirecciones no deseadas.
- Implementa protecciones mediante **net.ipv4.tcp_rfc1337** y **net.ipv4.conf.\*.shared_media**.
- Endurecimiento ARP en LAN: **net.ipv4.conf.\*.arp_filter**, **net.ipv4.conf.\*.arp_ignore**, **net.ipv4.conf.all.drop_gratuitous_arp** para mitigar ARP spoofing/MITM.

### 12. Aleatorización de Memoria (ASLR)

- Aumenta significativamente la aleatorización del diseño de memoria para dificultar los exploits.
- Utiliza **vm.mmap_rnd_bits** y **vm.mmap_rnd_compat_bits** para un ASLR mejorado.

### 13. Protecciones BPF y Namespaces de Usuario

- Endurece el compilador JIT de BPF y restringe su uso a usuarios privilegiados.
- Implementa **net.core.bpf_jit_harden**, **kernel.unprivileged_bpf_disabled** y **kernel.yama.ptrace_scope**.

### 14. Optimizaciones de Memoria y Swap

- Optimiza la gestión de memoria reduciendo la tendencia a usar swap en sistemas con suficiente RAM.
- Controlado por el parámetro **vm.swappiness**.

---

## 🚀 Guía de Implementación

1. Crea el archivo de configuración con privilegios de root:

   ```bash
   sudo cp 99-linux-security-es.conf /etc/sysctl.d/
   ```

2. Aplica los cambios usando uno de estos métodos:

   **Método 1**: Aplicar todas las configuraciones de sysctl (recomendado para la mayoría de usuarios)

   ```bash
   sudo sysctl --system
   ```

   **Método 2**: Aplicar solo esta configuración específica

   ```bash
   sudo sysctl -p /etc/sysctl.d/99-linux-security-es.conf
   ```

---

## 🔍 Verificación de los Cambios

Puedes verificar la configuración aplicada usando cualquiera de los comandos de verificación detallados en los READMEs generales o inspeccionando parámetros individuales mediante:

```bash
sysctl <nombre_del_parametro>
```
