#!/bin/bash
# Autor: Javier García "jgarciab"

#Este script reinicia los equipos eligiendo la entrada en UEFI detectada como "Windows Boot Manager" se parte siempre de equipos encendidos con Ubuntu ya arrancado. Se trata de una utilidad pensada para reiniciar rapidamente una sala a Windows y realizar actualizaciones.

#Está pendiente implementar funcion que permita varios reinicios continuados de Windows de manera que en un proceso de actualización la misma se pueda realizar de manera semiautomatizada sin eque el técnico tenga que intervenir manualmente. 

if [ $# -eq 0 ]; then
    echo "Uso: $0 equipo1 equipo2 ..."
    exit 1
fi

# Bucle sobre los equipos recibidos por línea de comandos
for i in "$@"; do
    echo "=== Configurando reinicio a Windows en $i ==="

    ssh -o ConnectTimeout=6 -o BatchMode=yes root@"$i" '
        # 1. Obtener la salida de efibootmgr
        efiob_output=$(efibootmgr)

        # 2. Extraer el número hexadecimal de 4 dígitos de Windows Boot Manager
        boot_num=$(echo "$efiob_output" | grep -i "Windows Boot Manager" | grep -oE "Boot[0-9A-Fa-f]{4}" | head -n 1 | cut -c 5-)

        # 3. Validar si se encontró la entrada
        if [ -z "$boot_num" ]; then
            echo "   [ERROR] No se encontró la entrada de Windows en $(hostname)." >&2
            exit 1
        fi

        echo "   [OK] Detectada entrada Windows: $boot_num. Reiniciando..."

        # 4. Programar el próximo arranque único y reiniciar
        efibootmgr -n "$boot_num" && reboot
    '

    if [ $? -ne 0 ]; then
        echo "   [ERROR] No se pudo conectar a $i o el comando falló." >&2
    fi

    echo "------------------------------------------------"
done