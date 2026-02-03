#!/bin/bash

# Script de monitorización DNS y conectividad
LOGFILE="/var/log/network_monitor.log"
touch "$LOGFILE" 2>/dev/null || LOGFILE="$HOME/network_monitor.log"

# DNS corporativo a monitorizar
DNS_SERVER="10.4.9.29"

echo "=== Inicio de monitorización: $(date) ===" >> "$LOGFILE"
echo "Monitorizando DNS: $DNS_SERVER" >> "$LOGFILE"
echo "Guardando logs en: $LOGFILE"

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Test DNS contra 10.4.9.29
    if command -v dig &> /dev/null; then
        DNS_RESULT=$(dig +short +time=2 +tries=1 @${DNS_SERVER} gpu1.esit.ull.es A 2>&1)
        DNS_STATUS=$?
        
        if [ $DNS_STATUS -eq 0 ] && [ -n "$DNS_RESULT" ]; then
            echo "[$TIMESTAMP] DNS OK - gpu1.esit.ull.es -> $DNS_RESULT (vía $DNS_SERVER)" >> "$LOGFILE"
        else
            echo "[$TIMESTAMP] DNS FAIL - gpu1.esit.ull.es (servidor: $DNS_SERVER)" >> "$LOGFILE"
        fi
    else
        DNS_RESULT=$(host -W 2 gpu1.esit.ull.es $DNS_SERVER 2>&1)
        DNS_STATUS=$?
        
        if [ $DNS_STATUS -eq 0 ]; then
            DNS_IP=$(echo "$DNS_RESULT" | awk '/has address/ {print $4}')
            echo "[$TIMESTAMP] DNS OK - gpu1.esit.ull.es -> $DNS_IP (vía $DNS_SERVER)" >> "$LOGFILE"
        else
            echo "[$TIMESTAMP] DNS FAIL - gpu1.esit.ull.es (servidor: $DNS_SERVER)" >> "$LOGFILE"
        fi
    fi
    
    # Test ping
    PING_RESULT=$(ping -c 1 -W 2 10.209.32.231 2>&1)
    
    if [ $? -eq 0 ]; then
        PING_TIME=$(echo "$PING_RESULT" | sed -n 's/.*time=\([0-9.]*\).*/\1/p')
        echo "[$TIMESTAMP] PING OK - 10.209.32.231 - ${PING_TIME}ms" >> "$LOGFILE"
    else
        echo "[$TIMESTAMP] PING FAIL - 10.209.32.231" >> "$LOGFILE"
    fi
    
    sleep 60
done