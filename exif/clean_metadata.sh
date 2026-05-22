#!/usr/bin/env bash
#
# 🧹 clean_metadata.sh
# Automatiza la limpieza recursiva o individual de metadatos usando mat2.
#
# Uso: ./clean_metadata.sh [-i|--inplace] <archivo_o_directorio>
#

set -euo pipefail

# Colores para salida en terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Función para imprimir ayuda
show_help() {
    echo -e "${BLUE}Uso:${NC} $0 [opciones] <archivo_o_directorio>"
    echo
    echo "Opciones:"
    echo "  -i, --inplace    Limpia los archivos directamente sobrescribiendo el original"
    echo "  -h, --help       Muestra este mensaje de ayuda"
    echo
    echo "Requisitos:"
    echo "  Debe tener instalado 'mat2' en el sistema."
}

# Verificar dependencias
check_dependencies() {
    if ! command -v mat2 &> /dev/null; then
        echo -e "${RED}Error:${NC} 'mat2' no está instalado en el sistema." >&2
        echo -e "Instálalo usando:" >&2
        echo -e "  Arch Linux: ${YELLOW}sudo pacman -S mat2${NC}" >&2
        echo -e "  Debian/Ubuntu: ${YELLOW}sudo apt install mat2${NC}" >&2
        exit 1
    fi
}

# Procesar argumentos
INPLACE=false
TARGET=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -i|--inplace)
            INPLACE=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        -*)
            echo -e "${RED}Opción desconocida:${NC} $1" >&2
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$TARGET" ]]; then
                TARGET="$1"
            else
                echo -e "${RED}Error:${NC} Solo se permite un archivo o directorio como objetivo." >&2
                show_help
                exit 1
            fi
            shift
            ;;
    esac
done

# Validar que se haya pasado un objetivo
if [[ -z "$TARGET" ]]; then
    echo -e "${RED}Error:${NC} No se especificó ningún archivo o directorio." >&2
    show_help
    exit 1
fi

# Validar que el objetivo exista
if [[ ! -e "$TARGET" ]]; then
    echo -e "${RED}Error:${NC} El objetivo '$TARGET' no existe." >&2
    exit 1
fi

check_dependencies

# Definir la acción de mat2
run_mat2() {
    local file="$1"
    if [ "$INPLACE" = true ]; then
        if mat2 --inplace "$file" 2>/dev/null; then
            echo -e "  [${GREEN}OK${NC}] Limpiado (inplace): $file"
        else
            echo -e "  [${RED}ERROR${NC}] Falló al limpiar: $file"
        fi
    else
        if mat2 "$file" 2>/dev/null; then
            echo -e "  [${GREEN}OK${NC}] Copia limpia creada para: $file"
        else
            echo -e "  [${RED}ERROR${NC}] Falló al limpiar: $file"
        fi
    fi
}

# Procesamiento
if [[ -f "$TARGET" ]]; then
    echo -e "${BLUE}Procesando archivo individual...${NC}"
    run_mat2 "$TARGET"
elif [[ -d "$TARGET" ]]; then
    echo -e "${BLUE}Procesando directorio recursivamente...${NC}"
    
    # mat2 --check verifica si el archivo es soportado por mat2
    # Buscamos todos los archivos regulares en el directorio y los procesamos si son soportados
    find "$TARGET" -type f | while read -r file; do
        # Verificar si mat2 soporta el archivo (retorna 0 si es soportado)
        if mat2 --show "$file" &>/dev/null || mat2 --show "$file" 2>&1 | grep -q "has no metadata" || mat2 --show "$file" 2>&1 | grep -q "contains metadata"; then
             run_mat2 "$file"
        fi
    done
fi

echo -e "\n${GREEN}¡Proceso finalizado!${NC}"
