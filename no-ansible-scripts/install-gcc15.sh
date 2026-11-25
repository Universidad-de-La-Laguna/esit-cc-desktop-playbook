#!/bin/bash

set -e

# Añadir el repositorio
sudo add-apt-repository -y ppa:ubuntu-toolchain-r/test
sudo apt update

# Instalar GCC 15 y G++ 15
sudo apt install -y gcc-15 g++-15

# Verificar la instalación
gcc-15 --version
g++-15 --version
