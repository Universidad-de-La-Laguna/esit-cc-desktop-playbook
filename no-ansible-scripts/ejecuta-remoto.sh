#!/bin/bash

# Validar parámetros
if [[ $# -ne 2 ]]; then
  echo "Uso: $0 <host_remoto> <ruta_script_remoto>"
  exit 1
fi

# Variables
REMOTE_USER="root"
REMOTE_HOST="$1"
REMOTE_SCRIPT="$2"

# Ejecutar el script en el host remoto
ssh "${REMOTE_USER}@${REMOTE_HOST}" "bash -s" < "${REMOTE_SCRIPT}"

