#!/bin/bash

#############################################################################
# Script: crear_usuario_restringido.sh
# Descripción: Crea/recrea un usuario con permisos sudo restringidos
# Uso: sudo ./crear_usuario_restringido.sh <usuario> <contraseña>
#############################################################################

set -e  # Salir si hay algún error

# Colores para mensajes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para mostrar mensajes
info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Función para mostrar uso
mostrar_uso() {
    echo "Uso: sudo $0 <usuario> <contraseña>"
    echo ""
    echo "Ejemplo: sudo $0 exam1 'MiPasswordSeguro123'"
    echo ""
    echo "Este script:"
    echo "  - Crea/recrea el usuario especificado"
    echo "  - Le asigna la contraseña proporcionada"
    echo "  - Configura permisos sudo para ejecutar solo /usr/local/bin/restric_mode.sh"
    exit 1
}

# Verificar que se ejecuta como root
if [ "$EUID" -ne 0 ]; then 
    error "Este script debe ejecutarse como root (usa sudo)"
    exit 1
fi

# Verificar argumentos
if [ $# -ne 2 ]; then
    error "Número incorrecto de argumentos"
    mostrar_uso
fi

USUARIO="$1"
PASSWORD="$2"
SUDOERS_FILE="/etc/sudoers.d/${USUARIO}_sudo"
SCRIPT_PATH="/usr/local/bin/restric_mode.sh"
PROFILE_SCRIPT="/etc/profile.d/exam_restric_mode.sh"



# Validar nombre de usuario
if ! [[ "$USUARIO" =~ ^[a-z_][a-z0-9_-]*$ ]]; then
    error "Nombre de usuario inválido. Debe comenzar con letra minúscula o guión bajo"
    exit 1
fi

# Validar que el usuario comience con "exam"
if ! [[ "$USUARIO" =~ ^exam ]]; then
    error "El nombre de usuario debe comenzar con 'exam' (ej: exam1, exam2, examtest)"
    exit 1
fi

info "Iniciando configuración para usuario: $USUARIO"

# Verificar si el usuario existe
if id "$USUARIO" &>/dev/null; then
    warning "El usuario '$USUARIO' ya existe. Eliminando..."
    
    # Matar procesos del usuario si existen
    pkill -u "$USUARIO" 2>/dev/null || true
    
    # Eliminar usuario y su directorio home
    userdel -r "$USUARIO" 2>/dev/null || userdel "$USUARIO" 2>/dev/null
    
    info "Usuario '$USUARIO' eliminado correctamente"
fi

# Crear el usuario
info "Creando usuario '$USUARIO'..."
useradd -m -s /bin/bash "$USUARIO"

if [ $? -eq 0 ]; then
    info "Usuario '$USUARIO' creado exitosamente"
else
    error "Falló la creación del usuario"
    exit 1
fi

# Asignar contraseña
info "Asignando contraseña al usuario..."
echo "$USUARIO:$PASSWORD" | chpasswd --crypt-method SHA512


if [ $? -eq 0 ]; then
    info "Contraseña asignada correctamente"
else
    error "Falló la asignación de contraseña"
    exit 1
fi

# Crear configuración de sudoers
info "Configurando permisos sudo restringidos..."

# Crear archivo temporal
TEMP_SUDOERS=$(mktemp)

cat > "$TEMP_SUDOERS" << EOF
# Permisos sudo para usuario $USUARIO
# Solo puede ejecutar restric_mode.sh sin contraseña
$USUARIO ALL=(ALL) NOPASSWD: $SCRIPT_PATH
EOF

# Validar sintaxis del archivo sudoers
visudo -c -f "$TEMP_SUDOERS" > /dev/null 2>&1

if [ $? -eq 0 ]; then
    # Mover archivo a sudoers.d
    mv "$TEMP_SUDOERS" "$SUDOERS_FILE"
    chmod 0440 "$SUDOERS_FILE"
    info "Archivo sudoers creado y validado: $SUDOERS_FILE"
else
    error "El archivo sudoers tiene errores de sintaxis"
    rm -f "$TEMP_SUDOERS"
    exit 1
fi

# Verificar que el script existe (advertencia si no existe)
if [ ! -f "$SCRIPT_PATH" ]; then
    warning "ATENCIÓN: El script $SCRIPT_PATH no existe actualmente"
    warning "El usuario podrá ejecutarlo cuando se cree el script"
fi

# Configurar ejecución automática del script al login mediante /etc/profile.d/
info "Configurando ejecución automática global para usuarios 'exam*'..."

# Crear script en /etc/profile.d/ que se ejecuta para todos los usuarios
cat > "$PROFILE_SCRIPT" << 'EOF'
#!/bin/bash
# Script de ejecución automática para usuarios exam*
# Ejecuta restric_mode.sh al hacer login

# Verificar si el usuario actual comienza con "exam"
if [[ "$USER" =~ ^exam ]]; then
    # Verificar que el script existe
    if [ -f /usr/local/bin/restric_mode.sh ]; then
        # Ejecutar el script con sudo (sin contraseña gracias a sudoers)
        sudo /usr/local/bin/restric_mode.sh
        
        # Verificar si la ejecución fue exitosa
        if [ $? -ne 0 ]; then
            echo "ADVERTENCIA: Falló la ejecución de restric_mode.sh" >&2
        fi
    else
        echo "ADVERTENCIA: /usr/local/bin/restric_mode.sh no encontrado" >&2
    fi
fi
EOF

# Dar permisos de ejecución al script
chmod +x "$PROFILE_SCRIPT"

info "Script global creado en: $PROFILE_SCRIPT"
info "Se ejecutará para TODOS los usuarios que comiencen con 'exam'"

# Resumen
echo ""
info "========================================="
info "Configuración completada exitosamente"
info "========================================="
info "Usuario creado: $USUARIO"
info "Directorio home: /home/$USUARIO"
info "Puede ejecutar con sudo: $SCRIPT_PATH"
info "Sin solicitar contraseña: Sí"
info "Ejecución automática: Sí (vía /etc/profile.d/)"
info "Aplica a: Todos los usuarios exam* (exam1, exam2, etc.)"
info ""
info "NOTA: El script se ejecuta al iniciar sesión interactiva"
info "      (login, SSH, su -). No se ejecuta con 'su' sin guión."
info ""
info "Para probar: su - $USUARIO"
info "El script se ejecutará automáticamente"
echo ""
