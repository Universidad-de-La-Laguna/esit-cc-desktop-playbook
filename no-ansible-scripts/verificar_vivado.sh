#!/bin/bash

# Script de verificación de instalación de Vivado

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Verificar parámetros
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Debe especificar el ordenador origen y la contraseña"
    echo "Uso: $0 <ordenador_origen> <contraseña>"
    exit 1
fi

ORIGEN="$1"
export SSHPASS="$2"
HOSTNAME=$(hostname)
ERRORES=0

# Verificar archivos específicos silenciosamente
[ ! -e "/etc/profile.d/vivado.sh" ] && ((ERRORES++))
[ ! -e "/tools" ] && ((ERRORES++))
[ ! -e "/etc/udev/rules.d/52-digilent-usb.rules" ] && ((ERRORES++))

# Verificar que /tools no está vacío
if [ -d "/tools" ]; then
    TOTAL_ARCHIVOS=$(find /tools -type f 2>/dev/null | wc -l)
    [ "$TOTAL_ARCHIVOS" -eq 0 ] && ((ERRORES++))
fi

# Verificar conectividad con origen
if ! sshpass -e ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no ${ORIGEN} "echo OK" &>/dev/null; then
    echo -e "${HOSTNAME}: ${RED}ERROR - No se puede conectar con origen${NC}"
    exit 1
fi

# Comparación con rsync (capturar diferencias)
DIFF_FILE=$(mktemp)

sshpass -e rsync -aHAX --dry-run --itemize-changes \
    -e "ssh -o StrictHostKeyChecking=no" \
    ${ORIGEN}:/etc/profile.d/vivado.sh /etc/profile.d/ >> $DIFF_FILE 2>&1

sshpass -e rsync -aHAX --dry-run --itemize-changes \
    -e "ssh -o StrictHostKeyChecking=no" \
    ${ORIGEN}:/tools/ /tools/ >> $DIFF_FILE 2>&1

sshpass -e rsync -aHAX --dry-run --itemize-changes \
    -e "ssh -o StrictHostKeyChecking=no" \
    ${ORIGEN}:/etc/udev/rules.d/52-digilent-usb.rules \
    /etc/udev/rules.d/ >> $DIFF_FILE 2>&1

# Verificar si hay diferencias
if [ -s "$DIFF_FILE" ]; then
    ((ERRORES++))
fi

rm -f $DIFF_FILE

# Resultado final
if [ "$ERRORES" -eq 0 ]; then
    echo -e "${HOSTNAME}: ${GREEN}OK${NC}"
    exit 0
else
    echo -e "${HOSTNAME}: ${RED}ERROR${NC}"
    exit 1
fi
