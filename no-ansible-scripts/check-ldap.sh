#!/usr/bin/env bash

LDAP_SERVER="193.145.100.18"
LDAP_PORT=389
LDAP_BASE="dc=ull,dc=es"
LDAP_FILTER="uid=pgonyan"

# --- Datos básicos ---
HOSTNAME=$(hostname -s)

OS_VERSION=$(grep '^PRETTY_NAME=' /etc/os-release 2>/dev/null | cut -d= -f2 | tr -d '"')

IP_ADDR=$(ip -4 route get 8.8.8.8 2>/dev/null | awk '{print $7; exit}')

MAC_ADDR=$(ip link | awk '/link\/ether/ {print $2; exit}')

echo "HOST=$HOSTNAME OS=$OS_VERSION IP=$IP_ADDR MAC=$MAC_ADDR"

# --- Telnet ---
timeout 3 bash -c "echo >/dev/tcp/${LDAP_SERVER}/${LDAP_PORT}" \
    && echo "TELNET=OK" \
    || echo "TELNET=FAIL"

# --- Nmap ---
if command -v nmap >/dev/null 2>&1; then
    NMAP_RESULT=$(nmap -p ${LDAP_PORT} -Pn -n --host-timeout 3s ${LDAP_SERVER} 2>/dev/null | grep "${LDAP_PORT}/tcp" | awk '{print $2}')
    echo "NMAP=${NMAP_RESULT:-FAIL}"
else
    echo "NMAP=NO_CMD"
fi

# --- Tcpdump salida + entrada diferenciadas ---
if command -v tcpdump >/dev/null 2>&1; then

    IFACE=$(ip route get ${LDAP_SERVER} | awk '{print $5; exit}')

    TCPDUMP_OUT=$(timeout 6 tcpdump -i ${IFACE} -nn -c 1 "dst host ${LDAP_SERVER} and port ${LDAP_PORT}" 2>/dev/null &)

    sleep 1

    timeout 3 bash -c "echo >/dev/tcp/${LDAP_SERVER}/${LDAP_PORT}" >/dev/null 2>&1

    TCPDUMP_IN=$(timeout 6 tcpdump -i ${IFACE} -nn -c 1 "src host ${LDAP_SERVER} and port ${LDAP_PORT}" 2>/dev/null)

    if [ $? -eq 0 ]; then
        echo "TCPDUMP_OUT=OK"
    else
        echo "TCPDUMP_OUT=FAIL"
    fi

    if [ -n "$TCPDUMP_IN" ]; then
        echo "TCPDUMP_IN=OK"
    else
        echo "TCPDUMP_IN=FAIL"
    fi

else
    echo "TCPDUMP_OUT=NO_CMD"
    echo "TCPDUMP_IN=NO_CMD"
fi

# --- ldapsearch ---
if command -v ldapsearch >/dev/null 2>&1; then
    ldapsearch -x \
        -H ldap://${LDAP_SERVER}:${LDAP_PORT} \
        -b ${LDAP_BASE} \
        "${LDAP_FILTER}" \
        -LLL -o nettimeout=3 >/dev/null 2>&1 \
        && echo "LDAPSEARCH=OK" \
        || echo "LDAPSEARCH=FAIL"
else
    echo "LDAPSEARCH=NO_CMD"
fi