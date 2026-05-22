#!/usr/bin/env bash
#
# 🧱 ufw_setup.sh
# Automatiza la configuración de UFW y el establecimiento de un Kill-Switch para VPN.
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

# Verificar si UFW está instalado
check_ufw() {
    if ! command -v ufw &>/dev/null; then
        echo -e "${RED}Error:${NC} 'ufw' no está instalado en el sistema." >&2
        echo -e "Por favor, instálalo usando el gestor de paquetes de tu distribución." >&2
        echo -e "  Arch Linux: ${YELLOW}sudo pacman -S ufw${NC}" >&2
        echo -e "  Debian/Ubuntu: ${YELLOW}sudo apt install ufw${NC}" >&2
        exit 1
    fi
}

setup_standard_firewall() {
    echo -e "\n${BLUE}Configurando Firewall Estándar (Recomendado para uso general)...${NC}"
    
    # Restablecer reglas por defecto
    ufw --force reset
    
    # Establecer políticas por defecto
    ufw default deny incoming
    ufw default allow outgoing
    
    # Habilitar firewall
    ufw enable
    systemctl enable ufw.service
    
    echo -e "\n[${GREEN}OK${NC}] Firewall estándar habilitado."
    echo -e "   - Tráfico entrante: ${RED}BLOQUEADO${NC} por defecto."
    echo -e "   - Tráfico saliente: ${GREEN}PERMITIDO${NC} por defecto."
}

setup_vpn_killswitch() {
    echo -e "\n${BLUE}Configurando Kill-Switch para VPN...${NC}"
    
    # Intentar auto-detectar la interfaz de red física por defecto
    DEFAULT_IFACE=""
    if command -v ip &>/dev/null; then
        DEFAULT_IFACE=$(ip route show | grep '^default' | awk '{print $5}' | head -n1)
    fi
    
    echo -e "Detectando interfaz física de red activa..."
    if [[ -n "$DEFAULT_IFACE" ]]; then
        echo -e "Interfaz física auto-detectada: ${YELLOW}$DEFAULT_IFACE${NC}"
    else
        DEFAULT_IFACE="wlan0"
        echo -e "No se pudo auto-detectar. Interfaz asumida por defecto: ${YELLOW}$DEFAULT_IFACE${NC}"
    fi
    
    read -p "Ingresa tu interfaz física de red (o presiona Enter para usar '$DEFAULT_IFACE'): " user_iface
    PHYS_IFACE=${user_iface:-$DEFAULT_IFACE}
    
    read -p "Ingresa el nombre de la interfaz de tu VPN (ej. tun0, wg0): " VPN_IFACE
    if [[ -z "$VPN_IFACE" ]]; then
        echo -e "${RED}Error:${NC} Debes especificar una interfaz de VPN válida." >&2
        exit 1
    fi

    read -p "Ingresa la IP del servidor de tu VPN (ej. 198.51.100.42): " VPN_SERVER_IP
    if [[ -z "$VPN_SERVER_IP" ]]; then
        echo -e "${RED}Error:${NC} Debes especificar la IP del servidor de tu VPN." >&2
        exit 1
    fi
    
    read -p "Ingresa el puerto de la VPN (ej. 1194 para OpenVPN, 51820 para WireGuard): " VPN_PORT
    if [[ -z "$VPN_PORT" ]]; then
        echo -e "${RED}Error:${NC} Debes especificar el puerto del servidor VPN." >&2
        exit 1
    fi
    
    read -p "Ingresa el protocolo (udp/tcp): " VPN_PROTO
    if [[ "$VPN_PROTO" != "udp" && "$VPN_PROTO" != "tcp" ]]; then
         echo -e "${RED}Error:${NC} El protocolo debe ser 'udp' o 'tcp'." >&2
         exit 1
    fi

    echo -e "\n${BLUE}Aplicando reglas de cortafuegos de Kill-Switch...${NC}"
    
    # Restablecer reglas por defecto
    ufw --force reset
    
    # 1. Denegar TODA la salida y entrada por defecto
    ufw default deny incoming
    ufw default deny outgoing
    
    # 2. Permitir tráfico de loopback (esencial para servicios locales)
    ufw allow in on lo
    ufw allow out on lo
    
    # 3. Permitir conexión saliente exclusiva al servidor VPN a través de la interfaz física
    ufw allow out on "$PHYS_IFACE" to "$VPN_SERVER_IP" port "$VPN_PORT" proto "$VPN_PROTO" comment "Conexión a Servidor VPN"
    
    # 4. Permitir TODA la entrada y salida por la interfaz del túnel VPN
    ufw allow in on "$VPN_IFACE" comment "Túnel VPN Entrante"
    ufw allow out on "$VPN_IFACE" comment "Túnel VPN Saliente"
    
    # Habilitar firewall
    ufw enable
    systemctl enable ufw.service
    
    echo -e "\n[${GREEN}OK${NC}] ¡Kill-Switch configurado y habilitado correctamente!"
    echo -e "   - Todo el tráfico saliente ahora está restringido a la VPN (${YELLOW}$VPN_IFACE${NC})."
    echo -e "   - Si la VPN se cae, el tráfico a internet se detendrá inmediatamente para evitar fugas."
    echo -e "   - Conexiones locales a través de 'lo' siguen activas."
}

# Flujo principal
check_ufw

echo -e "${BLUE}=== Asistente de Configuración de Cortafuegos (UFW) ===${NC}"
echo "Elige el tipo de configuración que deseas aplicar:"
echo "1) Firewall Estándar (Seguro por defecto, permite toda salida ordinaria)"
echo "2) Firewall Estricto con Kill-Switch (Todo el tráfico restringido a la VPN)"
echo "3) Salir"
read -p "Opción (1-3): " opt

case "$opt" in
    1)
        setup_standard_firewall
        ;;
    2)
        setup_vpn_killswitch
        ;;
    3)
        echo "Saliendo sin realizar cambios."
        exit 0
        ;;
    *)
        echo -e "${RED}Opción inválida.${NC}" >&2
        exit 1
        ;;
esac
