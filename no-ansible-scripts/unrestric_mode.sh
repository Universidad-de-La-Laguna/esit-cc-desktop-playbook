#!/bin/bash

###############################################################################
# Script: unrestric_mode.sh
# Descripción: Elimina todas las reglas y filtros aplicados por restric_mode.sh
# Uso: sudo /usr/local/bin/unrestric_mode.sh
###############################################################################

set -e

LOG_FILE="/var/log/restric_mode.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "=== Desactivando modo restringido para usuario: $SUDO_USER ==="

# Eliminar referencia a la cadena RESTRIC_MODE en OUTPUT
iptables -D OUTPUT -j RESTRIC_MODE 2>/dev/null || true

# Eliminar la cadena RESTRIC_MODE si existe
iptables -F RESTRIC_MODE 2>/dev/null || true
iptables -X RESTRIC_MODE 2>/dev/null || true

log_message "Modo restringido eliminado correctamente"

echo "╔════════════════════════════════════════════════════════╗"
echo "║     MODO RESTRINGIDO DE RED DESACTIVADO               ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Se han eliminado todas las reglas impuestas por restric_mode.sh."
echo "El tráfico de red vuelve a estar sin restricciones."
echo "Log: $LOG_FILE"
echo ""
