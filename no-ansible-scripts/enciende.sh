#!/bin/bash

# Verifica que se haya proporcionado al menos un argumento
if [ $# -lt 1 ]; then
    echo "Uso: $0 <nombre_del_host_sin_etsii>"
    exit 1
fi

# Nombre de archivo que contiene las MAC addresses
archivo="resources/ansible/hosts"

# Función para enviar el paquete de Wake-on-LAN
enviar_wol() {
    local mac=$1
    # Verifica si la MAC address no está vacía
    if [ -n "$mac" ]; then
        echo "Enviando paquete de Wake-on-LAN a la MAC address '$mac'..."
        wakeonlan "$mac"
    fi
}

# Itera sobre cada argumento proporcionado
for host in "$@"; do
    # Añade "etsii.ull.es" al nombre del host
    hostname="$host.etsii.ull.es"
    pw=$(pwd)
    # Busca la MAC address correspondiente al hostname proporcionado
    mac=$(grep -w "$hostname" "$archivo" | awk '{print $2}' | cut -d= -f2)
    # Verifica si se encontró la MAC address
    if [ -z "$mac" ]; then
        echo "No se encontró la MAC address para el hostname '$hostname'."
    else
        # Envía el paquete de Wake-on-LAN
        enviar_wol "$mac"
    fi
done


