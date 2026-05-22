#!/usr/bin/env bash
#
# 🔒 ssh_hardening.sh
# Audita y endurece la configuración de SSH (/etc/ssh/sshd_config).
# Debe ejecutarse con privilegios de root (sudo).
#

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SSHD_CONFIG="/etc/ssh/sshd_config"

# Comprobar privilegios de root
if [[ "$EUID" -ne 0 ]]; then
    echo -e "${RED}Error:${NC} Este script debe ejecutarse con privilegios de root (usando sudo)." >&2
    echo -e "Ejecución recomendada: ${YELLOW}sudo $0${NC}" >&2
    exit 1
fi

# Verificar si sshd está instalado
if [[ ! -f "$SSHD_CONFIG" ]]; then
    echo -e "${RED}Error:${NC} No se encontró el archivo de configuración SSH en $SSHD_CONFIG." >&2
    echo -e "Asegúrate de tener un servidor OpenSSH instalado." >&2
    exit 1
fi

# Parámetros que queremos comprobar/aplicar
declare -A SECURE_PARAMS=(
    ["PermitRootLogin"]="no"
    ["PasswordAuthentication"]="no"
    ["PubkeyAuthentication"]="yes"
    ["PermitEmptyPasswords"]="no"
    ["X11Forwarding"]="no"
    ["MaxAuthTries"]="3"
    ["ClientAliveInterval"]="300"
    ["ClientAliveCountMax"]="2"
)

# Criptografía fuerte moderna (KEX, Ciphers y MACs)
CRYPTO_CONFIG="
# --- Ajustes de Seguridad Avanzados ---
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com
"

audit_ssh() {
    echo -e "${BLUE}=== Iniciando Auditoría de Configuración SSH ===${NC}\n"
    local vulnerabilities=0
    
    for param in "${!SECURE_PARAMS[@]}"; do
        local expected="${SECURE_PARAMS[$param]}"
        # Buscar el parámetro activo en sshd_config (ignorando comentarios)
        local current
        current=$(grep -i "^[[:space:]]*$param" "$SSHD_CONFIG" | awk '{print $2}' | tail -n1 || true)
        
        if [[ -z "$current" ]]; then
            # Si no está definido, se usa el valor predeterminado de OpenSSH (a menudo inseguro para estos parámetros)
            echo -e "  [${YELLOW}NO CONFIGURADO${NC}] Parámetro '${param}' no está explícitamente definido. Esperado: '${expected}'"
            vulnerabilities=$((vulnerabilities + 1))
        elif [[ "${current,,}" != "${expected,,}" ]]; then
            echo -e "  [${RED}INSEGURO${NC}] '${param}' está establecido en '${current}'. Esperado: '${expected}'"
            vulnerabilities=$((vulnerabilities + 1))
        else
            echo -e "  [${GREEN}SEGURO${NC}] '${param}' está establecido correctamente en '${current}'"
        fi
    done
    
    # Comprobar si hay cifrados heredados débiles definidos
    if grep -Ei "^[[:space:]]*(Ciphers|KexAlgorithms|MACs).*(3des|arcfour|cbc|md5|sha1)" "$SSHD_CONFIG" &>/dev/null; then
         echo -e "  [${RED}INSEGURO${NC}] Se detectaron algoritmos débiles de cifrado o intercambio de claves activos."
         vulnerabilities=$((vulnerabilities + 1))
    fi
    
    echo -e "\n${BLUE}Auditoría completada.${NC} Parámetros inseguros o faltantes encontrados: ${YELLOW}$vulnerabilities${NC}"
}

apply_hardening() {
    echo -e "${BLUE}=== Aplicando Endurecimiento de Configuración SSH ===${NC}\n"
    
    # 1. Copia de seguridad
    local backup="${SSHD_CONFIG}.bak.$(date +%F_%H%M%S)"
    echo -e "1. Creando copia de seguridad del archivo actual en: ${YELLOW}$backup${NC}"
    cp "$SSHD_CONFIG" "$backup"
    
    # 2. Modificar los parámetros estándar
    echo -e "2. Modificando parámetros en el archivo de configuración..."
    for param in "${!SECURE_PARAMS[@]}"; do
        local expected="${SECURE_PARAMS[$param]}"
        
        # Si el parámetro existe y está activo, lo reemplazamos
        if grep -q "^[[:space:]]*$param" "$SSHD_CONFIG"; then
            sed -i "s|^[[:space:]]*$param.*|$param $expected|i" "$SSHD_CONFIG"
        # Si está comentado, eliminamos el comentario y lo modificamos
        elif grep -q "^#[[:space:]]*$param" "$SSHD_CONFIG"; then
            sed -i "s|^#[[:space:]]*$param.*|$param $expected|i" "$SSHD_CONFIG"
        # Si no existe, lo agregamos al final del archivo
        else
            echo "$param $expected" >> "$SSHD_CONFIG"
        fi
    done
    
    # 3. Aplicar criptografía fuerte (evitando duplicar)
    if ! grep -q "KexAlgorithms" "$SSHD_CONFIG"; then
        echo -e "3. Agregando suite de cifrado moderna (KexAlgorithms, Ciphers, MACs)..."
        echo "$CRYPTO_CONFIG" >> "$SSHD_CONFIG"
    else
        echo -e "3. ${YELLOW}Advertencia:${NC} 'KexAlgorithms' ya existe en $SSHD_CONFIG. Se omitió la suite criptográfica automática para evitar conflictos."
    fi
    
    # 4. Validar la sintaxis antes de reiniciar el servicio (¡CRÍTICO!)
    echo -n "4. Validando sintaxis de la nueva configuración... "
    if sshd -t; then
        echo -e "[${GREEN}OK${NC}]"
        
        # 5. Reiniciar SSH
        echo -n "5. Reiniciando servicio SSH para aplicar los cambios... "
        local restart_cmd=""
        if systemctl list-units --type=service | grep -q "sshd.service"; then
            restart_cmd="systemctl restart sshd.service"
        elif systemctl list-units --type=service | grep -q "ssh.service"; then
            restart_cmd="systemctl restart ssh.service"
        fi
        
        if [[ -n "$restart_cmd" ]] && eval "$restart_cmd"; then
            echo -e "[${GREEN}OK${NC}]"
            echo -e "\n${GREEN}¡Endurecimiento SSH completado con éxito!${NC}"
        else
            echo -e "[${RED}FALLÓ${NC}]"
            echo -e "   No se pudo reiniciar el servicio automáticamente. Reinícialo manualmente para aplicar cambios." >&2
        fi
    else
        echo -e "[${RED}FALLÓ${NC}]"
        echo -e "   ${RED}¡ATENCIÓN! La nueva configuración tiene errores de sintaxis.${NC}" >&2
        echo -e "   Restaurando copia de seguridad inmediatamente..." >&2
        cp "$backup" "$SSHD_CONFIG"
        exit 1
    fi
}

# Flujo principal
echo -e "${BLUE}=== Asistente de Hardening de SSH ===${NC}"
echo "Elige una acción:"
echo "1) Auditar configuración actual (modo de lectura/prueba)"
echo "2) Aplicar endurecimiento seguro (modifica sshd_config y reinicia)"
echo "3) Salir"
read -p "Opción (1-3): " opt

case "$opt" in
    1)
        audit_ssh
        ;;
    2)
        apply_hardening
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
