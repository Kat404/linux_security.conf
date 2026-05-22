# 🐧 🛡️ Guía de Configuración, Hardening y Privacidad en Linux

<div align="left">
  <a href="./README.md">
    <img src="https://img.shields.io/badge/English_README-1a5fb4?style=for-the-badge&logo=googletranslate&logoColor=white" alt="English README">
  </a>
</div>

Este repositorio es una colección modular de configuraciones de seguridad, guías prácticas y scripts de automatización CLI en Bash diseñados para auditar, proteger y optimizar sistemas operativos Linux (especialmente distribuciones basadas en Arch Linux y Debian/Ubuntu) contra amenazas comunes, salvaguardar la privacidad de la red física y digital, y anonimizar metadatos.

---

## 🗂️ Estructura del Repositorio

El repositorio está organizado de forma modular. Cada subdirectorio contiene su propia guía técnica detallada y sus correspondientes scripts de automatización:

### 1. ⚙️ [sysctl/](./sysctl) - Configuración del Kernel y Red

- **Contenido:** Ajustes avanzados a nivel de kernel mediante archivos `.conf`.
- **Enfoque:** Protecciones contra Spoofing IP, mitigación de ataques de Denegación de Servicio (DoS/SYN Floods), desactivación de redirecciones ICMP (prevención MITM), endurecimiento ARP y extensiones de privacidad IPv6.
- **Ir al Módulo:** 👉 [sysctl/README-es.md](./sysctl/README-es.md)

### 2. 🛡️ [hardening/](./hardening) - Auditoría y Fortalecimiento del Sistema

- **Contenido:** Técnicas de endurecimiento y auditoría del sistema operativo.
- **Enfoque:** Uso de la herramienta FOSS `Lynis` para auditar la robustez del sistema, configuración y criptografía avanzada en SSH (`sshd_config`), e inhabilitación de módulos del kernel obsoletos o innecesarios.
- **Ir al Módulo:** 👉 [hardening/README-es.md](./hardening/README-es.md)

### 3. 📦 [containers/](./containers) - Seguridad en Contenedores (Podman)

- **Contenido:** Directrices de menor privilegio orientadas al ecosistema Podman.
- **Enfoque:** Configuración de contenedores en modo **Rootless** (sin privilegios de root), definición segura de rangos de ID (`subuid`/`subgid`), reducción de capacidades del kernel (`capabilities`), ejecución en modo solo lectura (`read-only`) y políticas Seccomp.
- **Ir al Módulo:** 👉 [containers/README-es.md](./containers/README-es.md)

### 4. 🧹 [exif/](./exif) - Anonimización de Metadatos

- **Contenido:** Limpieza automatizada de metadatos sensibles en archivos multimedia y documentos.
- **Enfoque:** Guía de uso de la herramienta recomendada `mat2` (Metadata Anonymisation Toolkit v2) y un script en Bash para la limpieza automática y recursiva de directorios completos.
- **Ir al Módulo:** 👉 [exif/README-es.md](./exif/README-es.md)

### 5. 👤 [privacy/](./privacy) - Privacidad y Anonimato en Red

- **Contenido:** Medidas de privacidad a nivel de interfaz de red y firewall.
- **Enfoque:** Aleatorización de direcciones MAC físicas en NetworkManager, resolución DNS segura mediante DNS sobre TLS (DoT) con `systemd-resolved`, enrutamiento selectivo sobre la red Tor y configuración de un Firewall robusto con Kill-Switch para VPN utilizando `ufw`.
- **Ir al Módulo:** 👉 [privacy/README-es.md](./privacy/README-es.md)

---

## 🚀 Filosofía de Diseño del Proyecto

- **Portabilidad CLI:** Todas las automatizaciones del repositorio se desarrollan en **Bash puro**, lo que garantiza que funcionen en cualquier distribución moderna sin dependencias externas complejas.
- **Privacidad Primero (FOSS):** Priorizamos estrictamente el uso de herramientas libres, seguras y que protejan la privacidad del usuario, tales como `mat2`, `Tor`, `Lynis` y `Podman`.
- **Educativo y Transparente:** Cada script y archivo de configuración contiene explicaciones analíticas detalladas. Creemos que es crucial comprender el **"Por qué"** antes de aplicar cualquier cambio en el sistema.

---

## 🔄 Compatibilidad

- **Sistemas Operativos:** Probado y diseñado para Arch Linux y distribuciones basadas en Debian/Ubuntu.
- **Kernel Linux:** La mayoría de los parámetros requieren un kernel moderno (versión `>= 4.x` para la mayoría de sysctl, y `>= 5.x` para funciones avanzadas como el bloqueo de `io_uring` o contenedores rootless).

---

## 📚 Recursos y Referencias de Alta Calidad

Para expandir tu conocimiento en seguridad y privacidad en Linux, te sugerimos visitar la documentación oficial y fuentes secundarias de alta reputación:

- [Privacy Guides](https://www.privacyguides.org/es/) - Guía estándar y de referencia para la privacidad y seguridad digital.
- [Awesome Privacy](https://awesome-privacy.xyz/) - Lista curada de software y servicios respetuosos con la privacidad.
- [Lynis Official Site](https://cisofy.com/lynis/) - Documentación oficial y buenas prácticas de auditoría CIS.
- [Maturity Model for Linux Hardening (MTR)](https://github.com/mzet-/linux-hardening-checklist) - Checklist de referencia para hardening avanzado del kernel y espacio de usuario.
- [Tor Project](https://www.torproject.org/) - Documentación oficial sobre la red de anonimato Tor y su integración.

---

## ⚠️ AVISO DE RESPONSABILIDAD

> La aplicación de las configuraciones y scripts contenidos en este repositorio se realiza bajo la absoluta responsabilidad del usuario. La seguridad informática consiste en gestionar riesgos; endurecer un sistema excesivamente puede romper la compatibilidad con ciertas aplicaciones (por ejemplo, restricciones excesivas en namespaces de usuario pueden interferir con Flatpak o sandboxes).
>
> **Verifica siempre los resultados en un entorno de pruebas (VM) antes de implementarlos en producción.**
