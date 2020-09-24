#!/bin/bash

#
# Instala extensiones de VSCode en el perfil del usuario del Disco Duro Virtual
# para hacerlas permanentes y móviles (se usan en cualquier puesto al que vaya el usuario)
#
# Autor: BJCV
# Centro de Cálculo de la ESIT
#

# Personalización de mensajes al usuario
function escribelog {
    echo $1 | awk '
    function color(c,s) {
            printf("\033[%dm%s\033[0m\n",30+c,s)
    }
    /ERROR/ {color(1,$0);next}
    /SUCCESS/ {color(2,$0);next}
    /WARNING/ {color(3,$0);next}
    /INFO/ {color(4,$0);next}
    /DBG/ {color(5,$0);next}
    {print}
    '
}

# Comprobación de parámetros
if [ $# -ne 1 ]
then
    escribelog "ERROR: Número de parámetros incorrecto." >&2
    escribelog "INFO: vscode_ddvinstallextension.sh <extension>" >&2
    exit 1
fi

# Comprobamos que esta VSCode instalado
dpkg -s code | grep "Status" > /dev/null 2> /dev/null

if [ $? -ne 0 ]
then
  escribelog "ERROR: VScode no está instalado. Si lo necesita póngase en contacto con ccetsii@ull.edu.es" >&2
  exit 1
fi

# Instalamos la extensión de forma local para que funcione en la sesión actual al terminar el script
escribelog "DBG: Instalando extensión en directorio home del usuario ($HOME/.vscode/extensions)"
code --install-extension $1

if [ $? -ne 0 ]
then
    escribelog "ERROR: Hubo un problema al instalar la extensión $1" >&2
    exit 1
else
    escribelog "SUCCESS: Extensión $1 instalada satisfactoriamente en el directorio $HOME/.vscode/extensions"
fi

# Instalamos la extensión en el perfil del DDV del usuario para movilidad
escribelog "DBG: Instalando extensión en el disco duro virtual..."

DDVDIR="$HOME/datos/Disco_Duro_Virtual/private/perfilesesit/perfil-ubuntu18.04"
if [ ! -d "$DDVDIR" ]; then
    escribelog "ERROR: Directorio $DDVDIR no existe. Parece que no se ha montado correctamente la unidad de disco duro virtual"
    exit 1
fi

code --install-extension $1 --extensions-dir $DDVDIR/.vscode/extensions

if [ $? -ne 0 ]
then
    escribelog "ERROR: Hubo un problema al instalar la extensión $1 en el disco duro virtual" >&2
    exit 1
else
    escribelog "SUCCESS: Extensión $1 instalada satisfactoriamente en el directorio $DDVDIR/.vscode/extensions"
fi

escribelog "INFO: La extensión $1 se ha instalado correctamente en su disco duro virtual."
escribelog "INFO: Estas extensiones se copiaran cada vez que inicie sesión en un equipo por lo que no es necesario que las instale de nuevo en ningún ordenador."