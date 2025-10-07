#!/bin/bash

# --- Configuración ---
DOMINIOS=(
    "www.googletagmanager.com"
    "static.ull.es"
    "ssl.google-analytics.com"
    "cdnjs.cloudflare.com"
)
IP_FILE="/etc/iptables/allowed_ips.txt"
CRON_SCRIPT="/usr/local/bin/iptables_actualizar.sh"

mkdir -p "$(dirname "$IP_FILE")"
touch "$IP_FILE"
mkdir -p "$(dirname "$CRON_SCRIPT")"

# --- Script principal de iptables ---
cat > "$CRON_SCRIPT" << 'EOF'
#!/bin/bash
DOMINIOS=(
    "www.googletagmanager.com"
    "static.ull.es"
    "ssl.google-analytics.com"
    "cdnjs.cloudflare.com"
)
IP_FILE="/etc/iptables/allowed_ips.txt"
mkdir -p "$(dirname "$IP_FILE")"
touch "$IP_FILE"
for DOM in "${DOMINIOS[@]}"; do
    IPS=$(dig +short "$DOM" | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$')
    for IP in $IPS; do
        if ! grep -qx "$IP" "$IP_FILE"; then
            iptables -C INPUT -s "$IP" -j ACCEPT 2>/dev/null || iptables -I INPUT -s "$IP" -j ACCEPT
            echo "$IP" >> "$IP_FILE"
        fi
    done
done
iptables-save > /etc/iptables/rules.v4
EOF

chmod +x "$CRON_SCRIPT"

# --- Añadir al crontab de root si no existe (cada 3 minutos) ---
(crontab -l 2>/dev/null | grep -v -F "$CRON_SCRIPT"; echo "*/3 * * * * $CRON_SCRIPT >/dev/null 2>&1") | crontab -
