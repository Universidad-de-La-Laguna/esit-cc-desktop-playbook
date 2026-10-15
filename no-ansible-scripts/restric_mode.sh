#!/bin/bash
###############################################################################
# restrict_mode.sh - Modo restringido de red con nftables
# Uso:        sudo /usr/local/bin/restrict_mode.sh
# Desactivar: sudo nft delete table inet restrict_mode
#
# Las reglas viven solo en el kernel: se pierden al reiniciar.
# Requiere nftables >= 0.9.4 y kernel >= 5.6 (flag auto-merge).
###############################################################################

LOG_FILE="/var/log/restrict_mode.log"
TABLE="restrict_mode"

ALLOWED_DOMAINS=(
    campusvirtual.ull.es valida.ull.es www.32x8.com
    www.charlie-coleman.com cdnjs.cloudflare.com olimpiada.uib.es
)
DENIED_DOMAINS=(iaas.ull.es vdi.ull.es)
ALLOWED_IPS=(
    10.4.9.29 10.4.9.30 104.16.132.229 104.16.133.229
    216.58.215.168 130.206.30.31
)
ALLOWED_NETS=(10.0.0.0/8 193.145.0.0/16)
SSH_IN_HOSTS=(cc1100 cc1200 cc1300 cc1400 cc2100 cc2200 cc2300 cc2400)
SSH_IN_NETS=(10.209.4.0/24)

log() { echo "$(date '+%F %T') - $1" >> "$LOG_FILE"; }

resolve() {  # IPv4 de un dominio; vacío si falla, sin abortar
    dig +short "$1" A 2>/dev/null | grep -E '^[0-9]+(\.[0-9]+){3}$' || true
}

# nft no admite "elements = { }" vacío: solo se emite si hay datos
elements() {
    [ $# -eq 0 ] && return
    local IFS=,
    echo "elements = { $* }"
}

log "=== Iniciando modo restringido (usuario: ${SUDO_USER:-desconocido}) ==="

sleep 60   # espera a que la red esté lista tras el login

# --- Resolver todo ANTES de tocar el firewall ---
allowed=("${ALLOWED_IPS[@]}" "${ALLOWED_NETS[@]}")
for d in "${ALLOWED_DOMAINS[@]}"; do
    ips=$(resolve "$d")
    if [ -z "$ips" ]; then log "ADVERTENCIA: no se pudo resolver $d"; continue; fi
    while read -r ip; do allowed+=("$ip"); log "Permitido: $d -> $ip"; done <<< "$ips"
done

denied=()
for d in "${DENIED_DOMAINS[@]}"; do
    ips=$(resolve "$d")
    if [ -z "$ips" ]; then log "ADVERTENCIA: no se pudo resolver $d"; continue; fi
    while read -r ip; do denied+=("$ip"); log "Denegado: $d -> $ip"; done <<< "$ips"
done

ssh_in=("${SSH_IN_NETS[@]}")
for h in "${SSH_IN_HOSTS[@]}"; do
    ip=$(getent ahostsv4 "$h" | awk 'NR==1{print $1}')
    if [ -z "$ip" ]; then log "ADVERTENCIA: no se pudo resolver $h"; continue; fi
    ssh_in+=("$ip"); log "Permitido SSH entrante desde $h ($ip)"
done

# Quitar duplicados
mapfile -t allowed < <(printf '%s\n' "${allowed[@]}" | sort -u)
mapfile -t denied  < <(printf '%s\n' "${denied[@]}"  | sort -u)
mapfile -t ssh_in  < <(printf '%s\n' "${ssh_in[@]}"  | sort -u)

# --- Generar el fichero de reglas nft ---
# Se escribe en un fichero temporal (mktemp: nombre único, permisos 600) y se
# carga de una sola vez con "nft -f". La carga es atómica: o se aplican todas
# las reglas o ninguna, así que nunca queda el firewall a medio configurar.
# Los "#" dentro del heredoc son comentarios de nft; las variables y $(...)
# las expande bash antes de escribir el fichero.
RULES=$(mktemp)
cat > "$RULES" <<EOF
# Truco de idempotencia: "add" crea la tabla vacía si no existe (así el
# "delete" siguiente no falla la primera vez) y "delete" la borra si existía.
# Después se define de nuevo desde cero: ejecutar el script varias veces
# reemplaza la tabla en vez de acumular reglas duplicadas.
add table inet $TABLE
delete table inet $TABLE

# "inet" = una sola tabla que cubre IPv4 e IPv6
table inet $TABLE {

    # Sets: listas de direcciones que las reglas consultan con @nombre.
    # "interval" permite redes (10.0.0.0/8) además de IPs sueltas.
    # "auto-merge" fusiona intervalos solapados (p. ej. 10.4.9.29 dentro de 10.0.0.0/8)
    # en vez de dar error.
    # elements(...) rellena el set desde los arrays de bash.

    # Destinos permitidos (IPs fijas, redes y dominios ya resueltos)
    set allowed { type ipv4_addr; flags interval; auto-merge; $(elements "${allowed[@]}") }
    # Destinos prohibidos aunque estén dentro de una red permitida (iaas, vdi)
    set denied  { type ipv4_addr; flags interval; auto-merge; $(elements "${denied[@]}") }
    # Orígenes autorizados a entrar por SSH (ordenadores de profesor y red admin)
    set ssh_in  { type ipv4_addr; flags interval; auto-merge; $(elements "${ssh_in[@]}") }

    # Tráfico SALIENTE de esta máquina. Se evalúa en orden, de arriba abajo,
    # y la primera regla que coincide decide.
    chain output {
        # "hook output" = engancha en la salida; "policy accept" = lo que no
        # case con ninguna regla pasa (aquí nunca ocurre: la última regla es drop)
        type filter hook output priority 0; policy accept;

        tcp dport 22 drop                      # sin SSH saliente (va antes que lo, como el original)
        ip daddr @denied drop                  # bloquea iaas/vdi antes de las reglas de permitir
        oif lo accept                          # loopback siempre permitido
        ct state established,related accept    # respuestas a conexiones ya permitidas
        meta nfproto ipv6 drop                 # corta todo IPv6 para evitar saltarse el filtro
        ip daddr @allowed accept               # destinos permitidos
        drop                                   # todo lo demás, bloqueado
    }

    # Tráfico ENTRANTE: solo se restringe el SSH.
    chain input {
        type filter hook input priority 0; policy accept;

        tcp dport 22 ip saddr @ssh_in accept   # SSH solo desde orígenes autorizados
        tcp dport 22 drop                      # el resto de intentos de SSH, bloqueados
    }
}
EOF

# Aplicar las reglas. Si nft detecta un error de sintaxis, no se aplica nada.
if nft -f "$RULES"; then
    log "=== Modo restringido activado correctamente ==="
else
    log "ERROR: fallo al aplicar las reglas nft"
    rm -f "$RULES"; exit 1
fi
rm -f "$RULES"

echo "MODO RESTRINGIDO DE RED ACTIVADO"
echo "Acceso permitido a: ${ALLOWED_DOMAINS[*]}, ${ALLOWED_NETS[*]} y IPs específicas."
echo "SSH entrante solo desde ordenadores de profesor y red admin."
echo "Log: $LOG_FILE"