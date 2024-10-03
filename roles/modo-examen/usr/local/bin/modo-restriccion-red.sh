#!/bin/bash
# Este script, llamado "modo-restriccion-red", implementa restricciones temporales en la red, 
# bloqueando todo el tráfico entrante y saliente, excepto para dominios específicos, redes locales, 
# y servicios esenciales como DNS y SSH. Se utiliza para situaciones donde se requiere cortar el 
# acceso a internet, como durante exámenes o entornos controlados, permitiendo solo el acceso a 
# determinados recursos. Las reglas de bloqueo duran 1 hora y luego el tráfico se restablece 
# automáticamente a su estado normal.


# Dominios a los que se permitirá el acceso
DOMAINS=(
  "openldap.stic.ull.es"
  "campusvirtual.ull.es"
  "campusingenieriaytecnologia2425.ull.es"
  "valida.ull.es"
)

# Redes a las que se permitirá el acceso (todas las que comienzan con 10. y 193.145.)
NETWORK_10="10.0.0.0/8"
NETWORK_193="193.145.0.0/16"

# Obtener las IPs de los dominios y almacenarlas en una lista
ALLOWED_IPS=()
for domain in "${DOMAINS[@]}"; do
  ip=$(nslookup $domain | awk '/^Address: / { print $2 }' | tail -n1)
  if [ -n "$ip" ]; then
    ALLOWED_IPS+=("$ip")
    echo "Permitido acceso a $domain con IP $ip"
  else
    echo "No se pudo resolver el dominio $domain"
  fi
done

# Limpia las reglas existentes en iptables
iptables -F
iptables -X

# Permitir tráfico en la interfaz de loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permitir tráfico relacionado con conexiones ya establecidas
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT

# Permitir acceso a los servidores DNS (puertos 53 UDP y TCP)
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 53 -j ACCEPT

# Permitir conexiones SSH entrantes (puerto 22)
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Permitir acceso a las IPs obtenidas de los dominios
for ip in "${ALLOWED_IPS[@]}"; do
  iptables -A OUTPUT -p tcp -d $ip --dport 80 -j ACCEPT
  iptables -A OUTPUT -p tcp -d $ip --dport 443 -j ACCEPT
done

# Permitir acceso a toda la red 10.0.0.0/8
iptables -A OUTPUT -d $NETWORK_10 -j ACCEPT
iptables -A INPUT -s $NETWORK_10 -j ACCEPT

# Permitir acceso a toda la red 193.145.0.0/16
iptables -A OUTPUT -d $NETWORK_193 -j ACCEPT
iptables -A INPUT -s $NETWORK_193 -j ACCEPT

# Bloquear todo el tráfico saliente por defecto
iptables -P OUTPUT DROP

# Bloquear todo el tráfico entrante por defecto
iptables -P INPUT DROP


echo "Acceso bloqueado a todas las direcciones excepto las IPs permitidas, redes locales (10.x.x.x y 193.145.x.x) durante 1 minuto."

# Esperar 1 hora
#sleep 3600
sleep 60

# Restablecer las reglas predeterminadas, permitiendo todo el tráfico
iptables -P OUTPUT ACCEPT
iptables -P INPUT ACCEPT
iptables -F
iptables -X

echo "Acceso restaurado después de 1 minuto."
