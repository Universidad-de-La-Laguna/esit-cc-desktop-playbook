#!/bin/bash

# Verificar que se pasan los parámetros necesarios
if [ -z "$1" ] || [ -z "$2" ]; then
    echo "Error: Debe especificar el ordenador origen y la contraseña"
    echo "Uso: $0 <ordenador_origen> <contraseña>"
    exit 1
fi

ORIGEN="$1"
export SSHPASS="$2"

# Verificar espacio libre en / (80 GB = 80000000 KB aproximadamente)
ESPACIO_LIBRE=$(df / | tail -1 | awk '{print $4}')
ESPACIO_REQUERIDO=80000000

if [ "$ESPACIO_LIBRE" -lt "$ESPACIO_REQUERIDO" ]; then
    echo "Error: No hay suficiente espacio libre en /"
    echo "Disponible: $(($ESPACIO_LIBRE / 1024 / 1024)) GB"
    echo "Requerido: 80 GB"
    exit 1
fi

echo "Espacio disponible: $(($ESPACIO_LIBRE / 1024 / 1024)) GB - OK"
echo "Sincronizando desde $ORIGEN..."

# Sincronizar vivado.sh
echo "Copiando /etc/profile.d/vivado.sh..."
sshpass -e rsync -aHAX --info=progress2 -e "ssh -T -o Compression=no -o StrictHostKeyChecking=no" \
    ${ORIGEN}:/etc/profile.d/vivado.sh /etc/profile.d/vivado.sh

# Sincronizar /tools/
echo "Copiando /tools/..."
sshpass -e rsync -aHAX --info=progress2 -e "ssh -T -o Compression=no -o StrictHostKeyChecking=no" \
    ${ORIGEN}:/tools/ /tools/

# Sincronizar regla udev
echo "Copiando regla udev..."
sshpass -e rsync -aHAX --info=progress2 -e "ssh -T -o Compression=no -o StrictHostKeyChecking=no" \
    ${ORIGEN}:/etc/udev/rules.d/52-digilent-usb.rules \
    /etc/udev/rules.d/52-digilent-usb.rules

echo "Sincronización completada desde $ORIGEN"