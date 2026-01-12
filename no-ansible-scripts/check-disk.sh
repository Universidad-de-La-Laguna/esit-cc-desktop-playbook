#!/bin/bash

# Colores
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Verificar parámetro
if [ $# -eq 0 ]; then
    echo "Uso: $0 <tamaño_minimo_en_GB> [ruta]"
    exit 1
fi

MIN_SIZE=$1
PATH_TO_CHECK=${2:-"/home/alumnos.ull.es"}

# Obtener hostname
HOSTNAME=$(hostname)

# Obtener espacio disponible en GB
AVAILABLE_GB=$(df -BG "$PATH_TO_CHECK" 2>/dev/null | awk 'NR==2 {print $4}' | sed 's/G//')

# Verificar y mostrar resultado
if [ -z "$AVAILABLE_GB" ]; then
    echo -e "$HOSTNAME - ${RED}ESPACIO INSUFICIENTE${NC}"
elif [ "$AVAILABLE_GB" -lt "$MIN_SIZE" ]; then
    echo -e "$HOSTNAME - ${RED}ESPACIO INSUFICIENTE${NC}"
else
    echo -e "$HOSTNAME - ${GREEN}ESPACIO SUFICIENTE${NC}"
fi