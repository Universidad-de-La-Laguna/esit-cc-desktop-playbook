#!/bin/bash

# Entorno para la asignatura "Tratamiento Inteligente de Datos"
NOMBRE_ENTORNO="tid-env"
RUTA_ENTORNO="/opt/$NOMBRE_ENTORNO"

sudo apt update -y
sudo apt install -y python3-dev python3-venv python3-pip
cd /opt

#Crear entorno virtual en ruta entorno
sudo python3 -m venv "$NOMBRE_ENTORNO"

#Activar entorno virtual e instalar las librerias de python
source /opt/"$NOMBRE_ENTORNO"/bin/activate
python3 -m pip install jupyter matplotlib nltk scipy numpy scikit-learn tensorflow keras

sudo chmod a+w -R "$RUTA_ENTORNO"
