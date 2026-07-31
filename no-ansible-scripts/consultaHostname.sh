#!/bin/bash

#CONSULTA "hostnamectl" PARA UNA SERIE DE EQUIPOS CLIENTES ESTABLECIDOS
# Comprueba si has pasado al menos un servidor como argumento
if [ $# -eq 0 ]; then
    echo "Error: Debes indicar al menos un servidor."
    echo "Uso: $0 servidor1 servidor2 ..."
    exit 1
fi

echo "Iniciando consulta de hostnames..."
echo "---------------------------------"

# $@ contiene todos los argumentos que pases al ejecutar el script
for servidor in "$@"; do
    (
        # Ejecuta en paralelo y controla el tiempo de espera
        hostname_remoto=$(ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=accept-new "$servidor" "hostname" 2>/dev/null)
        
        if [ -n "$hostname_remoto" ]; then
            echo "[OK] $servidor responde: $hostname_remoto"
        else
            echo "[ERROR] No se pudo conectar con $servidor"
        fi
    ) &
done

# Espera a que terminen todas las conexiones en segundo plano
wait

echo "---------------------------------"
echo "Consulta finalizada."
