#!/usr/bin/env bash

LDAP_SERVER="193.145.100.18"
LDAP_PORT=389
LDAP_USER="uid=pgonyan"

# --- Datos básicos ---
HOSTNAME=$(hostname -s)

OS_VERSION=$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')

IP_ADDR=$(ip -4 route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}')

MAC_ADDR=$(ip link | awk '/link\/ether/ {print $2; exit}')

echo "HOST=$HOSTNAME OS=$OS_VERSION IP=$IP_ADDR MAC=$MAC_ADDR"

# --- Telnet (timeout corto) ---
timeout 3 bash -c "echo >/dev/tcp/${LDAP_SERVER}/${LDAP_PORT}" \
    && echo "TELNET=OK" \
    || echo "TELNET=FAIL"

# --- Nmap rápido ---
if command -v nmap >/dev/null 2>&1; then
    NMAP_RESULT=$(nmap -p ${LDAP_PORT} -Pn -n --host-timeout 3s ${LDAP_SERVER} 2>/dev/null | grep "${LDAP_PORT}/tcp" | awk '{print $2}')
    echo "NMAP=${NMAP_RESULT:-FAIL}"
else
    echo "NMAP=NO_CMD"
fi

# --- Tcpdump prueba LDAP ---
if command -v tcpdump >/dev/null 2>&1; then
    timeout 5 tcpdump -nn -c 1 host ${LDAP_SERVER} and port ${LDAP_PORT} >/dev/null 2>&1 &
    TCPDUMP_PID=$!

    sleep 1
    timeout 3 bash -c "echo >/dev/tcp/${LDAP_SERVER}/${LDAP_PORT}" >/dev/null 2>&1

    wait $TCPDUMP_PID >/dev/null 2>&1 \
        && echo "TCPDUMP=OK" \
        || echo "TCPDUMP=FAIL"
else
    echo "TCPDUMP=NO_CMD"
fi

# --- ldapsearch ---
if command -v ldapsearch >/dev/null 2>&1; then
    ldapsearch -x -H ldap://${LDAP_SERVER}:${LDAP_PORT} "${LDAP_USER}"  -b dc=ull,dc=es  -LLL -o nettimeout=3 >/dev/null 2>&1 \
        && echo "LDAPSEARCH=OK" \
        || echo "LDAPSEARCH=FAIL"
else
    echo "LDAPSEARCH=NO_CMD"
fi