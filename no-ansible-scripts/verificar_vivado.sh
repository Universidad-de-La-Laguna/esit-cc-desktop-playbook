#!/bin/bash

# Script de verificación de instalación de Vivado
# Verifica que la copia desde el origen se realizó correctamente

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Contadores
ERRORES=0
WARNINGS=0

# Verificar parámetros
if [ -z "$1" ] || [ -z "$2" ]; then
    echo -e "${RED}Error: Debe especificar el ordenador origen y la contraseña${NC}"
    echo "Uso: $0 <ordenador_origen> <contraseña>"
    exit 1
fi

ORIGEN="$1"
export SSHPASS="$2"

echo "========================================="
echo "  Verificación de instalación de Vivado"
echo "========================================="
echo ""

# 1. Verificar archivos específicos
echo "1. Verificando archivos específicos..."
echo "----------------------------------------"

check_file() {
    local archivo="$1"
    if [ -e "$archivo" ]; then
        echo -e "[${GREEN}✓${NC}] $archivo"
    else
        echo -e "[${RED}✗${NC}] $archivo - NO ENCONTRADO"
        ((ERRORES++))
    fi
}

check_file "/etc/profile.d/vivado.sh"
check_file "/tools"
check_file "/etc/udev/rules.d/52-digilent-usb.rules"

echo ""

# 2. Conteo de archivos en /tools/
echo "2. Contando archivos en /tools/..."
echo "----------------------------------------"

if [ -d "/tools" ]; then
    TOTAL_ARCHIVOS=$(find /tools -type f 2>/dev/null | wc -l)
    TOTAL_DIRS=$(find /tools -type d 2>/dev/null | wc -l)
    ESPACIO=$(du -sh /tools 2>/dev/null | cut -f1)
    
    echo -e "[${GREEN}✓${NC}] Total archivos: $TOTAL_ARCHIVOS"
    echo -e "[${GREEN}✓${NC}] Total directorios: $TOTAL_DIRS"
    echo -e "[${GREEN}✓${NC}] Espacio ocupado: $ESPACIO"
    
    if [ "$TOTAL_ARCHIVOS" -eq 0 ]; then
        echo -e "[${RED}✗${NC}] ADVERTENCIA: /tools/ está vacío"
        ((ERRORES++))
    fi
else
    echo -e "[${RED}✗${NC}] /tools/ no existe"
    ((ERRORES++))
fi

echo ""

# 3. Verificar conectividad con origen
echo "3. Verificando conectividad con origen..."
echo "----------------------------------------"

if ! sshpass -e ssh -o ConnectTimeout=10 -o StrictHostKeyChecking=no ${ORIGEN} "echo OK" &>/dev/null; then
    echo -e "[${RED}✗${NC}] No se puede conectar con $ORIGEN"
    echo "No se puede realizar la comparación con rsync"
    ((ERRORES++))
    SKIP_RSYNC=1
else
    echo -e "[${GREEN}✓${NC}] Conectividad con $ORIGEN: OK"
fi

echo ""

# 4. Comparación con rsync (sin checksum, solo metadatos)
if [ -z "$SKIP_RSYNC" ]; then
    echo "4. Comparando archivos con origen (rsync)..."
    echo "----------------------------------------"
    echo "Esto puede tardar 1-3 minutos..."
    echo ""
    
    # Archivo temporal para capturar diferencias
    DIFF_FILE=$(mktemp)
    
    # Verificar vivado.sh
    echo -n "Verificando vivado.sh... "
    sshpass -e rsync -aHAX --dry-run --itemize-changes \
        -e "ssh -o StrictHostKeyChecking=no" \
        ${ORIGEN}:/etc/profile.d/vivado.sh /etc/profile.d/ > $DIFF_FILE 2>&1
    
    if [ -s "$DIFF_FILE" ]; then
        echo -e "${YELLOW}DIFERENCIAS${NC}"
        ((WARNINGS++))
        cat $DIFF_FILE
    else
        echo -e "${GREEN}OK${NC}"
    fi
    
    # Verificar /tools/
    echo -n "Verificando /tools/ ... "
    sshpass -e rsync -aHAX --dry-run --itemize-changes \
        -e "ssh -o StrictHostKeyChecking=no" \
        ${ORIGEN}:/tools/ /tools/ > $DIFF_FILE 2>&1
    
    if [ -s "$DIFF_FILE" ]; then
        echo -e "${YELLOW}DIFERENCIAS ENCONTRADAS${NC}"
        ((WARNINGS++))
        echo "Primeras 20 diferencias:"
        head -20 $DIFF_FILE
        TOTAL_DIFF=$(wc -l < $DIFF_FILE)
        if [ "$TOTAL_DIFF" -gt 20 ]; then
            echo "... y $((TOTAL_DIFF - 20)) diferencias más"
        fi
    else
        echo -e "${GREEN}OK${NC}"
    fi
    
    # Verificar regla udev
    echo -n "Verificando regla udev... "
    sshpass -e rsync -aHAX --dry-run --itemize-changes \
        -e "ssh -o StrictHostKeyChecking=no" \
        ${ORIGEN}:/etc/udev/rules.d/52-digilent-usb.rules \
        /etc/udev/rules.d/ > $DIFF_FILE 2>&1
    
    if [ -s "$DIFF_FILE" ]; then
        echo -e "${YELLOW}DIFERENCIAS${NC}"
        ((WARNINGS++))
        cat $DIFF_FILE
    else
        echo -e "${GREEN}OK${NC}"
    fi
    
    rm -f $DIFF_FILE
    echo ""
fi

# 5. Resumen final
echo "========================================="
echo "           RESUMEN DE VERIFICACIÓN"
echo "========================================="

if [ "$ERRORES" -eq 0 ] && [ "$WARNINGS" -eq 0 ]; then
    echo -e "${GREEN}Estado: INSTALACIÓN VERIFICADA ✓${NC}"
    echo "Todos los archivos están presentes y sin diferencias"
    exit 0
elif [ "$ERRORES" -gt 0 ]; then
    echo -e "${RED}Estado: INSTALACIÓN INCOMPLETA ✗${NC}"
    echo "Errores encontrados: $ERRORES"
    [ "$WARNINGS" -gt 0 ] && echo "Advertencias: $WARNINGS"
    exit 1
else
    echo -e "${YELLOW}Estado: INSTALACIÓN CON DIFERENCIAS ⚠${NC}"
    echo "Advertencias: $WARNINGS"
    echo "Los archivos principales existen pero hay diferencias con el origen"
    exit 2
fi