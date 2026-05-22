# 📦 Seguridad en Contenedores con Podman (Rootless)

**Podman** (Pod Manager) es un motor de contenedores de código abierto y sin demonio (daemonless) desarrollado por Red Hat. A diferencia de Docker, que tradicionalmente requiere un demonio ejecutándose como root (`dockerd`), Podman está diseñado para ejecutarse completamente en espacio de usuario no privilegiado (**Rootless**).

Este módulo proporciona guías y automatizaciones para implementar contenedores seguros utilizando la filosofía de menor privilegio.

---

## 🛡️ ¿Por qué Podman Rootless?

1. **Sin demonio ejecutándose como root:** Docker requiere un demonio con privilegios de superusuario. Si un atacante compromete el demonio de Docker, obtiene acceso de root al host. Podman interactúa directamente con el kernel a través de llamadas de sistema ordinarias.
2. **Rootless por diseño:** Los contenedores se ejecutan bajo el UID del usuario que los lanza. Un escape del contenedor dejará al atacante con los privilegios de un usuario común en el host, no de root.
3. **Integración nativa con Systemd:** Podman genera archivos de servicio systemd limpios para gestionar el ciclo de vida de los contenedores como servicios de usuario.
4. **Soporte de Namespaces:** Utiliza namespaces de usuario para mapear el UID `0` (root) dentro del contenedor a un UID no privilegiado en el host.

---

## ⚙️ Requisitos y Configuración del Host

Para que un usuario no privilegiado pueda ejecutar Podman en modo rootless, se deben configurar los namespaces de usuario.

### 1. Instalación en Arch Linux

```bash
sudo pacman -S podman dbus-user-session slirp4netns
```

### 2. Configurar `/etc/subuid` y `/etc/subgid`

Estos archivos definen el rango de IDs de usuario y de grupo que el usuario tiene permitido usar dentro de los contenedores.

Edita `/etc/subuid` y `/etc/subgid` agregando un rango para tu usuario (por ejemplo, 65,536 IDs a partir del ID 100,000):

```text
# Formato: usuario:rango_inicial:cantidad_ids
josel:100000:65536
```

### 3. Habilitar Namespaces en el Kernel (si aplica)

En Arch Linux, los namespaces de usuario no privilegiados están habilitados por defecto en el kernel. Puedes verificarlo con:

```bash
sysctl kernel.unprivileged_userns_clone
```

Si devuelve `1`, está habilitado. Si devuelve `0` o no existe, agrégalo a tu archivo sysctl:

```ini
kernel.unprivileged_userns_clone=1
```

---

## 🔒 Buenas Prácticas al Ejecutar Contenedores

Incluso con Podman Rootless, debes aplicar principios de endurecimiento (hardening) al lanzar contenedores:

### 1. Reducir Capacidades del Kernel (`Capabilities`)

Por defecto, los contenedores heredan varias capacidades del kernel. Deshabilítalas todas y agrega solo las requeridas:

```bash
# Ejemplo: Deshabilitar todo y habilitar solo NET_BIND_SERVICE
podman run --cap-drop=all --cap-add=net_bind_service -d nginx
```

### 2. Contenedor en Modo Solo Lectura (`Read-Only`)

Previene que un atacante modifique binarios o scripts dentro del contenedor si logra entrar:

```bash
podman run --read-only -d nginx
```

_Nota: Si la aplicación requiere escribir en directorios temporales, monta un volumen `tmpfs`:_

```bash
podman run --read-only --tmpfs /tmp --tmpfs /run -d nginx
```

### 3. No usar el flag de Privilegiado (`--privileged`)

El uso de `--privileged` deshabilita todas las protecciones de seguridad de Podman (incluyendo perfiles de Seccomp y AppArmor/SELinux), dando acceso casi total al hardware y kernel del host. **Nunca lo uses en producción.**

### 4. Limitar Recursos

Previene ataques de denegación de servicio (DoS) locales limitando memoria y CPU:

```bash
podman run --memory=512m --cpus=1.0 -d nginx
```

---

## 🤖 Automatización con Script

El script [`podman_setup.sh`](./podman_setup.sh) automatiza la validación del entorno y la configuración inicial de los archivos de mapeo de UIDs para tu usuario.

### Ejecutar el script:

1. Dale permisos de ejecución:

   ```bash
   chmod +x podman_setup.sh
   ```

2. Ejecútalo:

   ```bash
   ./podman_setup.sh
   ```
