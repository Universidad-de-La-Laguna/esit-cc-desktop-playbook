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

    echo "=== Comprobando $equipo ==="

    # Comprobar si el equipo está encendido
    if ! ping -c 1 -W 1 "$equipo" &>/dev/null; then
        echo "[$equipo] YA ESTABA APAGADO / NO DISPONIBLE"
        return
    fi

    echo "[$equipo] Encendido, intentando apagar..."

    if ssh -o ConnectTimeout=5 \
           -o StrictHostKeyChecking=accept-new \
           root@"$equipo" 'poweroff'; then
        echo "[$equipo] APAGADO CORRECTAMENTE"
    else
        echo "[$equipo] ERROR SSH" >&2
    fi
}

# Lanzar todos en paralelo
for equipo in "$@"; do
    apagar_equipo "$equipo" &
done

# Esperar a que terminen todos
wait

echo
echo "Todos los intentos de apagado han finalizado."