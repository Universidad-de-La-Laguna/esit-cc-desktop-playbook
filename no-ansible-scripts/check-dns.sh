#!/bin/bash

# Script de monitorización DNS y conectividad
# Archivo de log
LOGFILE="/var/log/network_monitor.log"

# Crear el archivo de log si no existe
touch "$LOGFILE" 2>/dev/null || LOGFILE="$HOME/network_monitor.log"

echo "=== Inicio de monitorización: $(date) ===" >> "$LOGFILE"
echo "Guardando logs en: $LOGFILE"

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Test de resolución DNS
    DNS_RESULT=$(nslookup gpu1.esit.ull.es 2>&1)
    DNS_STATUS=$?
    
    if [ $DNS_STATUS -eq 0 ]; then
        DNS_IP=$(echo "$DNS_RESULT" | grep -A1 "Name:" | grep "Address:" | awk '{print $2}' | head -1)
        echo "[$TIMESTAMP] DNS OK - gpu1.esit.ull.es -> $DNS_IP" >> "$LOGFILE"
    else
        echo "[$TIMESTAMP] DNS FAIL - gpu1.esit.ull.es - Error en resolución" >> "$LOGFILE"
    fi
    
    # Test de ping
    PING_RESULT=$(ping -c 1 -W 2 10.209.32.231 2>&1)
    PING_STATUS=$?
    
    if [ $PING_STATUS -eq 0 ]; then
        PING_TIME=$(echo "$PING_RESULT" | grep "time=" | sed 's/.*time=\([0-9.]*\).*/\1/')
        echo "[$TIMESTAMP] PING OK - 10.209.32.231 - ${PING_TIME}ms" >> "$LOGFILE"
    else
        echo "[$TIMESTAMP] PING FAIL - 10.209.32.231 - Sin respuesta" >> "$LOGFILE"
    fi
    
    # Esperar 60 segundos
    sleep 60
done
