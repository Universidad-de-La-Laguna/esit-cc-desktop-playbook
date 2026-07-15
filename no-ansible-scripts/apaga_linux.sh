#!/bin/bash
# Autor: Javier García "jgarciab"
if [ $# -eq 0 ]; then
    echo "Uso: $0 equipo1 equipo2 ..."
    exit 1
fi

echo "============================================================"
echo "                     ATENCIÓN"
echo "============================================================"
echo
echo "Esta operación apagará de forma inmediata los equipos"
echo "especificados, incluso si existen usuarios con sesiones"
echo "abiertas o trabajos sin guardar."
echo
echo "Realice esta operación únicamente en un entorno controlado."
echo
read -rp "Escriba 'Yes' y pulse Enter para continuar, o pulse Enter para cancelar: " confirm

if [[ "$confirm" != "Yes" ]]; then
    echo "Operación cancelada."
    exit 0
fi

echo
echo "Iniciando apagado..."
echo

apagar_equipo() {

    local equipo="$1"

    echo "=== Apagando $equipo ==="

    if ssh -o ConnectTimeout=1 -o BatchMode=yes root@"$equipo" 'poweroff'; then
        echo "[$equipo] OK"
    else
        echo "[$equipo] ERROR" >&2
    fi
}

comprobar_estado() {
    local hostname=$1
    if ping -c 1 -W 1 "$hostname" &>/dev/null; then
        echo -e "\e[32m$hostname SIGUE ENCENDIDO\e[0m"
    fi
}

# Lanzar todos en paralelo
for equipo in "$@"; do
    apagar_equipo "$equipo" &
done

# Esperar a que terminen todos
wait

echo "Todos los intentos de apagado han finalizado."

# Comprueba el estado de cada host
# for host in "$@"; do
    # hostname="$host.etsii.ull.es"
    # comprobar_estado "$hostname"
# done