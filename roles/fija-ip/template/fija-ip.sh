#!/bin/bash

# Obtener el hostname de la máquina
hostname=$(hostname)

# Buscar el hostname en el archivo /etc/hosts y obtener la dirección IP correspondiente
ip=$(grep -w "$hostname" /etc/hosts | awk '{print $1}')

# Verificar si se encontró una dirección IP para el hostname
if [ -z "$ip" ]; then
            echo "No se pudo encontrar una dirección IP para el hostname $hostname en el archivo /etc/hosts."
                exit 1
        fi

        # Configurar la dirección IP estática en /etc/network/interfaces
        sed -i '/^iface eth0 inet static/,+3d' /etc/network/interfaces
        cat <<EOF >> /etc/network/interfaces
iface eth0 inet static
    address $ip
    netmask 255.255.255.0
    gateway ${ip%.*}.1
EOF

# Configurar los servidores DNS en /etc/resolv.conf
cat > /etc/resolv.conf <<EOF
nameserver 10.4.9.29
nameserver 10.4.9.30
EOF

# Reiniciar el servicio de red para aplicar los cambios
systemctl restart networking

echo "La dirección IP $ip se ha configurado correctamente y persistirá después de un reinicio."