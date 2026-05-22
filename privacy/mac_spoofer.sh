#!/usr/bin/env bash
#
# 🛜 mac_spoofer.sh
# Configura NetworkManager para aleatorizar direcciones MAC automáticamente.
# Debe ejecutarse con privilegios de root (sudo).
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}Error:${NC} Este script debe ejecutarse con privilegios de root (usando sudo)." >&2
    echo -e "Ejecución recomendada: ${YELLOW}sudo $0${NC}" >&2
    exit 1
fi

is_nm_installed() {
    if command -v pacman &>/dev/null; then
        # Arch Linux (paquete: networkmanager)
        pacman -Qs networkmanager &>/dev/null
    elif command -v dpkg-query &>/dev/null; then
        # Debian/Ubuntu (paquete: networkmanager)
        dpkg-query -W -f='${Status}' networkmanager 2>/dev/null | grep -q "ok installed"
    elif command -v rpm &>/dev/null; then
        # Fedora/RHEL (paquete: NetworkManager)
        rpm -q NetworkManager &>/dev/null
    else
        # Fallback genérico si no se detecta gestor de paquetes soportado
        command -v NetworkManager &>/dev/null || command -v nmcli &>/dev/null
    fi
}

echo -e "${BLUE}=== Configuración de MAC Address Spoofing en NetworkManager ===${NC}\n"

# 1. Verificar si NetworkManager está instalado en el sistema
echo -n "1. Verificando la presencia de NetworkManager en el sistema... "
if is_nm_installed; then
    echo -e "[${GREEN}INSTALADO${NC}]"
else
    echo -e "[${RED}FALLÓ${NC}]"
    echo -e "   NetworkManager no se encuentra instalado en tu gestor de paquetes." >&2
    echo -e "   Por favor, instálalo antes de ejecutar este script." >&2
    exit 1
fi

# 2. Confirmación de uso activo
echo -e "\n${YELLOW}¿Utilizas actualmente NetworkManager de manera activa para el manejo de tus redes?${NC}"
read -rp "Selecciona (s/N): " nm_active
if [[ ! "$nm_active" =~ ^[sSyY]$ ]]; then
    echo -e "\n${RED}Ejecución abortada:${NC} Este script requiere que utilices NetworkManager activamente." >&2
    exit 1
fi

# 3. Ruta de configuración
CONF_DIR="/etc/NetworkManager/conf.d"
CONF_FILE="$CONF_DIR/30-mac-randomization.conf"

echo -n "3. Creando archivo de configuración en $CONF_FILE... "

mkdir -p "$CONF_DIR"

cat << 'EOF' > "$CONF_FILE"
# Configuración creada por script de Linux Hardening & Seguridad
# Aleatoriza la MAC tanto en el escaneo de redes wifi como al conectarse.

[device]
wifi.scan-rand-mac-address=yes

[connection]
wifi.cloned-mac-address=random
ethernet.cloned-mac-address=random
EOF

echo -e "[${GREEN}OK${NC}]"

# 4. Reiniciar NetworkManager
echo -n "4. Reiniciando servicio NetworkManager para aplicar los cambios... "
if systemctl restart NetworkManager; then
    echo -e "[${GREEN}OK${NC}]"
else
    echo -e "[${RED}FALLÓ${NC}]"
    echo -e "   No se pudo reiniciar NetworkManager. Por favor, reinícialo manualmente usando:" >&2
    echo -e "   ${YELLOW}sudo systemctl restart NetworkManager${NC}" >&2
fi

echo -e "\n${GREEN}¡Configuración completada con éxito!${NC}"
echo -e "A partir de ahora, tu dirección MAC se aleatorizará en cada nueva conexión Wi-Fi y Ethernet."
echo -e "Puedes verificar tus direcciones MAC actuales ejecutando el comando: ${YELLOW}ip link${NC}"
