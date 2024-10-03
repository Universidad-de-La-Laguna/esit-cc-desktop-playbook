#!/bin/bash

# Verifica que se pase un argumento (la dirección IP o el hostname)
if [ "$#" -ne 1 ]; then
    echo "Uso: $0 <dirección_IP_o_hostname>"
    exit 1
fi

# Asigna la dirección IP o el hostname a una variable
remote_host="$1"

# Ruta de la clave privada compartida
private_key="/etc/id_rsa_modorestringido"

# Comprobar si la clave privada existe
if [ ! -f "$private_key" ]; then
    echo "La clave privada no se encuentra en $private_key"
    exit 1
fi

# Ejecutar el script en el host remoto usando la clave privada
if ssh -i "$private_key" usuario_ssh@"$remote_host" "sudo /usr/local/bin/modo-restriccion-red.sh"; then
    echo "El script se ejecutó correctamente en $remote_host."
else
    echo -e "\e[31mError al ejecutar el script en $remote_host.\e[0m"  # Mensaje en rojo
fi
