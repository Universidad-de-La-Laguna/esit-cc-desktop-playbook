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

# Función para crear el script restric_mode.sh
crear_script_restric_mode() {
    local SCRIPT_PATH="$1"
    
    info "Creando script de restricción de red: $SCRIPT_PATH"
    
    cat > "$SCRIPT_PATH" << 'EOFSCRIPT'
#!/bin/bash

###############################################################################
# Script: restric_mode.sh
# Descripción: Restringe el acceso a Internet permitiendo solo ciertos destinos
# Uso: sudo /usr/local/bin/restric_mode.sh
###############################################################################

set -e

# Dominios y direcciones permitidas
ALLOWED_DOMAINS=(
    "campusvirtual.ull.es"
    "valida.ull.es"
)

ALLOWED_IPS=(
    "10.4.9.29"
    "10.4.9.30"
)

LOG_FILE="/var/log/restric_mode.log"

# Función de logging
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "=== Iniciando modo restringido para usuario: $SUDO_USER ==="

# Limpiar reglas existentes de iptables para el usuario
log_message "Limpiando reglas anteriores..."

# Crear cadena personalizada si no existe
iptables -N RESTRIC_MODE 2>/dev/null || iptables -F RESTRIC_MODE

# Limpiar la cadena
iptables -F RESTRIC_MODE

# Política por defecto: DENEGAR todo el tráfico saliente
log_message "Aplicando política restrictiva..."

# Permitir loopback (localhost)
iptables -A RESTRIC_MODE -o lo -j ACCEPT
log_message "Permitido: loopback (localhost)"

# Permitir conexiones establecidas y relacionadas
iptables -A RESTRIC_MODE -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
log_message "Permitido: conexiones establecidas"

# Permitir IPs específicas
for ip in "${ALLOWED_IPS[@]}"; do
    iptables -A RESTRIC_MODE -d "$ip" -j ACCEPT
    log_message "Permitido: IP $ip"
done

# Resolver y permitir dominios
for domain in "${ALLOWED_DOMAINS[@]}"; do
    # Resolver el dominio a IPs (tanto IPv4)
    domain_ips=$(dig +short "$domain" A 2>/dev/null | grep -E '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+
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
echo "$USUARIO:$PASSWORD" | chpasswd

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
echo "")
    
    if [ -n "$domain_ips" ]; then
        while IFS= read -r ip; do
            iptables -A RESTRIC_MODE -d "$ip" -j ACCEPT
            log_message "Permitido: $domain -> $ip"
        done <<< "$domain_ips"
    else
        log_message "ADVERTENCIA: No se pudo resolver $domain"
    fi
done

# Permitir DNS (necesario para resolver nombres)
iptables -A RESTRIC_MODE -p udp --dport 53 -j ACCEPT
iptables -A RESTRIC_MODE -p tcp --dport 53 -j ACCEPT
log_message "Permitido: DNS (puerto 53)"

# DENEGAR todo lo demás
iptables -A RESTRIC_MODE -j DROP
log_message "Denegado: todo el resto del tráfico"

# Aplicar la cadena al tráfico OUTPUT
iptables -I OUTPUT 1 -j RESTRIC_MODE

log_message "=== Modo restringido activado correctamente ==="

echo "╔════════════════════════════════════════════════════════╗"
echo "║     MODO RESTRINGIDO DE RED ACTIVADO                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo ""
echo "Acceso permitido únicamente a:"
echo "  • campusvirtual.ull.es"
echo "  • valida.ull.es"
echo "  • 10.4.9.29"
echo "  • 10.4.9.30"
echo ""
echo "Todo el demás tráfico de Internet está bloqueado."
echo "Log: $LOG_FILE"
echo ""
EOFSCRIPT

    # Dar permisos de ejecución
    chmod +x "$SCRIPT_PATH"
    
    # Crear archivo de log si no existe
    touch /var/log/restric_mode.log
    chmod 644 /var/log/restric_mode.log
    
    info "Script de restricción creado exitosamente"
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
echo "$USUARIO:$PASSWORD" | chpasswd

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
