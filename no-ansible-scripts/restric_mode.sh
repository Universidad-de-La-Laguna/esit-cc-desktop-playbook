#!/bin/bash

###############################################################################
# Script: restrict_mode.sh
# Descripción: Restringe el acceso a Internet permitiendo solo ciertos destinos
#              Se ejecuta automáticamente al hacer login usuarios exam*
# Destinos permitidos:
#   - campusvirtual.ull.es
#   - valida.ull.es
#   - 10.4.9.29
#   - 10.4.9.30
# Uso: sudo /usr/local/bin/restrict_mode.sh
###############################################################################

set -e

# Dominios y direcciones permitidas
ALLOWED_DOMAINS=(
    "campusvirtual.ull.es"
    "valida.ull.es"
    "www.32x8.com"
    "www.charlie-coleman.com"
    "cdnjs.cloudflare.com"           # FIX #3: corregido "cloudfare" → "cloudflare"
    "olimpiada.uib.es"
)

ALLOWED_IPS=(
    "10.4.9.29"
    "10.4.9.30"
    "104.16.132.229"
    "104.16.133.229"
    "216.58.215.168"
    "130.206.30.31"
)

LOG_FILE="/var/log/restrict_mode.log"

# Función de logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "=== Iniciando modo restringido para usuario: $SUDO_USER ==="

# Limpiar reglas existentes de iptables
log_message "Limpiando reglas anteriores..."

# FIX #1: Eliminar la cadena RESTRIC_MODE de OUTPUT antes de vaciarla/borrarla
iptables -D OUTPUT -j RESTRIC_MODE 2>/dev/null || true

# Crear cadena personalizada si no existe, o vaciarla si ya existe
iptables -N RESTRIC_MODE 2>/dev/null || iptables -F RESTRIC_MODE

# FIX #6: Bloquear TODO el tráfico IPv6 saliente para evitar bypass
log_message "Bloqueando tráfico IPv6..."
ip6tables -F OUTPUT  2>/dev/null || true
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP
log_message "IPv6 OUTPUT y FORWARD bloqueados"

# Política por defecto: DENEGAR todo el tráfico saliente
log_message "Aplicando política restrictiva..."

# Denegar acceso explícito a iaas.ull.es y vdi.ull.es
for DENY_DOMAIN in iaas.ull.es vdi.ull.es; do
    DENY_IPS=$(dig +short "$DENY_DOMAIN" A 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
    if [ -n "$DENY_IPS" ]; then
        while IFS= read -r ip; do
            iptables -A RESTRIC_MODE -d "$ip" -j DROP
            log_message "Denegado: $DENY_DOMAIN -> $ip"
        done <<< "$DENY_IPS"
    else
        log_message "ADVERTENCIA: No se pudo resolver $DENY_DOMAIN"
    fi
done

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

# Permitir el rango 193.145.0.0/16
iptables -A RESTRIC_MODE -d 193.145.0.0/16 -j ACCEPT
log_message "Permitido: red 193.145.0.0/16 (todas las IPs 193.145.x.x)"

# Para cada dominio permitido, resolver a IPv4 y añadir reglas
for domain in "${ALLOWED_DOMAINS[@]}"; do
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

# FIX #2: DNS restringido solo a resolvers de confianza (red campus + 127.0.0.53)
# Evita tunneling DNS hacia servidores externos
iptables -A RESTRIC_MODE -p udp -d 127.0.0.53   --dport 53 -j ACCEPT
iptables -A RESTRIC_MODE -p tcp -d 127.0.0.53   --dport 53 -j ACCEPT
iptables -A RESTRIC_MODE -p udp -d 193.145.0.0/16 --dport 53 -j ACCEPT
iptables -A RESTRIC_MODE -p tcp -d 193.145.0.0/16 --dport 53 -j ACCEPT
iptables -A RESTRIC_MODE -p udp -d 10.0.0.0/8    --dport 53 -j ACCEPT
iptables -A RESTRIC_MODE -p tcp -d 10.0.0.0/8    --dport 53 -j ACCEPT
log_message "Permitido: DNS solo hacia resolvers de confianza (localhost, 193.145.x.x, 10.x.x.x)"

# Bloquear SSH saliente
iptables -A RESTRIC_MODE -p tcp --dport 22 -j DROP
log_message "Bloqueado: SSH saliente"

# DENEGAR todo lo demás
iptables -A RESTRIC_MODE -j DROP
log_message "Denegado: todo el resto del tráfico"

# FIX #1: Aplicar la cadena al tráfico OUTPUT una sola vez (al final)
iptables -I OUTPUT 1 -j RESTRIC_MODE
log_message "Cadena RESTRIC_MODE aplicada a OUTPUT"

# --- PERMITIR SSH ENTRANTE DESDE HOSTS AUTORIZADOS ---
# FIX #5: Insertar las reglas ACCEPT *antes* que la regla DROP final de SSH
for HOST in cc1100 cc1200 cc1300 cc1400 cc2100 cc2200 cc2300 cc2400; do
    HOST_IP=$(getent hosts "$HOST" | awk '{ print $1 }')
    if [ -n "$HOST_IP" ]; then
        iptables -I INPUT 1 -p tcp -s "$HOST_IP" --dport 22 -j ACCEPT
        log_message "Permitido SSH entrante desde $HOST ($HOST_IP)"
    else
        log_message "ADVERTENCIA: No se pudo resolver $HOST"
    fi
done

# Permitir SSH desde la red de administración
iptables -I INPUT 1 -p tcp -s 10.209.4.0/24 -m tcp --dport 22 -j ACCEPT
log_message "Permitido: SSH entrante desde 10.209.4.0/24"

# Bloquear todo el SSH entrante por defecto (va al final, tras los ACCEPT)
iptables -A INPUT -p tcp --dport 22 -j DROP
log_message "Bloqueado: SSH entrante por defecto"

# FIX #4: Eliminada la regla redundante de 127.0.0.53 en INPUT
# (systemd-resolved en loopback ya es accesible sin regla explícita)

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
echo "  • 10.0.0.0/8"
echo "  • 193.145.0.0/16"
echo "  • olimpiada.uib.es"
echo "  • 130.206.30.31"
echo "  • SSH entrante desde ordenadores de profesor y red admin"
echo ""
echo "Todo el demás tráfico de Internet está bloqueado."
echo "Log: $LOG_FILE"
echo ""