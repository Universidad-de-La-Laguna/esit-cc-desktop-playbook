#!/bin/bash
# Comprobar instalación de mediapipe en /opt/env-sipc

source /opt/env-sipc/bin/activate

echo "Host: $(hostname)"
pip list --format=columns | grep mediapipe && echo "✅ mediapipe instalado correctamente" || echo "❌ mediapipe no encontrado"
