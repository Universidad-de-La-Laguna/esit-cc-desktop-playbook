#!/bin/bash

# Verifica que se haya proporcionado al menos un argumento
if [ $# -lt 1 ]; then
    echo "Uso: $0 <nombre_del_host_sin_etsii>"
    exit 1
fi

# Nombre de archivo que contiene las MAC addresses
archivo="../resources/ansible/hosts"

# Función para enviar el paquete de Wake-on-LAN
enviar_wol() {
    local mac=$1
    # Verifica si la MAC address no está vacía
    if [ -n "$mac" ]; then
        echo "Enviando paquete de Wake-on-LAN a la MAC address '$mac'..."
        wakeonlan "$mac"
    fi
}

# Función para comprobar el estado de los hosts
comprobar_estado() {
    local hostname=$1
    if ping -c 1 -W 1 "$hostname" &>/dev/null; then
        echo -e "\e[32m$hostname está ENCENDIDO\e[0m"
    else
        echo -e "\e[31m$hostname está APAGADO\e[0m"
    fi
}



# Timer con visualización
mostrar_timer() {
    local segundos=$1
    echo "Esperando $segundos segundos para comprobar el estado de los hosts..."
    for ((i = segundos; i > 0; i--)); do
        echo -ne "\rTiempo restante: $i segundos "
        sleep 1
    done
    echo -e "\n"
}

declare -a resultados


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


# Informa al usuario y espera 20 segundos con un timer
mostrar_timer 20


# Comprueba el estado de cada host
for host in "$@"; do
    hostname="$host.etsii.ull.es"
    comprobar_estado "$hostname"
done

