#!/bin/bash

# Verificar que se pasa el ordenador origen como parámetro
if [ -z "$1" ]; then
    echo "Error: Debe especificar el ordenador origen"
    echo "Uso: $0 <ordenador_origen>"
    exit 1
fi

ORIGEN="$1"

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
rsync -aHAX --info=progress2 -e "ssh -T -o Compression=no" \
    ${ORIGEN}:/etc/profile.d/vivado.sh /etc/profile.d/vivado.sh

# Sincronizar /tools/
echo "Copiando /tools/..."
rsync -aHAX --info=progress2 -e "ssh -T -o Compression=no" \
    ${ORIGEN}:/tools/ /tools/

# Sincronizar regla udev
echo "Copiando regla udev..."
rsync -aHAX --info=progress2 -e "ssh -T -o Compression=no" \
    ${ORIGEN}:/etc/udev/rules.d/52-digilent-usb.rules \
    /etc/udev/rules.d/52-digilent-usb.rules

echo "Sincronización completada desde $ORIGEN"