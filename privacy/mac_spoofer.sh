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

echo -e "${BLUE}=== Configuración de MAC Address Spoofing en NetworkManager ===${NC}\n"

# 1. Verificar si NetworkManager está instalado
echo -n "1. Verificando la presencia de NetworkManager... "
if systemctl list-unit-files | grep -q "NetworkManager.service"; then
    echo -e "[${GREEN}OK${NC}]"
else
    echo -e "[${RED}FALLÓ${NC}]"
    echo -e "   NetworkManager no parece estar configurado como servicio en este sistema." >&2
    echo -e "   Este script solo soporta sistemas que gestionan redes mediante NetworkManager." >&2
    exit 1
fi

# 2. Ruta de configuración
CONF_DIR="/etc/NetworkManager/conf.d"
CONF_FILE="$CONF_DIR/30-mac-randomization.conf"

echo -n "2. Creando archivo de configuración en $CONF_FILE... "

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

# 3. Reiniciar NetworkManager
echo -n "3. Reiniciando servicio NetworkManager para aplicar los cambios... "
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
