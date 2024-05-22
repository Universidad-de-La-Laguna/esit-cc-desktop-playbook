#!/bin/bash

# Verifica si se han proporcionado argumentos
if [ $# -eq 0 ]; then
    echo "Uso: $0 host1 host2 host3 ..."
    exit 1
fi

# Define la IP a la que se va a hacer ping
IP="10.209.31.1"

# Función para realizar el ping y comprobar el resultado
check_ping() {
    local host=$1
    echo "Conectando a $host..."
    # Ejecuta el ping en el host remoto
    ssh "$host" "ping -c 6 $IP > /dev/null 2>&1"
    if [ $? -ne 0 ]; then
        echo "ERROR: $host"
    else
        echo "Ping a $IP en $host fue exitoso"
    fi
}

# Bucle para recorrer cada host proporcionado como argumento
for host in "$@"; do
    check_ping "$host"
done

