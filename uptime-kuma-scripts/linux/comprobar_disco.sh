#!/bin/bash

# --- CONFIGURACIÓN ---
PUSH_URL="http://lara.esit.ull.es/api/push/lSi2GLcPjVI65edqgQHVJr2r3GBZb6jF"
UMBRAL_GB=10
# ---------------------

# 1. Calcular el espacio real del sistema de archivos raíz (/)
GB_LIBRES=$(df -h / | awk 'NR==2 {print $4}' | sed 's/G//' )

# 2. Obtener el nombre del ordenador automáticamente
NOMBRE_PC="$(hostname)"

# 3. Evaluar si se debe disparar la alerta quedando 10GB o menos

#if [ "$GB_LIBRES" -le "$UMBRAL_GB" ]; then
if true; then
    MESSAGE="ALERTA: El equipo [$NOMBRE_PC] (Linux) se esta quedando sin espacio. Solo quedan ${GB_LIBRES}GB libres"

    curl -s -o /dev/null \
        --get \
        --data-urlencode "status=up" \
        --data-urlencode "msg=$MESSAGE" \
        "$PUSH_URL"

fi
