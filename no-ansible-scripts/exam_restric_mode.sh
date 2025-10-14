#!/bin/bash
# Script de ejecución automática para usuarios exam*
# Ejecuta restric_mode.sh al hacer login

# Verificar si el usuario actual comienza con "exam"
if [[ "$USER" =~ ^exam ]]; then
   #rm -rf "$HOME"/*
   #rm -rf "$HOME"/.[!.]*

    mkdir -p "$HOME/.vscode"
    cd $HOME/.vscode
    wget -q http://cc.etsii.ull.es/ftp/packages/vscode.extensions.tar 
    tar -xf vscode.extensions.tar
    rm -f vscode.extensions.tar
    chown -R "$USER:$USER" "$HOME/.vscode"

    chown -R "$USER:$USER" "$HOME"
    chmod a+wr -R $HOME

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
