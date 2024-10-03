#!/bin/bash

# Verificamos si se pasaron los argumentos necesarios
if [ $# -ne 2 ]; then
    echo "Uso: $0 <sala> <modo>"
    echo "Por ejemplo: $0 sala13 activo"
    exit 1
fi

# Asignamos los parámetros a variables para mejor legibilidad
sala=$1
modo=$2

# Ejecutamos el modo si es necesario
if [ "$modo" == "activado" ]; then
    echo "Modo activado en $sala."
    # Aquí puedes añadir más comandos para activar el modo
# Ejecutamos el script según la sala especificada
    case "$sala" in
        sala11) modo-restriccion-red-pc-remoto.sh cc11{1..4}{1..6} ;;
        sala12) modo-restriccion-red-pc-remoto.sh cc12{1..4}{1..6} ;;
        sala13) modo-restriccion-red-pc-remoto.sh cc13{1..3}{1..6} ;;
        sala14) modo-restriccion-red-pc-remoto.sh cc14{1..4}{1..6} ;;
        sala21) modo-restriccion-red-pc-remoto.sh cc21{1..4}{1..8} ;;
        sala22) modo-restriccion-red-pc-remoto.sh cc22{1..4}{1..6} ;;
        sala23) modo-restriccion-red-pc-remoto.sh cc23{1..4}{1..8} ;;
        sala24) modo-restriccion-red-pc-remoto.sh cc24{1..4}{1..6} ;;
        *) echo "Sala no reconocida. Usa 'sala11', 'sala12', ..., 'sala24'." ;;
    esac

elif [ "$modo" == "desactivado" ]; then
    echo "Modo desactivado en $sala."
    # Aquí puedes añadir más comandos para desactivar el modo
else
    echo "Modo no reconocido. Usa 'activado' o 'desactivado'."
    exit 1
fi

exit 0

