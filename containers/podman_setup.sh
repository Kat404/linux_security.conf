#!/usr/bin/env bash
#
# 📦 podman_setup.sh
# Verifica y configura el entorno local para ejecutar Podman en modo Rootless.
# Debe ejecutarse como usuario no privilegiado (usará sudo cuando sea necesario).
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Asegurar que NO se está ejecutando directamente como root
if [[ "$EUID" -eq 0 ]]; then
    echo -e "${RED}Error:${NC} Este script debe ejecutarse como usuario no privilegiado (sin sudo)." >&2
    echo -e "El script solicitará privilegios de administración (sudo) cuando los requiera." >&2
    exit 1
fi

REAL_USER="$USER"
echo -e "${BLUE}=== Configuración de Podman Rootless para el usuario: ${YELLOW}$REAL_USER${BLUE} ===${NC}\n"

# 1. Verificar si podman está instalado
echo -n "1. Verificando instalación de Podman... "
if command -v podman &>/dev/null; then
    echo -e "[${GREEN}OK${NC}]"
else
    echo -e "[${RED}FALLÓ${NC}]"
    echo -e "   Por favor, instala podman primero usando el gestor de paquetes de tu distribución." >&2
    exit 1
fi

# 2. Verificar namespaces de usuario en el kernel
echo -n "2. Verificando namespaces de usuario en el kernel... "
if [[ -f /proc/sys/kernel/unprivileged_userns_clone ]]; then
    VAL=$(cat /proc/sys/kernel/unprivileged_userns_clone)
    if [[ "$VAL" -eq 1 ]]; then
        echo -e "[${GREEN}OK${NC}]"
    else
        echo -e "[${YELLOW}DESHABILITADO${NC}]"
        echo -e "   Habilitando temporalmente namespaces de usuario..."
        sudo sysctl kernel.unprivileged_userns_clone=1
        echo -e "   ${YELLOW}Nota:${NC} Asegúrate de tener 'kernel.unprivileged_userns_clone=1' en tus archivos sysctl.conf."
    fi
else
    # En kernels modernos de algunas distros esta opción no existe porque está habilitada por defecto sin opción a apagarse
    echo -e "[${GREEN}OK${NC}] (Soporte nativo)"
fi

# 3. Verificar /etc/subuid y /etc/subgid
echo -n "3. Verificando rangos de UID/GID secundarios... "
SUBUID_OK=false
SUBGID_OK=false

if grep -q "^${REAL_USER}:" /etc/subuid 2>/dev/null; then
    SUBUID_OK=true
fi

if grep -q "^${REAL_USER}:" /etc/subgid 2>/dev/null; then
    SUBGID_OK=true
fi

if [ "$SUBUID_OK" = true ] && [ "$SUBGID_OK" = true ]; then
    echo -e "[${GREEN}OK${NC}]"
    grep "^${REAL_USER}:" /etc/subuid | while read -r line; do
        echo -e "   Rango encontrado en subuid: ${YELLOW}$line${NC}"
    done
else
    echo -e "[${YELLOW}CONFIGURACIÓN NECESARIA${NC}]"
    echo -e "   No se encontraron rangos definidos para el usuario '${REAL_USER}'."
    
    # Calcular un rango inicial libre
    START_ID=100000
    if [[ -f /etc/subuid ]]; then
        # Obtener el último ID final utilizado para evitar solapamientos
        LAST_USED=$(awk -F: '{print $2+$3}' /etc/subuid | sort -n | tail -n1)
        if [[ -n "$LAST_USED" && "$LAST_USED" -gt "$START_ID" ]]; then
            START_ID="$LAST_USED"
        fi
    fi
    
    RANGE=65536
    echo -e "   Se asignará el rango ${YELLOW}${START_ID}-${((START_ID + RANGE - 1))}${NC} para UIDs y GIDs secundarios."
    echo -e "   Se requieren privilegios de root para modificar /etc/subuid y /etc/subgid:"
    
    echo "${REAL_USER}:${START_ID}:${RANGE}" | sudo tee -a /etc/subuid >/dev/null
    echo "${REAL_USER}:${START_ID}:${RANGE}" | sudo tee -a /etc/subgid >/dev/null
    
    echo -e "   [${GREEN}OK${NC}] Rangos de ID agregados correctamente."
fi

# 4. Verificar XDG_RUNTIME_DIR
echo -n "4. Verificando variable de entorno XDG_RUNTIME_DIR... "
if [[ -n "${XDG_RUNTIME_DIR:-}" ]]; then
    echo -e "[${GREEN}OK${NC}] (Valor: $XDG_RUNTIME_DIR)"
else
    echo -e "[${RED}ADVERTENCIA${NC}]"
    echo -e "   La variable \$XDG_RUNTIME_DIR no está definida. Podman Rootless podría fallar." >&2
    echo -e "   Asegúrate de que el módulo pam_systemd esté cargado y de haber iniciado sesión correctamente." >&2
    # Intentamos establecer un valor por defecto seguro basado en el UID
    MY_UID=$(id -u)
    export XDG_RUNTIME_DIR="/run/user/$MY_UID"
    echo -e "   Estableciendo temporalmente a: $XDG_RUNTIME_DIR"
fi

# 5. Ejecutar prueba rápida
echo -e "\n${BLUE}5. Ejecutando prueba de contenedor rootless (alpine)...${NC}"
if podman run --rm alpine echo "¡Podman Rootless funciona correctamente!" 2>/dev/null; then
    echo -e "\n[${GREEN}ÉXITO${NC}] Podman Rootless está completamente configurado y operativo."
else
    # Si falla, podría ser porque requiere un reinicio o un comando migrate
    echo -e "   La ejecución directa falló. Intentando migración de base de datos de Podman..."
    podman system migrate || true
    
    if podman run --rm alpine echo "¡Podman Rootless funciona correctamente!" 2>/dev/null; then
        echo -e "\n[${GREEN}ÉXITO${NC}] Podman Rootless está operativo después de la migración."
    else
        echo -e "\n[${RED}ERROR${NC}] La prueba del contenedor falló." >&2
        echo -e "   Detalles comunes de solución de problemas:" >&2
        echo -e "   - Cierra tu sesión actual de terminal y vuelve a ingresar para aplicar los cambios de /etc/subuid." >&2
        echo -e "   - Si estás usando SSH o tmux, asegúrate de que tu sesión de systemd-logind esté activa." >&2
        exit 1
    fi
fi
