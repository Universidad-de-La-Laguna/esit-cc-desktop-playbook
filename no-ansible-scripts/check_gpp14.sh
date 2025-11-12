#!/bin/bash

# Mostrar el hostname
echo "Hostname: $(hostname)"

# Comprobar si g++-14 está instalado
if command -v g++-14 &> /dev/null; then
    echo "g++-14: INSTALADO"
    echo "Versión: $(g++-14 --version | head -n1)"
else
    echo "g++-14: NO INSTALADO"
fi