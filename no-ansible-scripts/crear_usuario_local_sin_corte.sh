#!/usr/bin/env bash
set -euo pipefail

USERNAME="${1:-}"
PASSWORD="${2:-}"
ZIP_PATH1="${3:-}"
ZIP_PATH2="${4:-}"
USER_HOME="/home/${USERNAME}"
DESKTOP_DIR="${USER_HOME}/Desktop"

echo "================ $HOSTNAME"

if [[ "$(id -u)" -ne 0 ]]; then
  echo "Debe ejecutarse como root." >&2
  exit 1
fi

if [[ -z "$USERNAME" || -z "$PASSWORD" ]]; then
  echo "Uso: $0 <USUARIO> <PASSWORD> <ZIP1> [ZIP2]" >&2
  exit 2
fi

# Validar nombre de usuario
if [[ ! "$USERNAME" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
  echo "Nombre de usuario inválido." >&2
  exit 6
fi

# Verificar que el nombre de usuario no comience por "exam"
if [[ "$USERNAME" =~ ^exam ]]; then
  echo "El nombre de usuario no puede comenzar por 'exam'." >&2
  exit 3
fi

# Verificar que al menos el primer ZIP exista
if [[ -z "$ZIP_PATH1" || ! -f "$ZIP_PATH1" ]]; then
  echo "Fichero no encontrado: $ZIP_PATH1" >&2
  exit 4
fi

# Verificar el segundo ZIP solo si se proporcionó
if [[ -n "$ZIP_PATH2" && ! -f "$ZIP_PATH2" ]]; then
  echo "Fichero no encontrado: $ZIP_PATH2" >&2
  exit 4
fi

# Verificar que unzip esté disponible
if ! command -v unzip &>/dev/null; then
  echo "Necesita 'unzip' instalado para descomprimir. Instálelo e intente de nuevo." >&2
  exit 5
fi

# Si el usuario existe, eliminarlo completamente
if id "$USERNAME" &>/dev/null; then
  echo "El usuario ${USERNAME} ya existe. Se eliminará y recreará."
  pkill -u "$USERNAME" 2>/dev/null || true
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
chmod 755 "$DESKTOP_DIR"

# Función para copiar y descomprimir un ZIP
process_zip() {
  local zip_path="$1"
  local zip_name=$(basename "$zip_path")
  
  echo "Procesando ${zip_name}..."
  
  # Copiar el ZIP al escritorio
  cp -f "$zip_path" "$DESKTOP_DIR/"
  chown "$USERNAME":"$USERNAME" "${DESKTOP_DIR}/${zip_name}"
  
  # Descomprimir como el usuario
  sudo -u "$USERNAME" unzip -o "${DESKTOP_DIR}/${zip_name}" -d "$DESKTOP_DIR" >/dev/null
  
  echo "  → ${zip_name} copiado y descomprimido."
}

# Procesar el primer ZIP (obligatorio)
process_zip "$ZIP_PATH1"

# Procesar el segundo ZIP si existe
if [[ -n "$ZIP_PATH2" ]]; then
  process_zip "$ZIP_PATH2"
fi

# Ajustar permisos finales
chown -R "$USERNAME":"$USERNAME" "$DESKTOP_DIR"

echo "Operación completada: usuario=${USERNAME}, archivos procesados en ${DESKTOP_DIR}."