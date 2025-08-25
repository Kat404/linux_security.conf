# 🐧 🛡️ Guía de Configuración de Seguridad de Red en Linux

Este repositorio contiene configuraciones de seguridad de red para sistemas Linux (distribuciones basadas en Debian) que ayudan a proteger contra varios ataques de red y mejoran la seguridad del sistema.

## ¿Qué es `99-network-security.conf`?

El archivo `99-network-security.conf` es un archivo de configuración del sistema que establece varios parámetros del kernel para mejorar la seguridad de la red. Contiene ajustes cuidadosamente configurados divididos en varias secciones, cada una abordando preocupaciones específicas de seguridad.

## Secciones de Configuración y Su Propósito

### 1. Protecciones contra Suplantación y Filtrado de Rutas

- **rp_filter**: Configura el filtrado de ruta inversa para prevenir ataques de suplantación IP.
  - Establecido en modo 2 (flexible) para mejor compatibilidad con VPNs y enrutamiento asimétrico.
  - Se aplica tanto a IPv4 como IPv6.

### 2. Protección contra DoS y Inundaciones SYN

- **tcp_syncookies**: Habilita protección contra ataques de inundación SYN.
- **icmp_echo_ignore_broadcasts**: Previene intentos de ataque Smurf/DoS.
- **icmp_ignore_bogus_error_responses**: Mejora la privacidad ignorando errores ICMP sospechosos.

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
- Habilita ACK selectivo, D-SACK y FACK para un rendimiento de red eficiente y seguro.

### 7. Controles IPv6

- Opciones para deshabilitar IPv6 si no se necesita, reduciendo la superficie de ataque.

## 🚀 Guía de Implementación

1. Abre una terminal.

2. Crea el archivo de configuración con privilegios de root:

   ```bash
   sudo nano /etc/sysctl.d/99-network-security.conf
   ```

   (Puedes usar tu editor preferido como vim o gedit con sudo)

3. Copia y Pega el contenido del archivo [`99-network-security-es.conf`](./99-network-security-es.conf), modifica la configuración según tus necesidades.

4. Guarda y cierra el editor (en nano: Ctrl+O, Enter, Ctrl+X).

5. Aplica los cambios:

   ```bash
   sudo sysctl --system
   ```

## 🔍 Verificación de los Cambios

Puedes verificar la configuración aplicada usando cualquiera de estos comandos:

### Versión Compacta

```bash
sysctl -a | grep -E 'net\.ipv4\.conf\.(all|default)\.(rp_filter|accept_redirects|send_redirects|accept_source_route|log_martians)|net\.ipv4\.(tcp_syncookies|icmp_echo_ignore_broadcasts|icmp_ignore_bogus_error_responses|ip_forward|tcp_timestamps|tcp_sack|tcp_dsack|tcp_fack)|net\.ipv6\.conf\.(all|default)\.(rp_filter|accept_redirects|accept_source_route|disable_ipv6)'
```

### Versión Detallada

```bash
sysctl net.ipv4.conf.default.rp_filter net.ipv4.conf.all.rp_filter net.ipv6.conf.default.rp_filter net.ipv6.conf.all.rp_filter net.ipv4.tcp_syncookies net.ipv4.icmp_echo_ignore_broadcasts net.ipv4.icmp_ignore_bogus_error_responses net.ipv4.conf.all.accept_redirects net.ipv4.conf.default.accept_redirects net.ipv4.conf.all.send_redirects net.ipv6.conf.all.accept_redirects net.ipv6.conf.default.accept_redirects net.ipv4.ip_forward net.ipv4.conf.all.accept_source_route net.ipv4.conf.default.accept_source_route net.ipv6.conf.all.accept_source_route net.ipv6.conf.default.accept_source_route net.ipv4.conf.all.log_martians net.ipv4.tcp_timestamps net.ipv4.tcp_sack net.ipv4.tcp_dsack net.ipv4.tcp_fack net.ipv6.conf.all.disable_ipv6 net.ipv6.conf.default.disable_ipv6
```

## Otras Recomendaciones

### Firewall

Utiliza un [firewall](https://es.wikipedia.org/wiki/Cortafuegos_(inform%C3%A1tica)) y personalízalo según tus necesidades. En Ubuntu y sus derivados está **gufw** (GUI uncomplicated firewall) y **ufw** (uncomplicated firewall) que son opciones bastante sencillas para empezar a implementar un firewall en tu sistema y aprender el cómo funciona un firewall.

### VPN

Considera el uso de una [VPN](https://es.wikipedia.org/wiki/Red_privada_virtual) para cifrar tu tráfico y proteger tu privacidad en línea. Hay varias opciones disponibles, tanto de código abierto como comerciales, que puedes implementar en tu sistema.

   Las opciones más seguras y privadas son:

- [MullvadVPN](https://mullvad.net/es/)
- [ProtonVPN](https://protonvpn.com/es/)
- [IVPN](https://www.ivpn.net/es)

### Guías

La privacidad y la seguridad son algo fundamental para el ser humano y el utilizar las herramientas incorrectas puede llegar a ponerte en riesgo, a continuación, te dejo algunos sitios que puedes visitar para poder mejorar tu privacidad y seguridad en línea:

- [PrivacyGuides](https://www.privacyguides.org/es/)
- [AwesomePrivacy](https://awesome-privacy.xyz/)
- [Personal Security Checklist](https://github.com/Lissy93/personal-security-checklist/blob/HEAD/CHECKLIST.md)

### Reddit/Demás

Los foros y demás comunidades en línea pueden ser recursos valiosos para obtener información y consejos sobre privacidad y seguridad. Algunos subreddits recomendados son:

- [r/privacy](https://www.reddit.com/r/privacy/)
- [r/degoogle](https://www.reddit.com/r/degoogle/)
- [r/PrivacyGuides](https://www.reddit.com/r/PrivacyGuides/)

> **Nota**:
>
> - Estas instrucciones son específicas para distribuciones Linux basadas en Debian. Para otras distribuciones, por favor consulta con tu asistente de IA preferido para verificar cualquier cambio en el procedimiento y proceso de verificación.
> - ⚠️ **AVISO DE RESPONSABILIDAD**: La aplicación de estos ajustes de configuración se realiza bajo la responsabilidad del usuario. Aunque estos parámetros están bien documentados y se aplican a nivel del kernel, no vienen con ninguna garantía de funcionamiento. Es responsabilidad del usuario verificar los resultados y la compatibilidad en su propio sistema antes de aplicarlos en un entorno de producción.
