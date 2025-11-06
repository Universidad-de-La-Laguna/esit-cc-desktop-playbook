#!/bin/bash

# Script simple para cambiar arranque predeterminado a Windows en Ubuntu 24.04

# Verificar root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: Ejecuta con sudo"
    exit 1
fi

echo "Cambiando arranque predeterminado a Windows..."

# Backup
cp /etc/default/grub /etc/default/grub.backup

# Buscar entrada de Windows
WINDOWS_ENTRY=$(grep -E "menuentry.*Windows" /boot/grub/grub.cfg | head -n 1 | cut -d "'" -f2)

if [ -z "$WINDOWS_ENTRY" ]; then
    echo "Error: No se encontró Windows en GRUB"
    exit 1
fi

echo "Windows encontrado: $WINDOWS_ENTRY"

# Modificar configuración
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=saved/' /etc/default/grub

# Actualizar GRUB
update-grub

# Establecer Windows como predeterminado
grub-set-default "$WINDOWS_ENTRY"

echo "¡Listo! Windows ahora arrancará por defecto"
echo "Backup guardado en: /etc/default/grub.backup"
