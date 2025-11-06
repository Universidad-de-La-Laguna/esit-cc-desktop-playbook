#!/bin/bash

# Script simple para cambiar arranque predeterminado a Linux en Ubuntu 24.04

# Verificar root
if [ "$EUID" -ne 0 ]; then 
    echo "Error: Ejecuta con sudo"
    exit 1
fi

echo "Cambiando arranque predeterminado a Linux..."

# Backup
cp /etc/default/grub /etc/default/grub.backup

# Modificar configuración para arrancar la primera entrada (Linux)
sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=0/' /etc/default/grub

# Actualizar GRUB
update-grub

# Establecer la primera entrada (Ubuntu) como predeterminada
grub-set-default 0

echo "¡Listo! Linux ahora arrancará por defecto"
echo "Backup guardado en: /etc/default/grub.backup"
