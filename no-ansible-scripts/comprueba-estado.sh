#!/bin/bash

# Verifica que se haya proporcionado al menos un argumento
if [ $# -lt 1 ]; then
    echo "Uso: $0 <nombre_del_host_sin_etsii>"
    exit 1
fi

# Nombre de archivo que contiene las MAC addresses
archivo="../resources/ansible/hosts"

# Función para comprobar el estado de los hosts
comprobar_estado() {
    local hostname=$1
    if ping -c 1 -W 1 "$hostname" &>/dev/null; then
        echo -e "\e[32m$hostname está ENCENDIDO\e[0m"
    else
        echo -e "\e[31m$hostname está APAGADO\e[0m"
    fi
}

# Comprueba el estado de cada host
for host in "$@"; do
    hostname="$host.etsii.ull.es"
    comprobar_estado "$hostname"
done

