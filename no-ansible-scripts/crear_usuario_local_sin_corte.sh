#!/usr/bin/env bash
set -euo pipefail

USERNAME="${1:-}"
PASSWORD="${2:-}"
ZIP_PATH="${3:-./pa_material.zip}"
USER_HOME="/home/${USERNAME}"
DESKTOP_DIR="${USER_HOME}/Desktop"

echo "================ $HOSTNAME"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Debe ejecutarse como root." >&2
  exit 1
fi

if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
  echo "Uso: $0 <USUARIO> <PASSWORD> [RUTA_A_MATERIALBASH.ZIP]" >&2
  exit 2
fi

# Verificar que el nombre de usuario no comience por "exam"
if [[ "$USERNAME" =~ ^exam ]]; then
  echo "El nombre de usuario no puede comenzar por 'exam'." >&2
  exit 3
fi

if [[ ! -f "$ZIP_PATH" ]]; then
  echo "Fichero no encontrado: $ZIP_PATH" >&2
  exit 4
fi

# Si el usuario existe, eliminarlo completamente
if id "$USERNAME" &>/dev/null; then
  echo "El usuario ${USERNAME} ya existe. Se eliminará y recreará."
  userdel -r "$USERNAME" 2>/dev/null || true
  rm -rf "$USER_HOME"
fi

# Crear usuario con home y bash
useradd -m -s /bin/bash "$USERNAME"
echo "Usuario ${USERNAME} creado."

# Asignar contraseña cifrada con SHA512
echo "${USERNAME}:${PASSWORD}" | chpasswd --crypt-method SHA512

# Preparar el Escritorio
mkdir -p "$DESKTOP_DIR"
chown "$USERNAME":"$USERNAME" "$DESKTOP_DIR"
chmod 700 "$DESKTOP_DIR"

# Copiar y descomprimir el material
cp -f "$ZIP_PATH" "$DESKTOP_DIR/"
chown "$USERNAME":"$USERNAME" "${DESKTOP_DIR}/$(basename "$ZIP_PATH")"

if command -v unzip &>/dev/null; then
  sudo -u "$USERNAME" unzip -o "${DESKTOP_DIR}/$(basename "$ZIP_PATH")" -d "$DESKTOP_DIR" >/dev/null
else
  echo "Necesita 'unzip' instalado para descomprimir. Instálelo e intente de nuevo." >&2
  exit 5
fi

# Ajustar permisos finalesls -l
chown -R "$USERNAME":"$USERNAME" "$DESKTOP_DIR"

echo "Operación completada: usuario=${USERNAME}, zip copiado y descomprimido en ${DESKTOP_DIR}."

