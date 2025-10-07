#!/bin/bash

###############################################################################
# Script: restric_mode.sh
# Descripción: Restringe el acceso a Internet permitiendo solo ciertos destinos
#              Se ejecuta automáticamente al hacer login usuarios exam*
# Destinos permitidos:
#   - campusvirtual.ull.es
#   - valida.ull.es
#   - 10.4.9.29
#   - 10.4.9.30
# Uso: sudo /usr/local/bin/restric_mode.sh
###############################################################################

set -e

# Dominios y direcciones permitidas
ALLOWED_DOMAINS=(
    "campusvirtual.ull.es"
    "valida.ull.es"
)

ALLOWED_IPS=(
    "10.4.9.29"
    "10.4.9.30"
)

LOG_FILE="/var/log/restric_mode.log"

# Función de logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "=== Iniciando modo restringido para usuario: $SUDO_USER ==="

# Limpiar reglas existentes de iptables para el usuario
log_message "Limpiando reglas anteriores..."

# Crear cadena personalizada si no existe
iptables -N RESTRIC_MODE 2>/dev/null || iptables -F RESTRIC_MODE

# Limpiar la cadena
iptables -F RESTRIC_MODE

# Política por defecto: DENEGAR todo el tráfico saliente
log_message "Aplicando política restrictiva..."

# Permitir loopback (localhost)
iptables -A RESTRIC_MODE -o lo -j ACCEPT
log_message "Permitido: loopback (localhost)"

# Permitir conexiones establecidas y relacionadas
iptables -A RESTRIC_MODE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
log_message "Permitido: conexiones establecidas"

# Permitir IPs específicas
for ip in "${ALLOWED_IPS[@]}"; do
    iptables -A RESTRIC_MODE -d "$ip" -j ACCEPT
    log_message "Permitido: IP $ip"
done

# Permitir toda la red 10.x.x.x
iptables -A RESTRIC_MODE -d 10.0.0.0/8 -j ACCEPT
log_message "Permitido: red 10.0.0.0/8 (todas las IPs 10.x.x.x)"

# Para cada dominio permitido, se resuelve a direcciones IPv4 y se añaden reglas iptables para permitir el tráfico hacia esas IPs
for domain in "${ALLOWED_DOMAINS[@]}"; do
    # Resolver el dominio a IPs (tanto IPv4)
    domain_ips=$(dig +short "$domain" A 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
    if [ -n "$domain_ips" ]; then
        while IFS= read -r ip; do
            iptables -A RESTRIC_MODE -d "$ip" -j ACCEPT
            log_message "Permitido: $domain -> $ip"
        done <<< "$domain_ips"
    else
        log_message "ADVERTENCIA: No se pudo resolver $domain"
    fi
done

# Permitir DNS (necesario para resolver nombres)
iptables -A RESTRIC_MODE -p udp --dport 53 -j ACCEPT
iptables -A RESTRIC_MODE -p tcp --dport 53 -j ACCEPT
log_message "Permitido: DNS (puerto 53)"

# DENEGAR todo lo demás
iptables -A RESTRIC_MODE -j DROP
log_message "Denegado: todo el resto del tráfico"

# Aplicar la cadena al tráfico OUTPUT
iptables -I OUTPUT 1 -j RESTRIC_MODE

log_message "=== Modo restringido activado correctamente ==="

echo "╔════════════════════════════════════════════════════════╗"
echo "║     MODO RESTRINGIDO DE RED ACTIVADO                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Acceso permitido únicamente a:"
echo "  • campusvirtual.ull.es"
echo "  • valida.ull.es"
echo "  • 10.4.9.29"
echo "  • 10.4.9.30"
echo "  • 10.0.0.0./8"
echo ""
echo "Todo el demás tráfico de Internet está bloqueado."
echo "Log: $LOG_FILE"
echo ""