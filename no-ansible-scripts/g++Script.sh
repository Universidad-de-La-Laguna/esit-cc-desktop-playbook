#!/bin/bash

equipos=(p1124-{1..4}{1..6} p1124-00)

actualizados=()
fallidos=()

echo "Iniciando actualización en paralelo de ${#equipos[@]} equipos..."
echo "----------------------------------------------------------"

tmpdir=$(mktemp -d)

for equipo in "${equipos[@]}"; do
    (
        echo "[$equipo] Iniciando actualización..."

        ssh -o StrictHostKeyChecking=no \
            -o ConnectTimeout=6 \
            root@"$equipo" \
            "ir install-gcc15.sh"

        resultado=$?

        if [ "$resultado" -eq 0 ]; then
            echo "$equipo" > "$tmpdir/$equipo.ok"
            echo "[$equipo] ACTUALIZADO"
        else
            echo "$equipo" > "$tmpdir/$equipo.error"
            echo "[$equipo] ERROR (código $resultado)"
        fi
    ) &
done

wait

echo
echo "=========================================================="
echo "                 RESUMEN DE ACTUALIZACIÓN"
echo "=========================================================="

echo
echo "EQUIPOS ACTUALIZADOS:"

for equipo in "${equipos[@]}"; do
    if [[ -f "$tmpdir/$equipo.ok" ]]; then
        echo "  [OK] $equipo"
        actualizados+=("$equipo")
    fi
done

echo
echo "EQUIPOS CON ERRORES:"

for equipo in "${equipos[@]}"; do
    if [[ -f "$tmpdir/$equipo.error" ]]; then
        echo "  [ERROR] $equipo"
        fallidos+=("$equipo")
    fi
done

echo
echo "----------------------------------------------------------"
echo "Total equipos:       ${#equipos[@]}"
echo "Actualizados:        ${#actualizados[@]}"
echo "Con errores:         ${#fallidos[@]}"
echo "----------------------------------------------------------"

rm -rf "$tmpdir"
