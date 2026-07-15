#!/bin/bash
# Autor: Javier García "jgarciab"

#Este script activa WoL en sistemas operativos linux y activa el servicio para que sea persistente, detecta el nombre de la interfaz de red que suelen empezar por enp, (estar pendiente de excepciones.)

if [ $# -eq 0 ]; then
    echo "Uso: $0 equipo1 equipo2 ..."
    exit 1
fi

# Bucle sobre los equipos recibidos por línea de comandos
for i in "$@"; do
    echo "=== Configurando WoL en $i ==="
    ssh root@$i '
        # 1. Descubrir dinámicamente el nombre de la tarjeta que empieza por "enp"
        INTERFAZ=$(ip -o link show | awk -F": " '\''$2 ~ /^enp/ {print $2}'\'' | head -n 1)

        # Verificar si se encontró la interfaz para evitar errores
        if [ -z "$INTERFAZ" ]; then
            echo "[ERROR] No se encontró ninguna interfaz que empiece por enp en $i"
            exit 1
        fi

        echo "Interfaz detectada: $INTERFAZ"

        # 2. Instalar ethtool si no existe
        apt-get update -y && apt-get install -y ethtool

        # 3. Activar WoL de forma inmediata en la interfaz detectada
        ethtool -s "$INTERFAZ" wol g

        # 4. Crear el servicio de systemd para persistencia usando la variable
        cat << EOF > /etc/systemd/system/wol.service
[Unit]
Description=Enable Wake On Lan en $INTERFAZ
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ethtool -s $INTERFAZ wol g

[Install]
WantedBy=basic.target
EOF

        # 5. Habilitar y arrancar el servicio
        systemctl daemon-reload
        systemctl enable wol.service
        systemctl start wol.service

        # 6. Comprobar el estado final
        ethtool "$INTERFAZ" | grep -i wake-on
    '
done
